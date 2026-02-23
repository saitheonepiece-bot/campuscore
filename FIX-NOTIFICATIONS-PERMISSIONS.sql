-- ============================================
-- FIX TABLE PERMISSIONS (401 Unauthorized Errors)
-- ============================================
-- Run this in Supabase SQL Editor to fix all permission errors

-- ============================================
-- 1. NOTIFICATIONS TABLE
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON notifications TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON notifications TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE notifications_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE notifications_id_seq TO authenticated;

-- ============================================
-- 2. TIMETABLE_IMAGES TABLE
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON timetable_images TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON timetable_images TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE timetable_images_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE timetable_images_id_seq TO authenticated;

-- ============================================
-- 3. OTHER ESSENTIAL TABLES (Preventive Fix)
-- ============================================
-- Grant permissions to all tables that might need them

-- Exams table
GRANT SELECT, INSERT, UPDATE, DELETE ON exams TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON exams TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE exams_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE exams_id_seq TO authenticated;

-- Class members table
GRANT SELECT, INSERT, UPDATE, DELETE ON class_members TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON class_members TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE class_members_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE class_members_id_seq TO authenticated;

-- Homework submissions table
GRANT SELECT, INSERT, UPDATE, DELETE ON homework_submissions TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON homework_submissions TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE homework_submissions_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE homework_submissions_id_seq TO authenticated;

-- Issue escalations table
GRANT SELECT, INSERT, UPDATE, DELETE ON issue_escalations TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON issue_escalations TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE issue_escalations_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE issue_escalations_id_seq TO authenticated;

-- CCA calendar table
GRANT SELECT, INSERT, UPDATE, DELETE ON cca_calendar TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON cca_calendar TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE cca_calendar_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE cca_calendar_id_seq TO authenticated;

-- Student promotions table
GRANT SELECT, INSERT, UPDATE, DELETE ON student_promotions TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON student_promotions TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE student_promotions_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE student_promotions_id_seq TO authenticated;

-- Teacher ratings table
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_ratings TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_ratings TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE teacher_ratings_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE teacher_ratings_id_seq TO authenticated;

-- Marks workflow table
GRANT SELECT, INSERT, UPDATE, DELETE ON marks_workflow TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON marks_workflow TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE marks_workflow_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE marks_workflow_id_seq TO authenticated;

-- ============================================
-- VERIFICATION
-- ============================================
-- Verify grants were applied
SELECT
    table_name,
    grantee,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_name IN (
    'notifications',
    'timetable_images',
    'exams',
    'class_members',
    'homework_submissions',
    'issue_escalations',
    'cca_calendar',
    'student_promotions',
    'teacher_ratings',
    'marks_workflow'
)
AND grantee IN ('anon', 'authenticated')
ORDER BY table_name, grantee;
