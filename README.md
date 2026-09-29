# PackSense

PackSense is an **AI/ML-based Food Packaging Recommendation System**. It matches food commodities and product specifications with optimal, sustainable barrier packaging materials.

## Overview

PackSense helps food producers, commercial kitchens, and packaging engineers determine suitable food packaging materials based on:
- **Food Characteristics:** Commodity profiles, physical states, moisture levels, pH/acidity, fat/oil content.
- **Storage & Shelf Life:** Storage temperatures (room temp, refrigerated, frozen) and target freshness duration.
- **Logistics & Fragility:** Transport distance and impact protection.
- **Economic & Environmental Goals:** Recyclability, compostability, and budget optimization.

## Technology Stack

- **Frontend:** Flutter / Dart 
- **UI/UX Source of Truth:** Google Stitch Design Specifications (Plus Jakarta Sans, Epistemic status cues, 52px safe touch targets)
- **Backend:** FastAPI
- **ML Engine :** Python + Scikit-learn
- **Database & Auth:** Supabase

## Project Structure

```
PackSense/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/          # AppColors, AppTypography, AppTheme
│   │   └── widgets/        # Reusable buttons, cards, progress bars, tags
│   ├── data/
│   │   ├── models/         # FoodItem, FoodProperties, PackagingMaterial, Recommendation, AnalysisHistoryItem
│   │   └── repositories/   # PackagingRepository, HistoryRepository, CommodityRepository
│   └── presentation/
│       ├── history/        # Real database-backed History & Detail screens
│       ├── home/           # Home screen & components
│       ├── materials/      # Materials catalog & technical specifications
│       ├── profile/        # Supabase auth profile & session management
│       └── recommendation_flow/ # 4-step recommendation flow
├── supabase/
│   └── migrations/     # PostgreSQL DDL migrations & Row-Level Security policies
├── pubspec.yaml
├── .gitignore
└── stitch_packsense_ui_ux_design/ # Stitch UI reference design assets
```

## Getting Started

1. Ensure Flutter SDK (>= 3.0.0) is installed.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   # Standard local session mode:
   flutter run

   # Connected to Supabase Cloud backend:
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

## Database & Supabase Integration

PackSense persists completed food packaging recommendations to Supabase in the `analysis_history` table with Row-Level Security (RLS) guaranteeing user-level isolation:
- **Migration script:** [`supabase/migrations/20260929_create_analysis_history.sql`](supabase/migrations/20260929_create_analysis_history.sql)
- **RLS Policies:** Authenticated users can SELECT, INSERT, and DELETE only their own records (`auth.uid() = user_id`). Records are immutable (no client-side updates).
- **History Tab:** Loads and orders records by `created_at DESC` with relative timestamps ("Just now", "2 hours ago", "Yesterday").
- **View Details:** Inspects the exact persisted analysis parameters, storage conditions, and barrier metrics without recomputing results.
