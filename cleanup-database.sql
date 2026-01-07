-- CampusCore Database Cleanup Script
-- This will remove all student data EXCEPT for Kasula (3180076) and Sai Charan (3240504)
-- Run this in your Supabase SQL Editor

-- ============================================
-- STEP 1: Delete Attendance Records
-- ============================================
-- Delete attendance for students we're removing
DELETE FROM attendance
WHERE student_id IN (3180077, 3180078, 3180079, 3180080);

-- ============================================
-- STEP 2: Delete Exam Results
-- ============================================
-- Delete exam results for students we're removing
DELETE FROM exam_results
WHERE student_id IN (3180077, 3180078, 3180079, 3180080);

-- ============================================
-- STEP 3: Delete Marks Submissions
-- ============================================
-- Delete marks submissions for students we're removing
DELETE FROM marks_submissions
WHERE student_id IN (3180077, 3180078, 3180079, 3180080);

-- ============================================
-- STEP 4: Delete Student Documents
-- ============================================
-- Delete documents for students we're removing
DELETE FROM student_documents
WHERE student_id IN (3180077, 3180078, 3180079, 3180080);

-- ============================================
-- STEP 5: Delete Report Cards
-- ============================================
-- Delete report cards for students we're removing
DELETE FROM report_cards
WHERE student_id IN (3180077, 3180078, 3180079, 3180080);

-- ============================================
-- STEP 6: Delete Parent Records
-- ============================================
-- Delete parent records for removed students
DELETE FROM parents
WHERE id IN ('P3180077A', 'P3180078A', 'P3180079A', 'P3180080A');

-- ============================================
-- STEP 7: Delete User Accounts
-- ============================================
-- Delete login accounts for removed parents
DELETE FROM users
WHERE username IN ('P3180077A', 'P3180078A', 'P3180079A', 'P3180080A');

-- ============================================
-- STEP 8: Delete Student Records
-- ============================================
-- Finally, delete the student records
DELETE FROM students
WHERE id IN (3180077, 3180078, 3180079, 3180080);

-- ============================================
-- STEP 9: Update Class Student Count
-- ============================================
-- Update the total student count for class 8B
UPDATE classes
SET total_students = 2
WHERE name = '8B';

-- Update the total student count for class 10A (now 0 students)
UPDATE classes
SET total_students = 0
WHERE name = '10A';

-- ============================================
-- VERIFICATION: Check Remaining Students
-- ============================================
-- Run this to verify only 2 students remain
SELECT id, name, class, parent_id, status
FROM students
ORDER BY id;

-- Expected result: Only 2 rows
-- 3180076 | Kasula Ashwath | 8B | P3180076A | active
-- 3240504 | Sai Charan     | 8B | P3240504A | active

-- ============================================
-- VERIFICATION: Check Remaining Parents
-- ============================================
SELECT id, name, student_id
FROM parents
ORDER BY id;

-- Expected result: Only 2 rows
-- P3180076A | Parent of Kasula     | 3180076
-- P3240504A | Parent of Sai Charan | 3240504

-- ============================================
-- VERIFICATION: Check Remaining Parent Users
-- ============================================
SELECT username, name, role
FROM users
WHERE role = 'parent'
ORDER BY username;

-- Expected result: Only 2 rows
-- P3180076A | Parent of Kasula     | parent
-- P3240504A | Parent of Sai Charan | parent

-- Cleanup complete!
