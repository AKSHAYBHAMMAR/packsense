# ==============================================================================
# Stage 1: Build the Flutter Web application
# ==============================================================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Compile-time build arguments for optional Supabase configuration
ARG SUPABASE_URL=""
ARG SUPABASE_ANON_KEY=""

# Copy dependency manifests first to leverage Docker layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the application source code
COPY . .

# Build the release bundle for Flutter Web with optional compile-time defines
RUN flutter build web --release \
    --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
    --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

# ==============================================================================
# Stage 2: Production runtime with lightweight Nginx
# ==============================================================================
FROM nginx:alpine

# Remove default Nginx configuration
RUN rm -rf /etc/nginx/conf.d/default.conf

# Copy custom Nginx configuration with SPA fallback and security headers
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web artifacts from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose HTTP port 80
EXPOSE 80

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
