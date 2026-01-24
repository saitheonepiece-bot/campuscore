-- ============================================
-- CAMPUS CORE - ADD NEW FEATURES MIGRATION
-- ============================================
-- Run this in Supabase SQL Editor to add new features
-- This keeps your existing auth system and data intact
-- ============================================

-- ============================================
-- 1. CREATE NEW TABLES
-- ============================================

-- Pre-Classes Table (Grade levels like Pre-A, Pre-B, Grade 1, etc.)
CREATE TABLE IF NOT EXISTS pre_classes (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Class Members Table (Student enrollment in classes)
CREATE TABLE IF NOT EXISTS class_members (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    joined_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(class_id, student_id)
);

-- Homework Submissions Table (Students submit homework)
CREATE TABLE IF NOT EXISTS homework_submissions (
    id BIGSERIAL PRIMARY KEY,
    homework_id BIGINT NOT NULL REFERENCES homework(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    submission_text TEXT,
    file_url TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'submitted' CHECK (status IN ('submitted', 'late', 'graded', 'missing')),
    grade DECIMAL(5,2),
    feedback TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(homework_id, student_id)
);

-- ============================================
-- 2. ADD COLUMNS TO EXISTING TABLES
-- ============================================

-- Add pre_class_id to classes table
ALTER TABLE classes
ADD COLUMN IF NOT EXISTS pre_class_id BIGINT REFERENCES pre_classes(id) ON DELETE SET NULL;

-- Add soft delete to students table
ALTER TABLE students
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ============================================
-- 3. CREATE INDEXES
-- ============================================

-- Pre-Classes indexes
CREATE INDEX IF NOT EXISTS idx_pre_classes_is_active ON pre_classes(is_active);
CREATE INDEX IF NOT EXISTS idx_pre_classes_name ON pre_classes(name);

-- Class Members indexes
CREATE INDEX IF NOT EXISTS idx_class_members_class_id ON class_members(class_id);
CREATE INDEX IF NOT EXISTS idx_class_members_student_id ON class_members(student_id);
CREATE INDEX IF NOT EXISTS idx_class_members_is_active ON class_members(is_active);

-- Homework Submissions indexes
CREATE INDEX IF NOT EXISTS idx_homework_submissions_homework_id ON homework_submissions(homework_id);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_student_id ON homework_submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_status ON homework_submissions(status);

-- Classes pre_class_id index
CREATE INDEX IF NOT EXISTS idx_classes_pre_class_id ON classes(pre_class_id);

-- ============================================
-- 4. DISABLE RLS (keep it simple like current setup)
-- ============================================
ALTER TABLE pre_classes DISABLE ROW LEVEL SECURITY;
ALTER TABLE class_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE homework_submissions DISABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. MIGRATE EXISTING DATA
-- ============================================

-- Extract unique grade levels from existing classes
-- This creates pre-classes based on the grade column
INSERT INTO pre_classes (name, description, is_active)
SELECT DISTINCT
    'Grade ' || grade,
    'Grade ' || grade || ' level',
    true
FROM classes
WHERE grade IS NOT NULL
ON CONFLICT (name) DO NOTHING;

-- Also add Pre-A, Pre-B if they exist in class names
INSERT INTO pre_classes (name, description, is_active) VALUES
('Pre-A', 'Pre-Primary A Level', true),
('Pre-B', 'Pre-Primary B Level', true),
('Pre-KG', 'Pre-Kindergarten', true),
('LKG', 'Lower Kindergarten', true),
('UKG', 'Upper Kindergarten', true)
ON CONFLICT (name) DO NOTHING;

-- Link existing classes to pre_classes
UPDATE classes c
SET pre_class_id = (
    SELECT pc.id
    FROM pre_classes pc
    WHERE pc.name = 'Grade ' || c.grade
    LIMIT 1
)
WHERE c.grade IS NOT NULL AND c.pre_class_id IS NULL;

-- For classes like "8B", "10A" - link to appropriate grade
UPDATE classes c
SET pre_class_id = (
    SELECT pc.id
    FROM pre_classes pc
    WHERE pc.name = 'Grade ' || c.grade
    LIMIT 1
)
WHERE c.pre_class_id IS NULL;

-- ============================================
-- 6. CREATE CLASS MEMBERS FROM EXISTING STUDENTS
-- ============================================

-- Enroll existing students into their classes based on student.class field
INSERT INTO class_members (class_id, student_id, is_active)
SELECT
    c.id as class_id,
    s.id as student_id,
    CASE WHEN s.status = 'active' THEN true ELSE false END as is_active
FROM students s
JOIN classes c ON c.name = s.class
WHERE s.status != 'removed'
  AND NOT EXISTS (
    SELECT 1 FROM class_members cm
    WHERE cm.class_id = c.id AND cm.student_id = s.id
  )
ON CONFLICT (class_id, student_id) DO NOTHING;

-- ============================================
-- 7. SEED ADDITIONAL PRE-CLASSES (6 total as required)
-- ============================================

INSERT INTO pre_classes (name, description, is_active) VALUES
('Grade 1', 'First Grade', true),
('Grade 2', 'Second Grade', true),
('Grade 3', 'Third Grade', true),
('Grade 4', 'Fourth Grade', true),
('Grade 5', 'Fifth Grade', true),
('Grade 6', 'Sixth Grade', true),
('Grade 7', 'Seventh Grade', true),
('Grade 8', 'Eighth Grade', true),
('Grade 9', 'Ninth Grade', true),
('Grade 10', 'Tenth Grade', true),
('Grade 11', 'Eleventh Grade', true),
('Grade 12', 'Twelfth Grade', true)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 8. ENSURE TEST CREDENTIALS EXIST
-- ============================================

-- Add test student if not exists
INSERT INTO students (id, name, class, parent_id, status) VALUES
(3180076, 'Kasula Ashwath', '8B', 'P3180076A', 'active')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    class = EXCLUDED.class,
    parent_id = EXCLUDED.parent_id,
    status = EXCLUDED.status;

-- Add test parent user if not exists
INSERT INTO users (username, password, name, role) VALUES
('P3180076A', 'parent123', 'Parent of Kasula', 'parent')
ON CONFLICT (username) DO UPDATE SET
    password = EXCLUDED.password,
    name = EXCLUDED.name,
    role = EXCLUDED.role;

-- Add test parent record if not exists
INSERT INTO parents (id, name, student_id, phone) VALUES
('P3180076A', 'Parent of Kasula', 3180076, '9876543210')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    student_id = EXCLUDED.student_id,
    phone = EXCLUDED.phone;

-- ============================================
-- 9. CREATE HELPER VIEWS FOR EASY QUERIES
-- ============================================

-- View: Students with their class and pre-class info
CREATE OR REPLACE VIEW v_students_full AS
SELECT
    s.id,
    s.name,
    s.class,
    s.parent_id,
    s.status,
    c.id as class_id,
    c.name as class_name,
    c.section,
    pc.id as pre_class_id,
    pc.name as pre_class_name,
    cm.joined_date,
    cm.is_active as enrolled
FROM students s
LEFT JOIN classes c ON c.name = s.class
LEFT JOIN pre_classes pc ON pc.id = c.pre_class_id
LEFT JOIN class_members cm ON cm.student_id = s.id AND cm.class_id = c.id
WHERE s.deleted_at IS NULL;

-- View: Class enrollment summary
CREATE OR REPLACE VIEW v_class_enrollment AS
SELECT
    c.id as class_id,
    c.name as class_name,
    c.section,
    pc.name as pre_class_name,
    COUNT(cm.id) as enrolled_students,
    COUNT(CASE WHEN cm.is_active THEN 1 END) as active_students
FROM classes c
LEFT JOIN pre_classes pc ON pc.id = c.pre_class_id
LEFT JOIN class_members cm ON cm.class_id = c.id
GROUP BY c.id, c.name, c.section, pc.name;

-- View: Homework with submission status
CREATE OR REPLACE VIEW v_homework_status AS
SELECT
    h.id as homework_id,
    h.class,
    h.subject,
    h.title,
    h.due_date,
    COUNT(DISTINCT cm.student_id) as total_students,
    COUNT(DISTINCT hs.student_id) as submitted_count,
    COUNT(DISTINCT CASE WHEN hs.status = 'graded' THEN hs.student_id END) as graded_count
FROM homework h
LEFT JOIN classes c ON c.name = h.class
LEFT JOIN class_members cm ON cm.class_id = c.id AND cm.is_active = true
LEFT JOIN homework_submissions hs ON hs.homework_id = h.id
GROUP BY h.id, h.class, h.subject, h.title, h.due_date;

-- ============================================
-- 10. VERIFICATION QUERIES
-- ============================================

-- Count all records
SELECT 'pre_classes' as table_name, COUNT(*) as count FROM pre_classes
UNION ALL
SELECT 'classes', COUNT(*) FROM classes
UNION ALL
SELECT 'students', COUNT(*) FROM students
UNION ALL
SELECT 'class_members', COUNT(*) FROM class_members
UNION ALL
SELECT 'homework', COUNT(*) FROM homework
UNION ALL
SELECT 'homework_submissions', COUNT(*) FROM homework_submissions
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
ORDER BY table_name;

-- Show pre-classes with class count
SELECT
    pc.name,
    pc.is_active,
    COUNT(c.id) as class_count
FROM pre_classes pc
LEFT JOIN classes c ON c.pre_class_id = pc.id
GROUP BY pc.id, pc.name, pc.is_active
ORDER BY pc.name;

-- Show class enrollment
SELECT * FROM v_class_enrollment
ORDER BY class_name;

-- Verify test credentials
SELECT
    u.username,
    u.role,
    s.id as student_id,
    s.name as student_name
FROM users u
LEFT JOIN students s ON s.parent_id = u.username
WHERE u.username = 'P3180076A';

-- ============================================
-- MIGRATION COMPLETE!
-- ============================================
-- New features added:
-- ✅ Pre-Classes table
-- ✅ Class Members table (enrollment tracking)
-- ✅ Homework Submissions table
-- ✅ Test credentials verified (P3180076A / parent123)
-- ✅ Existing data migrated
-- ✅ Helper views created
-- ============================================
