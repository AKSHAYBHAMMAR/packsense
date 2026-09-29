-- PackSense Supabase Database Migration
-- Table: analysis_history
-- Description: Stores completed food packaging recommendation analyses per authenticated user.

-- 1. Create table
CREATE TABLE IF NOT EXISTS public.analysis_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    has_product_data BOOLEAN NOT NULL DEFAULT FALSE,
    analysis_type TEXT NOT NULL DEFAULT 'ai_estimate', -- 'measured' | 'ai_estimate'
    moisture NUMERIC NULL,
    temperature NUMERIC NULL,
    relative_humidity NUMERIC NULL,
    storage_condition TEXT NULL,
    recommended_material TEXT NOT NULL,
    recommendation_reason TEXT NULL,
    barrier_properties JSONB NULL,
    predicted_shelf_life TEXT NULL,
    confidence_score NUMERIC NULL,
    input_data JSONB NULL,
    recommendation_data JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. Performance index: user lookup sorted by latest first
CREATE INDEX IF NOT EXISTS idx_analysis_history_user_created 
    ON public.analysis_history (user_id, created_at DESC);

-- 3. Enable Row Level Security
ALTER TABLE public.analysis_history ENABLE ROW LEVEL SECURITY;

-- 4. RLS: SELECT - Users can read ONLY their own analysis records
CREATE POLICY "Users can view own analysis history"
    ON public.analysis_history
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- 5. RLS: INSERT - Users can insert analysis records ONLY under their own user ID
CREATE POLICY "Users can insert own analysis history"
    ON public.analysis_history
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- 6. RLS: DELETE - Users can delete their own analysis records
CREATE POLICY "Users can delete own analysis history"
    ON public.analysis_history
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Immutable: No UPDATE policy provided.
