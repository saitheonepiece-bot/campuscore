-- CampusCore Sample Data Initialization
-- Run this AFTER running supabase-schema.sql
-- This will populate your database with sample data for testing

-- ============================================
-- Insert Students
-- ============================================
INSERT INTO students (id, name, class, parent_id, status) VALUES
(3180076, 'Kasula Ashwath', '8B', 'P3180076A', 'active'),
(3240504, 'Sai Charan', '8B', 'P3240504A', 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Parents
-- ============================================
INSERT INTO parents (id, name, student_id, phone) VALUES
('P3180076A', 'Parent of Kasula', 3180076, '9876543210'),
('P3240504A', 'Parent of Sai Charan', 3240504, '9876543213')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Teachers
-- ============================================
INSERT INTO teachers (id, name, subjects, classes, status) VALUES
('T001', 'English Teacher', 'English', '10A', 'active'),
('T002', 'Math Teacher', 'Mathematics', '10A,10B', 'active'),
('T003', 'Science Teacher', 'Physics', '10A', 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Class Teachers
-- ============================================
INSERT INTO class_teachers (id, name, class, status) VALUES
('CT10A', 'PRASNA KUMAR', '10A', 'active'),
('CT8B', 'Class Teacher 8B', '8B', 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Coordinators
-- ============================================
INSERT INTO coordinators (id, name, department, status) VALUES
('C001', 'ANITHA', 'General', 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Vice Principals
-- ============================================
INSERT INTO vice_principals (id, name, school, status) VALUES
('VP001', 'Srishia Vice Principal', 'DPS Nadergul', 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Super Vice Principals
-- ============================================
INSERT INTO super_vice_principals (id, name, school, status) VALUES
('AP000123', 'Super Principal', 'DPS Nadergul', 'active')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Insert Users (Login Credentials)
-- ============================================
INSERT INTO users (username, password, name, role) VALUES
-- Parents
('P3180076A', 'parent123', 'Parent of Kasula', 'parent'),
('P3240504A', 'parent123', 'Parent of Sai Charan', 'parent'),
-- Teachers
('T001', 'teacher123', 'English Teacher', 'teacher'),
('T002', 'teacher123', 'Math Teacher', 'teacher'),
('T003', 'teacher123', 'Science Teacher', 'teacher'),
-- Coordinator
('C001', 'coord123', 'Coordinator Anitha', 'coordinator'),
-- Vice Principal
('VP001', 'VP123', 'Srishia Vice Principal', 'viceprincipal'),
-- Super Vice Principal
('AP000123', 'DPSSITE123', 'Super Principal', 'superviceprincipal'),
-- Class Teachers
('CT10A', 'CLASS123', 'Class Teacher 10A', 'classteacher'),
('CT8B', 'CLASS123', 'Class Teacher 8B', 'classteacher')
ON CONFLICT (username) DO NOTHING;

-- ============================================
-- Insert Holidays
-- ============================================
INSERT INTO holidays (date, reason) VALUES
('2025-12-25', 'Christmas'),
('2026-01-26', 'Republic Day'),
('2026-03-08', 'Maha Shivaratri'),
('2026-08-15', 'Independence Day'),
('2026-10-02', 'Gandhi Jayanti'),
('2026-10-24', 'Diwali'),
('2026-11-14', 'Children''s Day')
ON CONFLICT (date) DO NOTHING;

-- ============================================
-- Insert Classes
-- ============================================
INSERT INTO classes (name, grade, section, class_teacher_id, total_students) VALUES
('8B', 8, 'B', 'CT8B', 2),
('10A', 10, 'A', 'CT10A', 0)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- Insert Timetables
-- ============================================
INSERT INTO timetables (class, periods) VALUES
('10A', '[
    {"time": "8:00-8:45", "mon": "English", "tue": "Math", "wed": "Science", "thu": "Hindi", "fri": "History", "sat": "PE"},
    {"time": "8:45-9:30", "mon": "Math", "tue": "English", "wed": "History", "thu": "Science", "fri": "Geography", "sat": "Art"},
    {"time": "9:30-10:15", "mon": "Science", "tue": "Hindi", "wed": "English", "thu": "Geography", "fri": "Math", "sat": "Music"}
]'::jsonb),
('8B', '[
    {"time": "8:45-9:30", "mon": "MATH", "tue": "MATH", "wed": "LIBRARY", "thu": "PYS", "fri": "GK/VE", "sat": "LS"},
    {"time": "9:30-10:15", "mon": "CD/WD", "tue": "GAMES", "wed": "PHYSICS", "thu": "PYS", "fri": "COMPUTER", "sat": "Art"},
    {"time": "10:15-10:25", "mon": "Break", "tue": "Break", "wed": "Break", "thu": "Break", "fri": "Break", "sat": "Break"},
    {"time": "10:25-11:10", "mon": "MATH", "tue": "3L", "wed": "MUSIC", "thu": "MATH", "fri": "2L", "sat": "Music"},
    {"time": "11:10-11:45", "mon": "ENGLISH", "tue": "MATH", "wed": "2L", "thu": "BIOLOGY", "fri": "SOCIAL", "sat": "3L"},
    {"time": "11:45-12:30", "mon": "BIOLOGY", "tue": "2L", "wed": "3L", "thu": "PHYSICS", "fri": "BIOLOGY", "sat": "2L"},
    {"time": "12:30-01:10", "mon": "Lunch", "tue": "Lunch", "wed": "Lunch", "thu": "Lunch", "fri": "Lunch", "sat": "Lunch"},
    {"time": "01:10-01:55", "mon": "SOCIAL", "tue": "SOCIAL", "wed": "MATH", "thu": "SOCIAL", "fri": "CHEMHISTORY", "sat": "CHEMHISTORY"},
    {"time": "01:55-02:40", "mon": "2L", "tue": "PHYSICS", "wed": "SOCIAL", "thu": "ENGLISH", "fri": "English", "sat": "SOCIAL"},
    {"time": "02:40-03:25", "mon": "Computer", "tue": "ENGLISH", "wed": "Computer", "thu": "2L", "fri": "MATH", "sat": "MATH"}
]'::jsonb)
ON CONFLICT (class) DO NOTHING;

-- ============================================
-- Insert Sample Attendance Records
-- ============================================
INSERT INTO attendance (student_id, date, period, type, behavior, marked_by) VALUES
-- Kasula Ashwath attendance
(3180076, '2025-01-02', '1', 'present', 'excellent', 'T001'),
(3180076, '2025-01-02', '2', 'present', 'good', 'T002'),
(3180076, '2025-01-03', '1', 'present', 'good', 'T001'),
-- Sai Charan attendance
(3240504, '2025-01-02', '1', 'present', 'good', 'T001'),
(3240504, '2025-01-03', '1', 'present', 'good', 'T001')
ON CONFLICT (student_id, date, period) DO NOTHING;

-- ============================================
-- Insert Sample Homework
-- ============================================
INSERT INTO homework (class, subject, title, description, date, due_date, assigned_by) VALUES
('8B', 'Mathematics', 'Chapter 5 Exercises', 'Complete exercises 5.1 to 5.3', '2025-01-02', '2025-01-05', 'T002'),
('8B', 'English', 'Essay Writing', 'Write an essay on "My Favorite Book"', '2025-01-02', '2025-01-06', 'T001'),
('10A', 'Science', 'Lab Report', 'Complete the physics lab report on motion', '2025-01-03', '2025-01-08', 'T003'),
('10A', 'Mathematics', 'Trigonometry Problems', 'Solve problems from page 87-90', '2025-01-03', '2025-01-07', 'T002')
ON CONFLICT DO NOTHING;

-- ============================================
-- Insert Sample Exam Schedules
-- ============================================
INSERT INTO exam_schedules (class, subject, exam_name, date, time, duration) VALUES
('8B', 'Mathematics', 'Mid-Term Exam', '2025-02-15', '09:00 AM', '2 hours'),
('8B', 'English', 'Mid-Term Exam', '2025-02-16', '09:00 AM', '2 hours'),
('8B', 'Science', 'Mid-Term Exam', '2025-02-17', '09:00 AM', '2 hours'),
('10A', 'Mathematics', 'Mid-Term Exam', '2025-02-15', '09:00 AM', '3 hours'),
('10A', 'English', 'Mid-Term Exam', '2025-02-16', '09:00 AM', '3 hours'),
('10A', 'Science', 'Mid-Term Exam', '2025-02-17', '09:00 AM', '3 hours')
ON CONFLICT DO NOTHING;

-- ============================================
-- Insert Sample Exam Results
-- ============================================
INSERT INTO exam_results (student_id, exam_name, subject, marks, total_marks, grade, remarks) VALUES
(3180076, 'Unit Test 1', 'Mathematics', 85, 100, 'A', 'Excellent performance'),
(3180076, 'Unit Test 1', 'English', 78, 100, 'B+', 'Good work'),
(3180076, 'Unit Test 1', 'Science', 92, 100, 'A+', 'Outstanding')
ON CONFLICT DO NOTHING;

-- ============================================
-- Insert Sample Issues
-- ============================================
INSERT INTO issues (title, description, reported_by, status, priority, assigned_to) VALUES
('Broken projector in Class 8B', 'The projector is not working properly', 'T001', 'pending', 'normal', 'C001'),
('Student discipline issue', 'Need to address behavior in class 10A', 'T002', 'in_progress', 'high', 'VP001'),
('Library book request', 'Need more science fiction books for students', 'T003', 'pending', 'low', 'C001')
ON CONFLICT DO NOTHING;

-- Data initialization complete!
-- You can now log in with any of the user credentials listed above.
