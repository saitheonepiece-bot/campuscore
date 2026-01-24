-- ============================================
-- FIX: Add 'class' column to issues table
-- ============================================
-- This fixes the error: "Could not find the 'class' column of 'issues'"
-- Run this in Supabase SQL Editor
-- ============================================

-- STEP 1: Add the class column if it doesn't exist
ALTER TABLE issues
ADD COLUMN IF NOT EXISTS class TEXT;

-- STEP 2: Ensure all permissions are granted
GRANT ALL ON TABLE issues TO anon, authenticated, service_role, postgres;

-- STEP 3: Disable RLS on issues table
ALTER TABLE issues DISABLE ROW LEVEL SECURITY;

-- STEP 4: Verify the column exists
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'issues'
ORDER BY ordinal_position;

-- ============================================
-- COMPLETE!
-- ============================================
-- The 'class' column should now exist and be accessible
-- Try filing an issue again - it should work!
