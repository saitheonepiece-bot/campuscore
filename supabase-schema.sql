-- CampusCore Database Schema for Supabase
-- Run this SQL in your Supabase SQL Editor to create all tables

-- ============================================
-- Users Table
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('parent', 'teacher', 'coordinator', 'viceprincipal', 'superviceprincipal', 'classteacher')),
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
    periods JSONB NOT NULL,
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
CREATE TABLE IF NOT EXISTS cca_calendars (
    id BIGSERIAL PRIMARY KEY,
    event_name TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_time TEXT,
    location TEXT,
    description TEXT,
    created_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
ALTER TABLE cca_calendars DISABLE ROW LEVEL SECURITY;

-- Schema creation complete!
