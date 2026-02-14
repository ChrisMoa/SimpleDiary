-- Complete database schema for the day tracker application

-- Create diary_days table
CREATE TABLE public.diary_days (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    day DATE NOT NULL,
    ratings JSONB NOT NULL,
    notes JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Create notes table
CREATE TABLE public.notes (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    "from" TEXT NOT NULL,  -- Note: Using quotes because 'from' is a reserved keyword
    "to" TEXT NOT NULL,    -- Note: Using quotes because 'to' is a reserved keyword  
    is_all_day INTEGER NOT NULL,
    note_category TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Add indexes for better performance
CREATE INDEX idx_diary_days_user_id ON public.diary_days(user_id);
CREATE INDEX idx_diary_days_day ON public.diary_days(day);
CREATE INDEX idx_diary_days_notes ON public.diary_days USING gin (notes);
CREATE INDEX idx_notes_user_id ON public.notes(user_id);
CREATE INDEX idx_notes_dates ON public.notes("from", "to");

-- Enable Row Level Security
ALTER TABLE public.diary_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for diary_days
CREATE POLICY "Users can read own diary days" ON public.diary_days
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own diary days" ON public.diary_days
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own diary days" ON public.diary_days
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own diary days" ON public.diary_days
    FOR DELETE USING (auth.uid()::text = user_id);

-- Create RLS policies for notes
CREATE POLICY "Users can read own notes" ON public.notes
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own notes" ON public.notes
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own notes" ON public.notes
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own notes" ON public.notes
    FOR DELETE USING (auth.uid()::text = user_id);

-- Create functions to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_diary_days_updated_at
    BEFORE UPDATE ON public.diary_days
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at
    BEFORE UPDATE ON public.notes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Note Templates Table
CREATE TABLE IF NOT EXISTS public.note_templates (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    note_category TEXT NOT NULL,
    description_sections TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Migration: Add description_sections column to existing note_templates
ALTER TABLE public.note_templates
  ADD COLUMN IF NOT EXISTS description_sections TEXT NOT NULL DEFAULT '';

-- Create index for faster queries by user_id
CREATE INDEX IF NOT EXISTS idx_note_templates_user_id ON public.note_templates(user_id);

-- Enable Row Level Security
ALTER TABLE public.note_templates ENABLE ROW LEVEL SECURITY;

-- Create policies for Row Level Security
CREATE POLICY "Users can view their own templates" ON public.note_templates
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own templates" ON public.note_templates
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own templates" ON public.note_templates
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own templates" ON public.note_templates
    FOR DELETE USING (auth.uid() = user_id);

-- Create trigger for automatically updating updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_note_templates_updated_at
    BEFORE UPDATE ON public.note_templates
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.note_templates TO authenticated;
GRANT ALL ON public.note_templates TO service_role;


-- Optional: Create a function to get user statistics
CREATE OR REPLACE FUNCTION get_user_stats(input_user_id TEXT)
RETURNS JSON AS $$
DECLARE
    stats JSON;
BEGIN
    SELECT json_build_object(
        'total_diary_days', (
            SELECT COUNT(*) 
            FROM public.diary_days 
            WHERE user_id = input_user_id
        ),
        'total_notes', (
            SELECT COUNT(*) 
            FROM public.notes 
            WHERE user_id = input_user_id
        ),
        'latest_entry', (
            SELECT MAX(day) 
            FROM public.diary_days 
            WHERE user_id = input_user_id
        ),
        'average_rating', (
            SELECT AVG((rating->>'score')::integer) 
            FROM public.diary_days,
            jsonb_array_elements(ratings) AS rating
            WHERE user_id = input_user_id
        )
    ) INTO stats;
    
    RETURN stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- TEST TABLES (used by debug builds and integration tests)
-- Same schema as production tables, prefixed with test_
-- ============================================================

-- test_diary_days
CREATE TABLE IF NOT EXISTS public.test_diary_days (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    day DATE NOT NULL,
    ratings JSONB NOT NULL,
    notes JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- test_notes
CREATE TABLE IF NOT EXISTS public.test_notes (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "to" TEXT NOT NULL,
    is_all_day INTEGER NOT NULL,
    note_category TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- test_note_templates
CREATE TABLE IF NOT EXISTS public.test_note_templates (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    note_category TEXT NOT NULL,
    description_sections TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Indexes for test tables
CREATE INDEX IF NOT EXISTS idx_test_diary_days_user_id ON public.test_diary_days(user_id);
CREATE INDEX IF NOT EXISTS idx_test_diary_days_day ON public.test_diary_days(day);
CREATE INDEX IF NOT EXISTS idx_test_diary_days_notes ON public.test_diary_days USING gin (notes);
CREATE INDEX IF NOT EXISTS idx_test_notes_user_id ON public.test_notes(user_id);
CREATE INDEX IF NOT EXISTS idx_test_notes_dates ON public.test_notes("from", "to");
CREATE INDEX IF NOT EXISTS idx_test_note_templates_user_id ON public.test_note_templates(user_id);

-- Enable RLS on test tables
ALTER TABLE public.test_diary_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.test_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.test_note_templates ENABLE ROW LEVEL SECURITY;

-- RLS policies for test_diary_days
CREATE POLICY "Users can read own test diary days" ON public.test_diary_days
    FOR SELECT USING (auth.uid()::text = user_id);
CREATE POLICY "Users can insert own test diary days" ON public.test_diary_days
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);
CREATE POLICY "Users can update own test diary days" ON public.test_diary_days
    FOR UPDATE USING (auth.uid()::text = user_id);
CREATE POLICY "Users can delete own test diary days" ON public.test_diary_days
    FOR DELETE USING (auth.uid()::text = user_id);

-- RLS policies for test_notes
CREATE POLICY "Users can read own test notes" ON public.test_notes
    FOR SELECT USING (auth.uid()::text = user_id);
CREATE POLICY "Users can insert own test notes" ON public.test_notes
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);
CREATE POLICY "Users can update own test notes" ON public.test_notes
    FOR UPDATE USING (auth.uid()::text = user_id);
CREATE POLICY "Users can delete own test notes" ON public.test_notes
    FOR DELETE USING (auth.uid()::text = user_id);

-- RLS policies for test_note_templates
CREATE POLICY "Users can view their own test templates" ON public.test_note_templates
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own test templates" ON public.test_note_templates
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own test templates" ON public.test_note_templates
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own test templates" ON public.test_note_templates
    FOR DELETE USING (auth.uid() = user_id);

-- Triggers for test tables (reuse existing update_updated_at_column function)
CREATE TRIGGER update_test_diary_days_updated_at
    BEFORE UPDATE ON public.test_diary_days
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_test_notes_updated_at
    BEFORE UPDATE ON public.test_notes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_test_note_templates_updated_at
    BEFORE UPDATE ON public.test_note_templates
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Grant permissions for test tables
GRANT ALL ON public.test_diary_days TO authenticated;
GRANT ALL ON public.test_diary_days TO service_role;
GRANT ALL ON public.test_notes TO authenticated;
GRANT ALL ON public.test_notes TO service_role;
GRANT ALL ON public.test_note_templates TO authenticated;
GRANT ALL ON public.test_note_templates TO service_role;