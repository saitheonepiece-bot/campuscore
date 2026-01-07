-- ============================================
-- CampusCore Report Card System Migration
-- Run this in Supabase SQL Editor
-- ============================================

-- STEP 1: Drop existing conflicting tables (if needed)
-- WARNING: This will delete existing data in these tables
-- Only run if you're sure or take backup first

-- DROP TABLE IF EXISTS marks_submissions CASCADE;
-- DROP TABLE IF EXISTS report_cards CASCADE;

-- ============================================
-- STEP 2: Create marks_entries table
-- ============================================

CREATE TABLE IF NOT EXISTS marks_entries (
    id BIGSERIAL PRIMARY KEY,

    -- Student and exam details
    student_id BIGINT REFERENCES students(id) NOT NULL,
    subject TEXT NOT NULL,
    exam_name TEXT NOT NULL,
    exam_type TEXT NOT NULL CHECK (exam_type IN ('unit_test', 'mid_term', 'final', 'quarterly', 'half_yearly', 'annual')),

    -- Marks data
    marks_obtained NUMERIC NOT NULL CHECK (marks_obtained >= 0),
    max_marks NUMERIC NOT NULL CHECK (max_marks > 0),
    percentage NUMERIC GENERATED ALWAYS AS ((marks_obtained / max_marks) * 100) STORED,

    -- Teacher who entered
    teacher_id TEXT NOT NULL,

    -- Status management
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'locked')),
    is_finalized BOOLEAN DEFAULT false,

    -- Audit fields
    submitted_at TIMESTAMP WITH TIME ZONE,
    submitted_by TEXT,
    locked_at TIMESTAMP WITH TIME ZONE,
    locked_by TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicate entries
    UNIQUE(student_id, subject, exam_name, exam_type)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_marks_entries_student ON marks_entries(student_id);
CREATE INDEX IF NOT EXISTS idx_marks_entries_teacher ON marks_entries(teacher_id);
CREATE INDEX IF NOT EXISTS idx_marks_entries_status ON marks_entries(status);
CREATE INDEX IF NOT EXISTS idx_marks_entries_exam ON marks_entries(exam_name, exam_type);

-- ============================================
-- STEP 3: Recreate report_cards table
-- ============================================

DROP TABLE IF EXISTS report_cards CASCADE;

CREATE TABLE report_cards (
    id BIGSERIAL PRIMARY KEY,

    -- Student details
    student_id BIGINT REFERENCES students(id) NOT NULL,

    -- Academic details
    academic_year TEXT NOT NULL,
    term TEXT NOT NULL,
    class TEXT NOT NULL,

    -- Performance data (stored as JSON)
    subjects_data JSONB NOT NULL,

    -- Calculated aggregates
    total_marks_obtained NUMERIC NOT NULL,
    total_max_marks NUMERIC NOT NULL,
    overall_percentage NUMERIC NOT NULL,
    overall_grade TEXT NOT NULL,
    pass_fail_status TEXT NOT NULL CHECK (pass_fail_status IN ('PASS', 'FAIL')),

    -- PDF storage (base64 encoded)
    pdf_base64 TEXT,
    pdf_generated BOOLEAN DEFAULT false,

    -- Locking mechanism (CRITICAL for "cannot be undone")
    is_locked BOOLEAN DEFAULT false NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE,
    locked_by TEXT,

    -- Remarks
    class_teacher_remarks TEXT,
    principal_remarks TEXT,

    -- Audit
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    generated_by TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicate reports
    UNIQUE(student_id, academic_year, term)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_report_cards_student ON report_cards(student_id);
CREATE INDEX IF NOT EXISTS idx_report_cards_locked ON report_cards(is_locked);
CREATE INDEX IF NOT EXISTS idx_report_cards_term ON report_cards(academic_year, term);
CREATE INDEX IF NOT EXISTS idx_report_cards_class ON report_cards(class);

-- ============================================
-- STEP 4: Create audit_logs table
-- ============================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,

    -- Action details
    action_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id BIGINT NOT NULL,

    -- User details
    user_id TEXT NOT NULL,
    user_role TEXT NOT NULL,
    user_name TEXT,

    -- Data snapshots
    old_data JSONB,
    new_data JSONB,

    -- Context
    description TEXT,
    ip_address TEXT,
    user_agent TEXT,

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);

-- ============================================
-- STEP 5: Create report_card_config table
-- ============================================

CREATE TABLE IF NOT EXISTS report_card_config (
    id BIGSERIAL PRIMARY KEY,

    -- Grading configuration
    grade_system JSONB NOT NULL,
    passing_percentage NUMERIC DEFAULT 40,

    -- Class-specific configuration
    class TEXT NOT NULL UNIQUE,
    required_subjects JSONB NOT NULL,

    -- Active configuration
    is_active BOOLEAN DEFAULT true,
    academic_year TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- STEP 6: Insert default grading system
-- ============================================

INSERT INTO report_card_config (class, grade_system, passing_percentage, required_subjects, academic_year)
VALUES
('8B', '[
    {"min": 95, "max": 100, "grade": "A+", "description": "Outstanding"},
    {"min": 90, "max": 94.99, "grade": "A", "description": "Excellent"},
    {"min": 85, "max": 89.99, "grade": "A-", "description": "Very Good"},
    {"min": 80, "max": 84.99, "grade": "B+", "description": "Good"},
    {"min": 75, "max": 79.99, "grade": "B", "description": "Above Average"},
    {"min": 70, "max": 74.99, "grade": "B-", "description": "Average"},
    {"min": 65, "max": 69.99, "grade": "C+", "description": "Satisfactory"},
    {"min": 60, "max": 64.99, "grade": "C", "description": "Acceptable"},
    {"min": 40, "max": 59.99, "grade": "D", "description": "Needs Improvement"},
    {"min": 0, "max": 39.99, "grade": "F", "description": "Fail"}
]'::jsonb, 40, '["Mathematics", "English", "Science", "Social Studies", "Hindi"]'::jsonb, '2024-2025'),

('10A', '[
    {"min": 95, "max": 100, "grade": "A+", "description": "Outstanding"},
    {"min": 90, "max": 94.99, "grade": "A", "description": "Excellent"},
    {"min": 85, "max": 89.99, "grade": "A-", "description": "Very Good"},
    {"min": 80, "max": 84.99, "grade": "B+", "description": "Good"},
    {"min": 75, "max": 79.99, "grade": "B", "description": "Above Average"},
    {"min": 70, "max": 74.99, "grade": "B-", "description": "Average"},
    {"min": 65, "max": 69.99, "grade": "C+", "description": "Satisfactory"},
    {"min": 60, "max": 64.99, "grade": "C", "description": "Acceptable"},
    {"min": 40, "max": 59.99, "grade": "D", "description": "Needs Improvement"},
    {"min": 0, "max": 39.99, "grade": "F", "description": "Fail"}
]'::jsonb, 40, '["Mathematics", "English", "Physics", "Chemistry", "Biology", "Social Studies"]'::jsonb, '2024-2025')
ON CONFLICT (class) DO NOTHING;

-- ============================================
-- STEP 7: Create security functions
-- ============================================

-- Function to prevent unlocking without admin privileges
CREATE OR REPLACE FUNCTION prevent_report_card_unlock()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if trying to unlock a locked report card
    IF OLD.is_locked = true AND NEW.is_locked = false THEN
        RAISE EXCEPTION 'Report cards cannot be unlocked once locked. Contact administrator for assistance.';
    END IF;

    -- Prevent modification of locked report cards
    IF OLD.is_locked = true THEN
        -- Only allow remarks to be added
        IF NEW.class_teacher_remarks IS DISTINCT FROM OLD.class_teacher_remarks OR
           NEW.principal_remarks IS DISTINCT FROM OLD.principal_remarks THEN
            RETURN NEW;
        END IF;

        RAISE EXCEPTION 'Locked report cards cannot be modified. This action is permanent.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to report_cards
DROP TRIGGER IF EXISTS enforce_report_card_lock ON report_cards;
CREATE TRIGGER enforce_report_card_lock
    BEFORE UPDATE ON report_cards
    FOR EACH ROW
    EXECUTE FUNCTION prevent_report_card_unlock();

-- Function to prevent editing locked marks
CREATE OR REPLACE FUNCTION prevent_locked_marks_edit()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if marks are locked
    IF OLD.status = 'locked' AND OLD.is_finalized = true THEN
        RAISE EXCEPTION 'Locked marks cannot be edited. Contact administrator for corrections.';
    END IF;

    -- Prevent changing submitted marks to draft
    IF OLD.status = 'submitted' AND NEW.status = 'draft' THEN
        RAISE EXCEPTION 'Submitted marks cannot be reverted to draft.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to marks_entries
DROP TRIGGER IF EXISTS enforce_marks_lock ON marks_entries;
CREATE TRIGGER enforce_marks_lock
    BEFORE UPDATE ON marks_entries
    FOR EACH ROW
    EXECUTE FUNCTION prevent_locked_marks_edit();

-- ============================================
-- STEP 8: Create helper functions
-- ============================================

-- Function to get student's marks completion status
CREATE OR REPLACE FUNCTION get_student_marks_status(
    p_student_id BIGINT,
    p_exam_name TEXT,
    p_exam_type TEXT
)
RETURNS TABLE(
    subject TEXT,
    has_marks BOOLEAN,
    marks_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rs.subject,
        me.id IS NOT NULL as has_marks,
        COALESCE(me.status, 'missing') as marks_status
    FROM
        unnest((
            SELECT required_subjects::text[]
            FROM report_card_config rc
            JOIN students s ON s.class = rc.class
            WHERE s.id = p_student_id
            LIMIT 1
        )) as rs(subject)
    LEFT JOIN marks_entries me ON
        me.student_id = p_student_id
        AND me.subject = rs.subject
        AND me.exam_name = p_exam_name
        AND me.exam_type = p_exam_type;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STEP 9: Disable RLS (for development)
-- ============================================

ALTER TABLE marks_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE report_cards DISABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE report_card_config DISABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 10: Grant permissions
-- ============================================

GRANT ALL ON marks_entries TO anon;
GRANT ALL ON marks_entries TO authenticated;

GRANT ALL ON report_cards TO anon;
GRANT ALL ON report_cards TO authenticated;

GRANT ALL ON audit_logs TO anon;
GRANT ALL ON audit_logs TO authenticated;

GRANT ALL ON report_card_config TO anon;
GRANT ALL ON report_card_config TO authenticated;

-- Grant sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================
-- STEP 11: Verification queries
-- ============================================

-- Verify tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('marks_entries', 'report_cards', 'audit_logs', 'report_card_config');

-- Verify grading config inserted
SELECT class, academic_year, passing_percentage
FROM report_card_config;

-- ============================================
-- Migration Complete!
-- ============================================

-- Next steps:
-- 1. Verify all tables created successfully
-- 2. Check that triggers are active
-- 3. Test inserting sample marks
-- 4. Implement frontend UI for marks entry
-- 5. Implement report card generation logic
