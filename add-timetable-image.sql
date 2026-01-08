-- ============================================
-- Add Timetable Image Support
-- ============================================
-- Run this SQL in your Supabase SQL Editor to add image support to timetables

-- Add image_data column to store base64 encoded images
ALTER TABLE timetables ADD COLUMN IF NOT EXISTS image_data TEXT;

-- Success message
SELECT 'Timetable table updated successfully with image support!' as message;
