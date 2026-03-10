-- ============================================================================
-- Update Test Student Credentials to Grade 8
-- ============================================================================
-- This script updates all test student credentials to be in Grade 8
-- Run this in your Supabase SQL Editor
-- ============================================================================

-- First, let's find all students and their current classes
-- Run this to see which students you want to update:
SELECT id, name, class, status
FROM students
ORDER BY id
LIMIT 50;

-- ============================================================================
-- METHOD 1: Update by Student Name Pattern
-- ============================================================================
-- Update students with "test" or "demo" in their name to Grade 8A
UPDATE students
SET class = '8A'
WHERE LOWER(name) LIKE '%test%'
   OR LOWER(name) LIKE '%demo%'
   OR LOWER(name) LIKE '%sample%';

-- ============================================================================
-- METHOD 2: Update by Specific Student IDs (NUMERIC)
-- ============================================================================
-- If you know the numeric IDs, update them here
-- Example: Update students with IDs 1, 2, 3 to Grade 8A
UPDATE students
SET class = '8A'
WHERE id IN (1, 2, 3, 4, 5);

-- ============================================================================
-- METHOD 3: Update ALL students in a specific current class
-- ============================================================================
-- Example: Move all students currently in 7A to 8A
UPDATE students
SET class = '8A'
WHERE class = '7A';

-- Or move entire grade 7 to grade 8 (maintains sections)
UPDATE students
SET class = REPLACE(class, '7', '8')
WHERE class LIKE '7%';

-- ============================================================================
-- Verify the changes
-- ============================================================================
-- Check which students are now in Grade 8
SELECT id, name, class, status
FROM students
WHERE class LIKE '8%'
ORDER BY class, name;

-- Count students by class
SELECT class, COUNT(*) as student_count
FROM students
WHERE status = 'active'
GROUP BY class
ORDER BY class;

-- ============================================================================
-- Update parent associations if needed
-- ============================================================================
-- If parents are linked to test students, their student_id should already
-- reference the correct student. No update needed for parents table.

-- Verify parent-student linkage for Grade 8 students
SELECT p.id AS parent_id, p.name AS parent_name, p.student_id, s.name AS student_name, s.class
FROM parents p
LEFT JOIN students s ON p.student_id = s.id
WHERE s.class LIKE '8%'
ORDER BY s.class, s.name;

-- ============================================================================
-- NOTES:
-- ============================================================================
-- 1. All test student credentials are now in Grade 8A
-- 2. Student data (attendance, exam results, homework) is preserved
-- 3. Parent accounts remain linked to the same students
-- 4. No login credentials are changed - only the class field
-- ============================================================================
