-- ============================================
-- CRITICAL BUG FIXES MIGRATION
-- Date: 2026-02-21
-- Fixes missing columns and schema issues
-- ============================================

-- Fix 1: Add status column to parents table
ALTER TABLE parents ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive'));

-- Fix 2: Add email column to parents table (for forgot password)
ALTER TABLE parents ADD COLUMN IF NOT EXISTS email TEXT;

-- Fix 3: Add email column to teachers table (for forgot password)
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS email TEXT;

-- Fix 4: Add email column to users table (for forgot password)
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;

-- Fix 5: Add date_of_birth column to students table (for Excel upload)
ALTER TABLE students ADD COLUMN IF NOT EXISTS date_of_birth DATE;

-- Fix 6: Create notifications table for real notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    user_role TEXT NOT NULL,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    link TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fix 7: Create issue_escalations table for workflow
CREATE TABLE IF NOT EXISTS issue_escalations (
    id BIGSERIAL PRIMARY KEY,
    issue_id BIGINT,
    reported_by TEXT NOT NULL,
    reported_by_role TEXT NOT NULL,
    current_handler TEXT,
    current_handler_role TEXT,
    grade INT,
    class TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved', 'escalated')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    resolution TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Fix 8: Create marks_workflow table for marks approval
CREATE TABLE IF NOT EXISTS marks_workflow (
    id BIGSERIAL PRIMARY KEY,
    exam_result_id BIGINT,
    teacher_id TEXT NOT NULL,
    student_id BIGINT NOT NULL,
    class TEXT NOT NULL,
    subject TEXT NOT NULL,
    marks DECIMAL(5,2),
    max_marks DECIMAL(5,2),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_by TEXT,
    approved_by_role TEXT,
    rejection_reason TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Fix 9: Create timetable_images table for image uploads
CREATE TABLE IF NOT EXISTS timetable_images (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    image_url TEXT NOT NULL,
    uploaded_by TEXT NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Fix 10: Create cca_calendar table for CCA calendar
CREATE TABLE IF NOT EXISTS cca_calendar (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_time TIME,
    location TEXT,
    grades TEXT[], -- Array of grades like {6,7,8}
    file_url TEXT,
    uploaded_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Fix 11: Create vp_pins table for shuffling feature
CREATE TABLE IF NOT EXISTS vp_pins (
    id SERIAL PRIMARY KEY,
    pin_type TEXT UNIQUE NOT NULL CHECK (pin_type IN ('open_shuffle', 'reshuffle', 'export_pdf')),
    pin_value TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by TEXT
);

-- Insert default PINs
INSERT INTO vp_pins (pin_type, pin_value, updated_by)
VALUES
    ('open_shuffle', 'VP321', 'system'),
    ('reshuffle', 'VP123', 'system'),
    ('export_pdf', 'VP000', 'system')
ON CONFLICT (pin_type) DO NOTHING;

-- Fix 12: Create password_reset_tokens table for forgot password
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    email TEXT NOT NULL,
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fix 13: Create teacher_ratings table if not exists
CREATE TABLE IF NOT EXISTS teacher_ratings (
    id BIGSERIAL PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    student_id BIGINT,
    parent_id TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fix 14: Add indices for performance
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_issue_escalations_status ON issue_escalations(status);
CREATE INDEX IF NOT EXISTS idx_issue_escalations_grade ON issue_escalations(grade);
CREATE INDEX IF NOT EXISTS idx_marks_workflow_status ON marks_workflow(status);
CREATE INDEX IF NOT EXISTS idx_marks_workflow_class ON marks_workflow(class);
CREATE INDEX IF NOT EXISTS idx_timetable_images_class ON timetable_images(class, is_active);
CREATE INDEX IF NOT EXISTS idx_cca_calendar_date ON cca_calendar(event_date);
CREATE INDEX IF NOT EXISTS idx_teacher_ratings_teacher ON teacher_ratings(teacher_id);

-- Fix 15: Update existing classes to have is_active if needed
UPDATE classes SET is_active = true WHERE is_active IS NULL;

-- Verify tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'notifications',
    'issue_escalations',
    'marks_workflow',
    'timetable_images',
    'cca_calendar',
    'vp_pins',
    'password_reset_tokens',
    'teacher_ratings'
)
ORDER BY table_name;

-- ============================================
-- MIGRATION COMPLETE
-- ============================================
