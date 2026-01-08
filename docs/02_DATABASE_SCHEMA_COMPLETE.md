# CampusCore - Complete Database Schema

## 📊 Database Architecture Overview

**Database System:** Supabase (PostgreSQL)
**Total Tables:** 23 tables
**Relationships:** Enforced with foreign keys
**Security:** Row Level Security (RLS) disabled for development

---

## Core Tables

### 1. `users` - Authentication & User Accounts

**Purpose:** Central authentication table for all user logins

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,        -- User ID (e.g., P3180076A, T001, VP001)
    password TEXT NOT NULL,               -- Plain text (should be hashed in production)
    name TEXT NOT NULL,                   -- Full name
    role TEXT NOT NULL CHECK (
        role IN ('parent', 'teacher', 'coordinator',
                 'viceprincipal', 'superviceprincipal', 'classteacher')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Fields:**
- `username`: Unique identifier for login (matches parent_id, teacher_id, etc.)
- `role`: Determines dashboard access and permissions
- `password`: Should be bcrypt hashed in production

**Example Data:**
```
| username    | password   | name                  | role          |
|-------------|------------|-----------------------|---------------|
| P3180076A   | parent123  | Parent of Kasula      | parent        |
| T001        | teacher123 | English Teacher       | teacher       |
| CT8B        | CLASS123   | Class Teacher 8B      | classteacher  |
| VP001       | VP123      | Srishia Vice Principal| viceprincipal |
```

**Relationships:**
- Referenced by: All role-specific tables via their ID fields

---

### 2. `students` - Student Records

**Purpose:** Core student information

```sql
CREATE TABLE students (
    id BIGINT PRIMARY KEY,                -- Student ID (e.g., 3180076)
    name TEXT NOT NULL,                   -- Student name
    class TEXT NOT NULL,                  -- Class (e.g., 8B, 10A)
    parent_id TEXT,                       -- Parent ID (FK to parents.id)
    status TEXT DEFAULT 'active' CHECK (
        status IN ('active', 'inactive', 'removed')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Status Values:**
- `active`: Regular student
- `inactive`: Removed but data preserved
- `removed`: Marked for permanent deletion

**Example Data:**
```
| id      | name            | class | parent_id  | status |
|---------|-----------------|-------|------------|--------|
| 3180076 | Kasula Ashwath  | 8B    | P3180076A  | active |
| 3240504 | Sai Charan      | 8B    | P3240504A  | active |
```

**Relationships:**
- One student → One parent (via parent_id)
- One student → Many marks_entries
- One student → Many attendance records
- One student → Many exam_results
- One student → Many report_cards

---

### 3. `parents` - Parent Records

**Purpose:** Parent contact and student linkage

```sql
CREATE TABLE parents (
    id TEXT PRIMARY KEY,                  -- Parent ID (e.g., P3180076A)
    name TEXT NOT NULL,                   -- Parent name
    student_id BIGINT REFERENCES students(id),  -- Linked student
    phone TEXT,                           -- Contact number
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Features:**
- `id` matches `username` in users table
- Each parent linked to one student (can be extended for multiple children)

**Example Data:**
```
| id         | name                  | student_id | phone       |
|------------|-----------------------|------------|-------------|
| P3180076A  | Parent of Kasula      | 3180076    | 9876543210  |
| P3240504A  | Parent of Sai Charan  | 3240504    | 9876543213  |
```

---

### 4. `teachers` - Teacher Records

**Purpose:** Teacher information and assignments

```sql
CREATE TABLE teachers (
    id TEXT PRIMARY KEY,                  -- Teacher ID (e.g., T001)
    name TEXT NOT NULL,
    subjects TEXT,                        -- Comma-separated subjects
    classes TEXT,                         -- Comma-separated classes
    status TEXT DEFAULT 'active' CHECK (
        status IN ('active', 'inactive')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Example Data:**
```
| id   | name            | subjects      | classes | status |
|------|-----------------|---------------|---------|--------|
| T001 | English Teacher | English       | 8B,10A  | active |
| T002 | Math Teacher    | Mathematics   | 8B,10A  | active |
| T003 | Science Teacher | Physics       | 10A     | active |
```

---

### 5. `class_teachers` - Class Teacher Assignments

**Purpose:** Maps class teachers to their classes

```sql
CREATE TABLE class_teachers (
    id TEXT PRIMARY KEY,                  -- Class teacher ID (e.g., CT8B)
    name TEXT NOT NULL,
    class TEXT NOT NULL,                  -- Assigned class
    status TEXT DEFAULT 'active' CHECK (
        status IN ('active', 'inactive')
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Example Data:**
```
| id    | name             | class | status |
|-------|------------------|-------|--------|
| CT8B  | Class Teacher 8B | 8B    | active |
| CT10A | PRASNA KUMAR     | 10A   | active |
```

---

## Academic Tables

### 6. `marks_entries` - Individual Marks Submission

**Purpose:** Teachers enter marks here (CRITICAL TABLE for report card system)

```sql
CREATE TABLE marks_entries (
    id BIGSERIAL PRIMARY KEY,

    -- Student and exam details
    student_id BIGINT REFERENCES students(id) NOT NULL,
    subject TEXT NOT NULL,
    exam_name TEXT NOT NULL,              -- e.g., "Mid Term 2025"
    exam_type TEXT NOT NULL CHECK (
        exam_type IN ('unit_test', 'mid_term', 'final',
                      'quarterly', 'half_yearly', 'annual')
    ),

    -- Marks data
    marks_obtained NUMERIC NOT NULL CHECK (marks_obtained >= 0),
    max_marks NUMERIC NOT NULL CHECK (max_marks > 0),
    percentage NUMERIC GENERATED ALWAYS AS
        ((marks_obtained / max_marks) * 100) STORED,

    -- Teacher who entered
    teacher_id TEXT NOT NULL,

    -- Status management (CRITICAL for locking)
    status TEXT DEFAULT 'draft' CHECK (
        status IN ('draft', 'submitted', 'locked')
    ),
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
```

**Status Flow:**
```
draft → submitted → locked
  ↓         ↓          ↓
Can edit  Cannot edit  PERMANENT
```

**Example Data:**
```
| id | student_id | subject | exam_name     | exam_type | marks | max | teacher_id | status    |
|----|------------|---------|---------------|-----------|-------|-----|------------|-----------|
| 1  | 3180076    | English | Mid Term 2025 | mid_term  | 78    | 100 | T001       | locked    |
| 2  | 3180076    | Math    | Mid Term 2025 | mid_term  | 85    | 100 | T002       | locked    |
| 3  | 3240504    | English | Mid Term 2025 | mid_term  | 92    | 100 | T001       | submitted |
```

**Key Features:**
- Unique constraint prevents duplicate entries
- Percentage auto-calculated
- Status controls edit permissions
- Audit trail tracks who/when

---

### 7. `report_cards` - Generated Report Cards

**Purpose:** Stores final report cards with PDFs (CRITICAL for parent delivery)

```sql
CREATE TABLE report_cards (
    id BIGSERIAL PRIMARY KEY,

    -- Student details
    student_id BIGINT REFERENCES students(id) NOT NULL,

    -- Academic details
    academic_year TEXT NOT NULL,          -- e.g., "2024-2025"
    term TEXT NOT NULL,                   -- e.g., "Mid Term", "Final"
    class TEXT NOT NULL,

    -- Performance data (JSON)
    subjects_data JSONB NOT NULL,         -- Array of subject marks/grades

    -- Calculated aggregates
    total_marks_obtained NUMERIC NOT NULL,
    total_max_marks NUMERIC NOT NULL,
    overall_percentage NUMERIC NOT NULL,
    overall_grade TEXT NOT NULL,          -- A+, A, B+, etc.
    pass_fail_status TEXT NOT NULL CHECK (
        pass_fail_status IN ('PASS', 'FAIL')
    ),

    -- PDF storage (base64 encoded)
    pdf_base64 TEXT,                      -- Complete PDF as base64 string
    pdf_generated BOOLEAN DEFAULT false,

    -- Locking mechanism (CRITICAL - prevents modifications)
    is_locked BOOLEAN DEFAULT false NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE,
    locked_by TEXT,                       -- Class teacher who generated

    -- Remarks
    class_teacher_remarks TEXT,
    principal_remarks TEXT,

    -- Audit
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    generated_by TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- One report per student per term
    UNIQUE(student_id, academic_year, term)
);
```

**subjects_data JSON Structure:**
```json
[
    {
        "subject": "English",
        "marks_obtained": 78,
        "max_marks": 100,
        "percentage": "78.00",
        "grade": "B+",
        "status": "PASS"
    },
    {
        "subject": "Mathematics",
        "marks_obtained": 85,
        "max_marks": 100,
        "percentage": "85.00",
        "grade": "A-",
        "status": "PASS"
    }
]
```

**Example Data:**
```
| id | student_id | academic_year | term     | overall_% | grade | pass_fail | is_locked | pdf_generated |
|----|------------|---------------|----------|-----------|-------|-----------|-----------|---------------|
| 1  | 3180076    | 2024-2025     | Mid Term | 85.00     | A-    | PASS      | true      | true          |
```

**Key Features:**
- `is_locked = true` → Cannot be modified (enforced by triggers)
- `pdf_base64` stores complete PDF
- Unique constraint prevents duplicates
- JSON stores detailed subject-wise data

---

### 8. `report_card_config` - Grading Configuration

**Purpose:** Defines grading system per class

```sql
CREATE TABLE report_card_config (
    id BIGSERIAL PRIMARY KEY,

    -- Grading system (JSON)
    grade_system JSONB NOT NULL,
    passing_percentage NUMERIC DEFAULT 40,

    -- Class-specific config
    class TEXT NOT NULL UNIQUE,
    required_subjects JSONB NOT NULL,     -- List of required subjects

    -- Active configuration
    is_active BOOLEAN DEFAULT true,
    academic_year TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**grade_system JSON:**
```json
[
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
]
```

**required_subjects JSON:**
```json
["Mathematics", "English", "Science", "Social Studies", "Hindi"]
```

---

### 9. `audit_logs` - Complete Audit Trail

**Purpose:** Track every action for accountability

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,

    -- Action details
    action_type TEXT NOT NULL,            -- MARKS_SUBMITTED, REPORT_GENERATED, etc.
    entity_type TEXT NOT NULL,            -- marks_entry, report_card, etc.
    entity_id BIGINT NOT NULL,

    -- User details
    user_id TEXT NOT NULL,
    user_role TEXT NOT NULL,
    user_name TEXT,

    -- Data snapshots
    old_data JSONB,                       -- Before change
    new_data JSONB,                       -- After change

    -- Context
    description TEXT,
    ip_address TEXT,
    user_agent TEXT,

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Action Types:**
- `MARKS_SAVED_DRAFT`
- `MARKS_SUBMITTED`
- `MARKS_EDITED`
- `REPORT_GENERATED`
- `REPORT_VIEWED`
- `REPORT_DOWNLOADED`

**Example Log Entry:**
```json
{
    "action_type": "REPORT_GENERATED",
    "entity_type": "report_card",
    "entity_id": 1,
    "user_id": "CT8B",
    "user_role": "classteacher",
    "description": "Report card generated for Kasula Ashwath (3180076)",
    "new_data": {...report_card_data...},
    "created_at": "2025-01-15T10:30:00Z"
}
```

---

## Supporting Tables

### 10. `attendance` - Student Attendance

```sql
CREATE TABLE attendance (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    date DATE NOT NULL,
    period TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('present', 'absent', 'late')),
    behavior TEXT DEFAULT 'good' CHECK (
        behavior IN ('good', 'excellent', 'distracting')
    ),
    marked_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, date, period)
);
```

### 11. `homework` - Homework Assignments

```sql
CREATE TABLE homework (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    subject TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    due_date DATE,
    assigned_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 12. `exam_schedules` - Exam Timetable

```sql
CREATE TABLE exam_schedules (
    id BIGSERIAL PRIMARY KEY,
    class TEXT NOT NULL,
    subject TEXT NOT NULL,
    exam_name TEXT NOT NULL,
    date DATE NOT NULL,
    time TEXT,
    duration TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 13. `issues` - Issue Tracking

```sql
CREATE TABLE issues (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    reported_by TEXT,
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'in_progress', 'resolved', 'escalated')
    ),
    priority TEXT DEFAULT 'normal' CHECK (
        priority IN ('low', 'normal', 'high', 'critical')
    ),
    assigned_to TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 14. `teacher_duties` - Teacher Duty Assignments

```sql
CREATE TABLE teacher_duties (
    id BIGSERIAL PRIMARY KEY,
    teacher_id TEXT NOT NULL,
    duty_name TEXT NOT NULL,
    duty_date DATE,
    duty_time TEXT,
    location TEXT,
    assigned_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 15. `holidays` - School Holidays

```sql
CREATE TABLE holidays (
    id BIGSERIAL PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 16. `classes` - Class Information

```sql
CREATE TABLE classes (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    grade INT NOT NULL,
    section TEXT NOT NULL,
    class_teacher_id TEXT,
    total_students INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Relationships Diagram

```
users
  ├─→ parents (username = id)
  │     └─→ students (student_id)
  ├─→ teachers (username = id)
  └─→ class_teachers (username = id)

students
  ├─→ marks_entries (many)
  ├─→ report_cards (many)
  ├─→ attendance (many)
  └─→ exam_results (many)

marks_entries
  └─→ locked when report_cards generated

report_cards
  └─→ delivered to parent via student_id linkage
```

---

## Database Triggers (Security Enforcement)

### 1. Prevent Report Card Unlock

```sql
CREATE OR REPLACE FUNCTION prevent_report_card_unlock()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_locked = true AND NEW.is_locked = false THEN
        RAISE EXCEPTION 'Report cards cannot be unlocked once locked';
    END IF;

    IF OLD.is_locked = true THEN
        IF NEW.class_teacher_remarks IS DISTINCT FROM OLD.class_teacher_remarks OR
           NEW.principal_remarks IS DISTINCT FROM OLD.principal_remarks THEN
            RETURN NEW;  -- Allow remarks
        END IF;
        RAISE EXCEPTION 'Locked report cards cannot be modified';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_report_card_lock
    BEFORE UPDATE ON report_cards
    FOR EACH ROW
    EXECUTE FUNCTION prevent_report_card_unlock();
```

### 2. Prevent Locked Marks Edit

```sql
CREATE OR REPLACE FUNCTION prevent_locked_marks_edit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'locked' AND OLD.is_finalized = true THEN
        RAISE EXCEPTION 'Locked marks cannot be edited';
    END IF;

    IF OLD.status = 'submitted' AND NEW.status = 'draft' THEN
        RAISE EXCEPTION 'Submitted marks cannot be reverted to draft';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_marks_lock
    BEFORE UPDATE ON marks_entries
    FOR EACH ROW
    EXECUTE FUNCTION prevent_locked_marks_edit();
```

---

## Indexes for Performance

```sql
-- marks_entries
CREATE INDEX idx_marks_entries_student ON marks_entries(student_id);
CREATE INDEX idx_marks_entries_teacher ON marks_entries(teacher_id);
CREATE INDEX idx_marks_entries_status ON marks_entries(status);
CREATE INDEX idx_marks_entries_exam ON marks_entries(exam_name, exam_type);

-- report_cards
CREATE INDEX idx_report_cards_student ON report_cards(student_id);
CREATE INDEX idx_report_cards_locked ON report_cards(is_locked);
CREATE INDEX idx_report_cards_term ON report_cards(academic_year, term);

-- audit_logs
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action_type);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- students
CREATE INDEX idx_students_class ON students(class);
CREATE INDEX idx_students_parent_id ON students(parent_id);
```

---

## Data Integrity Rules

1. **Referential Integrity:**
   - All foreign keys enforced
   - Cascade deletes disabled (prevent accidental data loss)

2. **Unique Constraints:**
   - One user per username
   - One marks entry per student/subject/exam
   - One report card per student/term

3. **Check Constraints:**
   - Valid status values
   - Marks cannot be negative
   - Max marks must be positive

4. **Triggers:**
   - Prevent unlocking locked data
   - Prevent modifying finalized data
   - Auto-update timestamps

---

**Next Document:** `03_WORKFLOW_MARKS_TO_REPORT.md` - Complete workflow from marks entry to parent delivery
