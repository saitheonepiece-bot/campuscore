-- Migration: Add Classes for Grades 6, 7, and 8
-- Creates classes 6A-6L, 7A-7L, and 8A-8K
-- Date: 2026-02-21
-- Schema: name, grade, section, class_teacher_id, total_students, is_active

-- Step 1: Add is_active column if it doesn't exist
ALTER TABLE classes ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Step 2: Update existing rows to set is_active = true
UPDATE classes SET is_active = true WHERE is_active IS NULL;

-- Step 3: Insert Grade 6 Classes (6A to 6L) - 12 sections
INSERT INTO classes (name, grade, section, total_students, class_teacher_id)
VALUES
    ('6A', 6, 'A', 0, NULL),
    ('6B', 6, 'B', 0, NULL),
    ('6C', 6, 'C', 0, NULL),
    ('6D', 6, 'D', 0, NULL),
    ('6E', 6, 'E', 0, NULL),
    ('6F', 6, 'F', 0, NULL),
    ('6G', 6, 'G', 0, NULL),
    ('6H', 6, 'H', 0, NULL),
    ('6I', 6, 'I', 0, NULL),
    ('6J', 6, 'J', 0, NULL),
    ('6K', 6, 'K', 0, NULL),
    ('6L', 6, 'L', 0, NULL)
ON CONFLICT (name) DO NOTHING;

-- Insert Grade 7 Classes (7A to 7L) - 12 sections
INSERT INTO classes (name, grade, section, total_students, class_teacher_id)
VALUES
    ('7A', 7, 'A', 0, NULL),
    ('7B', 7, 'B', 0, NULL),
    ('7C', 7, 'C', 0, NULL),
    ('7D', 7, 'D', 0, NULL),
    ('7E', 7, 'E', 0, NULL),
    ('7F', 7, 'F', 0, NULL),
    ('7G', 7, 'G', 0, NULL),
    ('7H', 7, 'H', 0, NULL),
    ('7I', 7, 'I', 0, NULL),
    ('7J', 7, 'J', 0, NULL),
    ('7K', 7, 'K', 0, NULL),
    ('7L', 7, 'L', 0, NULL)
ON CONFLICT (name) DO NOTHING;

-- Insert Grade 8 Classes (8A to 8K) - 11 sections
-- Note: 8B already exists in the database
INSERT INTO classes (name, grade, section, total_students, class_teacher_id)
VALUES
    ('8A', 8, 'A', 0, NULL),
    ('8C', 8, 'C', 0, NULL),
    ('8D', 8, 'D', 0, NULL),
    ('8E', 8, 'E', 0, NULL),
    ('8F', 8, 'F', 0, NULL),
    ('8G', 8, 'G', 0, NULL),
    ('8H', 8, 'H', 0, NULL),
    ('8I', 8, 'I', 0, NULL),
    ('8J', 8, 'J', 0, NULL),
    ('8K', 8, 'K', 0, NULL)
ON CONFLICT (name) DO NOTHING;

-- Verify the insertions
SELECT
    grade,
    COUNT(*) as total_sections,
    STRING_AGG(section, ', ' ORDER BY section) as sections
FROM classes
WHERE grade IN (6, 7, 8)
GROUP BY grade
ORDER BY grade;
