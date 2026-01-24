-- ============================================
-- FIX: ALL SEQUENCE PERMISSION ERRORS
-- ============================================
-- Fixes "permission denied for sequence" errors
-- This fixes homework, teacher_duties, and ALL other sequences
-- Run this in Supabase SQL Editor
-- ============================================

-- STEP 1: Grant usage on ALL sequences to all roles
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role, postgres;

-- STEP 2: Grant ALL privileges on ALL tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role, postgres;

-- STEP 3: Specifically fix each sequence individually
-- Homework sequence (FIXES YOUR ERROR)
GRANT ALL ON SEQUENCE homework_id_seq TO anon, authenticated, service_role, postgres;

-- Teacher duties sequence
GRANT ALL ON SEQUENCE teacher_duties_id_seq TO anon, authenticated, service_role, postgres;

-- Fix ALL other sequences
GRANT ALL ON SEQUENCE students_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE classes_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE attendance_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE parents_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE teachers_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE users_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE exam_schedules_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE exam_results_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE report_cards_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE issues_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE holidays_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE teacher_appointments_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE marks_submissions_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE student_documents_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE cca_calendars_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE timetables_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE teacher_timetables_id_seq TO anon, authenticated, service_role, postgres;

-- Grant permissions for new feature sequences (if they exist)
GRANT ALL ON SEQUENCE pre_classes_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE class_members_id_seq TO anon, authenticated, service_role, postgres;
GRANT ALL ON SEQUENCE homework_submissions_id_seq TO anon, authenticated, service_role, postgres;

-- Alternative: Set default privileges for future sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO anon, authenticated, service_role;

-- Verify sequences are accessible
SELECT
    sequence_schema,
    sequence_name
FROM information_schema.sequences
WHERE sequence_schema = 'public'
ORDER BY sequence_name;

-- ============================================
-- COMPLETE!
-- ============================================
-- The sequence permission error should now be fixed
-- Try assigning teacher duties again
