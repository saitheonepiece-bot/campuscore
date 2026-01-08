-- ============================================
-- DISABLE ROW LEVEL SECURITY (RLS) ON ALL TABLES
-- ============================================
-- Run this SQL in your Supabase SQL Editor to fix login and data display issues
-- This is required for the application to work properly

-- Core Tables
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE students DISABLE ROW LEVEL SECURITY;
ALTER TABLE parents DISABLE ROW LEVEL SECURITY;
ALTER TABLE teachers DISABLE ROW LEVEL SECURITY;
ALTER TABLE classes DISABLE ROW LEVEL SECURITY;

-- Staff Tables
ALTER TABLE class_teachers DISABLE ROW LEVEL SECURITY;
ALTER TABLE coordinators DISABLE ROW LEVEL SECURITY;
ALTER TABLE vice_principals DISABLE ROW LEVEL SECURITY;
ALTER TABLE super_vice_principals DISABLE ROW LEVEL SECURITY;

-- Academic Tables
ALTER TABLE attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE homework DISABLE ROW LEVEL SECURITY;
ALTER TABLE exam_results DISABLE ROW LEVEL SECURITY;
ALTER TABLE exam_schedules DISABLE ROW LEVEL SECURITY;
ALTER TABLE report_cards DISABLE ROW LEVEL SECURITY;

-- Schedule Tables
ALTER TABLE timetables DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_timetables DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_duties DISABLE ROW LEVEL SECURITY;
ALTER TABLE holidays DISABLE ROW LEVEL SECURITY;
ALTER TABLE cca_calendars DISABLE ROW LEVEL SECURITY;

-- Other Tables
ALTER TABLE issues DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_appointments DISABLE ROW LEVEL SECURITY;

-- Success message
SELECT 'Row Level Security has been disabled on all tables!' as message;
