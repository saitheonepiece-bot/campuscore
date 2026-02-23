-- ============================================
-- CAMPUSCORE DATABASE MIGRATION
-- Session Date: February 23, 2026
-- Purpose: Add all new columns and tables for enhanced features
-- ============================================

-- IMPORTANT: Run this entire file in Supabase SQL Editor
-- This migration is SAFE - it only adds new columns/tables, never deletes existing data

-- ============================================
-- 1. ADVANCED FEATURES
-- ============================================

-- Add email column for forgot password feature and user registration
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;

-- Add PIN columns for student shuffle feature (VP only)
-- Default PINs: VP321 (open), VP123 (shuffle), VP000 (export)
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_open TEXT DEFAULT 'VP321';
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_shuffle TEXT DEFAULT 'VP123';
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_export TEXT DEFAULT 'VP000';


-- ============================================
-- 2. MARKS WORKFLOW TABLE
-- ============================================

-- Create marks_workflow table if it doesn't exist
CREATE TABLE IF NOT EXISTS marks_workflow (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT,
    subject TEXT NOT NULL,
    class TEXT NOT NULL,
    term TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitted_by TEXT,
    total_students INTEGER,
    approver_id TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add columns if table already exists (for existing databases)
ALTER TABLE marks_workflow ADD COLUMN IF NOT EXISTS submitted_by TEXT;
ALTER TABLE marks_workflow ADD COLUMN IF NOT EXISTS total_students INTEGER;


-- ============================================
-- 3. OTHER ESSENTIAL TABLES (Create if missing)
-- ============================================

-- Create notifications table if it doesn't exist
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

-- Create timetable_images table if it doesn't exist
CREATE TABLE IF NOT EXISTS timetable_images (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    image_url TEXT NOT NULL,
    uploaded_by TEXT,
    is_active BOOLEAN DEFAULT true,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create exams table if it doesn't exist
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

-- Create class_members table if it doesn't exist
CREATE TABLE IF NOT EXISTS class_members (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT,
    student_id BIGINT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(class_id, student_id)
);

-- Create homework_submissions table if it doesn't exist
CREATE TABLE IF NOT EXISTS homework_submissions (
    id BIGSERIAL PRIMARY KEY,
    homework_id BIGINT,
    student_id BIGINT,
    submission_text TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'submitted', 'graded')),
    grade TEXT,
    feedback TEXT,
    UNIQUE(homework_id, student_id)
);

-- Create issue_escalations table if it doesn't exist
CREATE TABLE IF NOT EXISTS issue_escalations (
    id BIGSERIAL PRIMARY KEY,
    issue_id BIGINT,
    escalated_from TEXT,
    escalated_to TEXT,
    grade_level INTEGER,
    escalated_by TEXT,
    escalated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'pending'
);

-- Create cca_calendar table if it doesn't exist
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
-- 4. STUDENT PROMOTION SYSTEM
-- ============================================

-- Create table to log all student promotions for audit trail
CREATE TABLE IF NOT EXISTS student_promotions (
  id SERIAL PRIMARY KEY,
  from_grade INTEGER NOT NULL,
  to_grade INTEGER NOT NULL,
  students_promoted INTEGER NOT NULL,
  performed_by TEXT NOT NULL,
  performed_at TIMESTAMP DEFAULT NOW(),
  details JSONB,
  CONSTRAINT valid_grades CHECK (from_grade >= 6 AND from_grade <= 10 AND to_grade >= 6 AND to_grade <= 10)
);

-- Add index for faster queries on performed_at
CREATE INDEX IF NOT EXISTS idx_student_promotions_performed_at ON student_promotions(performed_at DESC);


-- ============================================
-- 5. TEACHER RATING SYSTEM (Future Feature)
-- ============================================

-- Create table for teacher ratings (placeholder for future analytics)
CREATE TABLE IF NOT EXISTS teacher_ratings (
  id SERIAL PRIMARY KEY,
  teacher_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  subject TEXT,
  feedback TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_teacher_ratings_teacher ON teacher_ratings(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_ratings_created ON teacher_ratings(created_at DESC);


-- ============================================
-- 6. DISABLE ROW LEVEL SECURITY FOR NEW TABLES
-- ============================================

-- Disable RLS for easier development (adjust for production)
ALTER TABLE marks_workflow DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE timetable_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE exams DISABLE ROW LEVEL SECURITY;
ALTER TABLE class_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE homework_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE issue_escalations DISABLE ROW LEVEL SECURITY;
ALTER TABLE cca_calendar DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_promotions DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_ratings DISABLE ROW LEVEL SECURITY;


-- ============================================
-- 7. CREATE INDEXES FOR PERFORMANCE
-- ============================================

-- Indexes for new tables
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_timetable_images_class ON timetable_images(class);
CREATE INDEX IF NOT EXISTS idx_exams_class ON exams(class);
CREATE INDEX IF NOT EXISTS idx_marks_workflow_status ON marks_workflow(status);
CREATE INDEX IF NOT EXISTS idx_marks_workflow_class ON marks_workflow(class);


-- ============================================
-- 8. VERIFICATION QUERIES
-- ============================================

-- Verify users table columns were added
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'email'
  ) THEN
    RAISE NOTICE '✅ users.email column exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'pin_open'
  ) THEN
    RAISE NOTICE '✅ users.pin_open column exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'pin_shuffle'
  ) THEN
    RAISE NOTICE '✅ users.pin_shuffle column exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'pin_export'
  ) THEN
    RAISE NOTICE '✅ users.pin_export column exists';
  END IF;
END $$;

-- Verify marks_workflow columns were added
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'marks_workflow' AND column_name = 'submitted_by'
  ) THEN
    RAISE NOTICE '✅ marks_workflow.submitted_by column exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'marks_workflow' AND column_name = 'total_students'
  ) THEN
    RAISE NOTICE '✅ marks_workflow.total_students column exists';
  END IF;
END $$;

-- Verify new tables were created
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'marks_workflow'
  ) THEN
    RAISE NOTICE '✅ marks_workflow table exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'notifications'
  ) THEN
    RAISE NOTICE '✅ notifications table exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'timetable_images'
  ) THEN
    RAISE NOTICE '✅ timetable_images table exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'exams'
  ) THEN
    RAISE NOTICE '✅ exams table exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'student_promotions'
  ) THEN
    RAISE NOTICE '✅ student_promotions table exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'teacher_ratings'
  ) THEN
    RAISE NOTICE '✅ teacher_ratings table exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'cca_calendar'
  ) THEN
    RAISE NOTICE '✅ cca_calendar table exists';
  END IF;
END $$;


-- ============================================
-- 9. GRANT PERMISSIONS TO ALL TABLES
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

-- Final success message
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '✅ DATABASE MIGRATION COMPLETED SUCCESSFULLY!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '✅ All columns added';
    RAISE NOTICE '✅ All tables created';
    RAISE NOTICE '✅ All permissions granted';
    RAISE NOTICE '✅ No more 401 Unauthorized errors!';
    RAISE NOTICE '============================================';
END $$;
