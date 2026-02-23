-- CampusCore Database Schema for Supabase
-- Run this SQL in your Supabase SQL Editor to create all tables
-- Last Updated: February 23, 2026

-- ============================================
-- Users Table
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('parent', 'teacher', 'coordinator', 'viceprincipal', 'superviceprincipal', 'classteacher', 'student', 'hassan')),
    email TEXT,                                    -- Added: For forgot password feature
    pin_open TEXT DEFAULT 'VP321',                 -- Added: PIN to access shuffle page (VP only)
    pin_shuffle TEXT DEFAULT 'VP123',              -- Added: PIN to execute shuffle (VP only)
    pin_export TEXT DEFAULT 'VP000',               -- Added: PIN to export PDF (VP only)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Students Table
-- ============================================
CREATE TABLE IF NOT EXISTS students (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    class TEXT NOT NULL,
    parent_id TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'removed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Parents Table
-- ============================================
CREATE TABLE IF NOT EXISTS parents (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    student_id BIGINT REFERENCES students(id),
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Teachers Table
-- ============================================
CREATE TABLE IF NOT EXISTS teachers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    subjects TEXT,
    classes TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Class Teachers Table
-- ============================================
CREATE TABLE IF NOT EXISTS class_teachers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    class TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Coordinators Table
-- ============================================
CREATE TABLE IF NOT EXISTS coordinators (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    department TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Vice Principals Table
-- ============================================
CREATE TABLE IF NOT EXISTS vice_principals (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    school TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Super Vice Principals Table
-- ============================================
CREATE TABLE IF NOT EXISTS super_vice_principals (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    school TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Attendance Table
-- ============================================
CREATE TABLE IF NOT EXISTS attendance (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    date DATE NOT NULL,
    period TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('present', 'absent', 'late')),
    behavior TEXT DEFAULT 'good' CHECK (behavior IN ('good', 'excellent', 'distracting')),
    marked_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, date, period)
);

-- ============================================
-- Homework Table
-- ============================================
CREATE TABLE IF NOT EXISTS homework (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    subject TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    due_date DATE,
    assigned_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Exam Schedules Table
-- ============================================
CREATE TABLE IF NOT EXISTS exam_schedules (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    subject TEXT NOT NULL,
    exam_name TEXT NOT NULL,
    date DATE NOT NULL,
    time TEXT,
    duration TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Exam Results Table
-- ============================================
CREATE TABLE IF NOT EXISTS exam_results (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    exam_name TEXT NOT NULL,
    subject TEXT NOT NULL,
    marks NUMERIC,
    total_marks NUMERIC,
    grade TEXT,
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Report Cards Table
-- ============================================
CREATE TABLE IF NOT EXISTS report_cards (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    term TEXT NOT NULL,
    academic_year TEXT NOT NULL,
    overall_percentage NUMERIC,
    overall_grade TEXT,
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Timetables Table
-- ============================================
CREATE TABLE IF NOT EXISTS timetables (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL UNIQUE,
    periods JSONB,
    image_data TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Teacher Timetables Table
-- ============================================
CREATE TABLE IF NOT EXISTS teacher_timetables (
    id BIGSERIAL PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    periods JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Issues Table
-- ============================================
CREATE TABLE IF NOT EXISTS issues (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    reported_by TEXT,
    student_id BIGINT,
    student_name TEXT,
    class TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved', 'escalated')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'critical')),
    assigned_to TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Holidays Table
-- ============================================
CREATE TABLE IF NOT EXISTS holidays (
    id BIGSERIAL PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Classes Table
-- ============================================
CREATE TABLE IF NOT EXISTS classes (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    grade INT NOT NULL,
    section TEXT NOT NULL,
    class_teacher_id TEXT,
    total_students INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Teacher Duties Table
-- ============================================
CREATE TABLE IF NOT EXISTS teacher_duties (
    id BIGSERIAL PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    duty_name TEXT NOT NULL,
    duty_date DATE,
    duty_time TEXT,
    location TEXT,
    assigned_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Teacher Appointments Table
-- ============================================
CREATE TABLE IF NOT EXISTS teacher_appointments (
    id BIGSERIAL PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    appointment_date DATE NOT NULL,
    subject TEXT,
    classes TEXT,
    status TEXT DEFAULT 'active',
    appointed_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Marks Submissions Table
-- ============================================
CREATE TABLE IF NOT EXISTS marks_submissions (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    subject TEXT NOT NULL,
    exam_name TEXT NOT NULL,
    marks NUMERIC,
    total_marks NUMERIC,
    submitted_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Student Documents Table
-- ============================================
CREATE TABLE IF NOT EXISTS student_documents (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    document_type TEXT NOT NULL,
    document_name TEXT NOT NULL,
    document_url TEXT,
    uploaded_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- CCA Calendar Table
-- ============================================
CREATE TABLE IF NOT EXISTS cca_calendar (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    description TEXT,
    event_date DATE,
    file_url TEXT,
    image_data TEXT,
    uploaded_by TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Timetable Images Table (Coordinator Uploads)
-- ============================================
CREATE TABLE IF NOT EXISTS timetable_images (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    image_url TEXT NOT NULL,
    uploaded_by TEXT,
    is_active BOOLEAN DEFAULT true,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Exams Table
-- ============================================
CREATE TABLE IF NOT EXISTS exams (
    id BIGSERIAL PRIMARY KEY,
    exam_name TEXT NOT NULL,
    subject TEXT NOT NULL,
    class TEXT NOT NULL,
    date DATE,
    max_marks NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Class Members Table
-- ============================================
CREATE TABLE IF NOT EXISTS class_members (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT REFERENCES classes(id),
    student_id BIGINT REFERENCES students(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(class_id, student_id)
);

-- ============================================
-- Homework Submissions Table
-- ============================================
CREATE TABLE IF NOT EXISTS homework_submissions (
    id BIGSERIAL PRIMARY KEY,
    homework_id BIGINT REFERENCES homework(id),
    student_id BIGINT REFERENCES students(id),
    submission_text TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'submitted', 'graded')),
    grade TEXT,
    feedback TEXT,
    UNIQUE(homework_id, student_id)
);

-- ============================================
-- Issue Escalations Table
-- ============================================
CREATE TABLE IF NOT EXISTS issue_escalations (
    id BIGSERIAL PRIMARY KEY,
    issue_id BIGINT REFERENCES issues(id),
    escalated_from TEXT,
    escalated_to TEXT,
    grade_level INTEGER,
    escalated_by TEXT,
    escalated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'pending'
);

-- ============================================
-- Marks Workflow Table
-- ============================================
CREATE TABLE IF NOT EXISTS marks_workflow (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT,
    subject TEXT NOT NULL,
    class TEXT NOT NULL,
    term TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitted_by TEXT,                             -- Added: Track who submitted marks
    total_students INTEGER,                        -- Added: Track student count
    approver_id TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Notifications Table
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
    icon TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Student Promotions Table
-- ============================================
CREATE TABLE IF NOT EXISTS student_promotions (
    id BIGSERIAL PRIMARY KEY,
    from_grade INTEGER NOT NULL,
    to_grade INTEGER NOT NULL,
    students_promoted INTEGER NOT NULL,
    performed_by TEXT NOT NULL,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    details JSONB,
    CONSTRAINT valid_grades CHECK (from_grade >= 6 AND from_grade <= 10 AND to_grade >= 6 AND to_grade <= 10)
);

-- ============================================
-- Teacher Ratings Table (Future Feature)
-- ============================================
CREATE TABLE IF NOT EXISTS teacher_ratings (
    id BIGSERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    subject TEXT,
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Create Indexes for Performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_students_class ON students(class);
CREATE INDEX IF NOT EXISTS idx_students_parent_id ON students(parent_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_homework_class ON homework(class);
CREATE INDEX IF NOT EXISTS idx_exam_schedules_class ON exam_schedules(class);
CREATE INDEX IF NOT EXISTS idx_exam_results_student_id ON exam_results(student_id);
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_teacher_duties_teacher_id ON teacher_duties(teacher_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_student_promotions_performed_at ON student_promotions(performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_teacher_ratings_teacher ON teacher_ratings(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_ratings_created ON teacher_ratings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_timetable_images_class ON timetable_images(class);
CREATE INDEX IF NOT EXISTS idx_exams_class ON exams(class);

-- ============================================
-- Enable Row Level Security (RLS)
-- ============================================
-- Note: For this educational project, we'll keep RLS simple
-- In production, you should implement proper RLS policies

-- For now, disable RLS to make it easier to work with
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE students DISABLE ROW LEVEL SECURITY;
ALTER TABLE parents DISABLE ROW LEVEL SECURITY;
ALTER TABLE teachers DISABLE ROW LEVEL SECURITY;
ALTER TABLE class_teachers DISABLE ROW LEVEL SECURITY;
ALTER TABLE coordinators DISABLE ROW LEVEL SECURITY;
ALTER TABLE vice_principals DISABLE ROW LEVEL SECURITY;
ALTER TABLE super_vice_principals DISABLE ROW LEVEL SECURITY;
ALTER TABLE attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE homework DISABLE ROW LEVEL SECURITY;
ALTER TABLE exam_schedules DISABLE ROW LEVEL SECURITY;
ALTER TABLE exam_results DISABLE ROW LEVEL SECURITY;
ALTER TABLE report_cards DISABLE ROW LEVEL SECURITY;
ALTER TABLE timetables DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_timetables DISABLE ROW LEVEL SECURITY;
ALTER TABLE issues DISABLE ROW LEVEL SECURITY;
ALTER TABLE holidays DISABLE ROW LEVEL SECURITY;
ALTER TABLE classes DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_duties DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE marks_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_documents DISABLE ROW LEVEL SECURITY;
ALTER TABLE cca_calendar DISABLE ROW LEVEL SECURITY;
ALTER TABLE timetable_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE exams DISABLE ROW LEVEL SECURITY;
ALTER TABLE class_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE homework_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE issue_escalations DISABLE ROW LEVEL SECURITY;
ALTER TABLE marks_workflow DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_promotions DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_ratings DISABLE ROW LEVEL SECURITY;

-- ============================================
-- GRANT PERMISSIONS TO ALL TABLES
-- ============================================
-- Fix 401 Unauthorized errors by granting permissions to anon and authenticated roles

-- Core tables
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON students TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON parents TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON teachers TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON class_teachers TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON coordinators TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON vice_principals TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON super_vice_principals TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON attendance TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON homework TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON exam_schedules TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON exam_results TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON report_cards TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON timetables TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_timetables TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON issues TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON holidays TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON classes TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_duties TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_appointments TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON marks_submissions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON student_documents TO anon, authenticated;

-- New tables from migration
GRANT SELECT, INSERT, UPDATE, DELETE ON notifications TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON timetable_images TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON exams TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON class_members TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON homework_submissions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON issue_escalations TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON cca_calendar TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON student_promotions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_ratings TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON marks_workflow TO anon, authenticated;

-- Grant sequence permissions (for auto-increment IDs)
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE attendance_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE homework_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE exam_schedules_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE exam_results_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE report_cards_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE timetables_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE teacher_timetables_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE issues_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE holidays_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE classes_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE teacher_duties_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE teacher_appointments_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE marks_submissions_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE student_documents_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE notifications_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE timetable_images_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE exams_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE class_members_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE homework_submissions_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE issue_escalations_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE cca_calendar_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE student_promotions_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE teacher_ratings_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE marks_workflow_id_seq TO anon, authenticated;

-- ============================================
-- Schema creation complete!
-- Last Updated: February 23, 2026
-- ============================================
-- This schema includes all tables needed for CampusCore dashboard
-- All permissions have been granted to prevent 401 Unauthorized errors
-- Run DATABASE-MIGRATION.sql to add new columns to existing database
