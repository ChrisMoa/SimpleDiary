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