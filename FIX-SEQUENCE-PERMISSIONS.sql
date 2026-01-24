-- ============================================
-- FIX: SEQUENCE PERMISSION ERRORS
-- ============================================
-- Fixes "permission denied for sequence" errors
-- Run this in Supabase SQL Editor
-- ============================================

-- Grant usage on all sequences to authenticated and anon roles
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- Specifically fix teacher_duties sequence
GRANT USAGE, SELECT ON SEQUENCE teacher_duties_id_seq TO anon, authenticated, service_role;

-- Fix other common sequences
GRANT USAGE, SELECT ON SEQUENCE students_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE classes_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE attendance_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE homework_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE parents_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE teachers_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE exam_schedules_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE exam_results_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE report_cards_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE issues_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE holidays_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE teacher_appointments_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE marks_submissions_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE student_documents_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE cca_calendars_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE timetables_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE teacher_timetables_id_seq TO anon, authenticated, service_role;

-- Grant permissions for new feature sequences (if they exist)
GRANT USAGE, SELECT ON SEQUENCE pre_classes_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE class_members_id_seq TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE homework_submissions_id_seq TO anon, authenticated, service_role;

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
