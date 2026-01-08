-- ============================================
-- Update Issues Table - Add Student Information
-- ============================================
-- Run this SQL in your Supabase SQL Editor to add new columns to the issues table

-- Add student_id column
ALTER TABLE issues ADD COLUMN IF NOT EXISTS student_id BIGINT;

-- Add student_name column
ALTER TABLE issues ADD COLUMN IF NOT EXISTS student_name TEXT;

-- Add class column
ALTER TABLE issues ADD COLUMN IF NOT EXISTS class TEXT;

-- Success message
SELECT 'Issues table updated successfully with student information columns!' as message;
