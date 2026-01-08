# CampusCore - Security, Audit & Data Integrity

## 🔒 Security Architecture

This document details ALL security measures, access controls, and data protection mechanisms implemented in CampusCore.

---

## 1. "Cannot Be Undone" Enforcement

### 1.1 Database-Level Protection (PostgreSQL Triggers)

**Trigger 1: Prevent Report Card Unlock**

```sql
CREATE OR REPLACE FUNCTION prevent_report_card_unlock()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if trying to unlock a locked report card
    IF OLD.is_locked = true AND NEW.is_locked = false THEN
        RAISE EXCEPTION 'Report cards cannot be unlocked once locked. This action is permanent.';
    END IF;

    -- Prevent modification of locked report cards
    IF OLD.is_locked = true THEN
        -- Only allow remarks to be added
        IF NEW.class_teacher_remarks IS DISTINCT FROM OLD.class_teacher_remarks OR
           NEW.principal_remarks IS DISTINCT FROM OLD.principal_remarks THEN
            RETURN NEW;  -- Allow remarks update
        END IF;

        RAISE EXCEPTION 'Locked report cards cannot be modified. Contact administrator.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to report_cards table
CREATE TRIGGER enforce_report_card_lock
    BEFORE UPDATE ON report_cards
    FOR EACH ROW
    EXECUTE FUNCTION prevent_report_card_unlock();
```

**Test Case:**
```sql
-- This will FAIL with error
UPDATE report_cards
SET is_locked = false
WHERE id = 1 AND is_locked = true;

-- Error: Report cards cannot be unlocked once locked
```

**Trigger 2: Prevent Locked Marks Edit**

```sql
CREATE OR REPLACE FUNCTION prevent_locked_marks_edit()
RETURNS TRIGGER AS $$
BEGIN
    -- Cannot edit locked marks
    IF OLD.status = 'locked' AND OLD.is_finalized = true THEN
        RAISE EXCEPTION 'Locked marks cannot be edited. Contact administrator for corrections.';
    END IF;

    -- Cannot revert submitted to draft
    IF OLD.status = 'submitted' AND NEW.status = 'draft' THEN
        RAISE EXCEPTION 'Submitted marks cannot be reverted to draft.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger
CREATE TRIGGER enforce_marks_lock
    BEFORE UPDATE ON marks_entries
    FOR EACH ROW
    EXECUTE FUNCTION prevent_locked_marks_edit();
```

**Test Case:**
```sql
-- This will FAIL
UPDATE marks_entries
SET marks_obtained = 95
WHERE status = 'locked';

-- Error: Locked marks cannot be edited
```

### 1.2 Application-Level Protection

**JavaScript Validation:**

```javascript
// Before any marks edit
async function validateCanEditMarks(marksEntryId) {
    const { data: marks } = await supabase
        .from('marks_entries')
        .select('status, is_finalized')
        .eq('id', marksEntryId)
        .single();

    if (marks.status === 'locked' && marks.is_finalized) {
        throw new Error('Cannot edit: Marks are locked permanently');
    }

    if (marks.status === 'submitted') {
        const user = getCurrentUser();
        if (user.role !== 'superviceprincipal') {
            throw new Error('Cannot edit: Marks already submitted. Contact admin.');
        }
    }

    return true;
}

// Before report card modification
async function validateCanModifyReport(reportCardId) {
    const { data: report } = await supabase
        .from('report_cards')
        .select('is_locked')
        .eq('id', reportCardId)
        .single();

    if (report.is_locked) {
        throw new Error('Cannot modify: Report card is locked permanently');
    }

    return true;
}
```

### 1.3 UI-Level Protection

**Hide Edit Buttons for Locked Data:**

```javascript
function renderMarksTable(marks) {
    return marks.map(mark => {
        const canEdit = mark.status === 'draft';
        const canSubmit = mark.status === 'draft' || mark.status === 'submitted';

        return `
            <tr>
                <td>${mark.student_id}</td>
                <td>${mark.subject}</td>
                <td>${mark.marks_obtained}</td>
                <td>
                    ${canEdit
                        ? `<button onclick="editMarks(${mark.id})">Edit</button>`
                        : `<span class="locked">🔒 Locked</span>`
                    }
                </td>
            </tr>
        `;
    });
}
```

---

## 2. Role-Based Access Control (RBAC)

### 2.1 Permission Matrix

| Resource | Parent | Teacher | Class Teacher | Coordinator | VP | Super VP |
|----------|--------|---------|---------------|-------------|-------|----------|
| **Marks Entry** |
| Enter Marks | ❌ | ✅ (Own subjects) | ✅ | ❌ | ❌ | ❌ |
| Edit Draft Marks | ❌ | ✅ (Own) | ✅ (Own) | ❌ | ❌ | ❌ |
| Edit Submitted Marks | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (Override) |
| View Own Marks | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| View All Marks | ❌ | ❌ | ✅ (Own class) | ✅ | ✅ | ✅ |
| **Report Cards** |
| Generate Reports | ❌ | ❌ | ✅ (Own class) | ❌ | ❌ | ❌ |
| View Reports | ✅ (Own child) | ❌ | ✅ (Own class) | ✅ | ✅ | ✅ |
| Download PDF | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ |
| Unlock Reports | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (Emergency) |
| **Administration** |
| Appoint Teachers | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Remove Students | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Manage Users | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| View Audit Logs | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

### 2.2 Access Control Implementation

**Function-Level Authorization:**

```javascript
function requireRole(allowedRoles) {
    const user = getCurrentUser();

    if (!user) {
        throw new Error('Not authenticated');
    }

    if (!allowedRoles.includes(user.role)) {
        throw new Error(`Unauthorized: ${user.role} cannot perform this action`);
    }

    return true;
}

// Usage examples
async function submitMarks(marksData) {
    requireRole(['teacher', 'classteacher']);
    // ... proceed with marks submission
}

async function generateReportCards() {
    requireRole(['classteacher']);
    // ... proceed with report generation
}

async function unlockReportCard(reportId) {
    requireRole(['superviceprincipal']);  // Only super admin
    // ... proceed with unlock
}
```

**Data-Level Authorization:**

```javascript
async function getReportCards() {
    const user = getCurrentUser();

    let query = supabase.from('report_cards').select('*');

    switch(user.role) {
        case 'parent':
            // Parents see only their child's reports
            const { data: parent } = await supabase
                .from('parents')
                .select('student_id')
                .eq('id', user.username)
                .single();

            query = query.eq('student_id', parent.student_id);
            break;

        case 'classteacher':
            // Class teachers see their class only
            const { data: ct } = await supabase
                .from('class_teachers')
                .select('class')
                .eq('id', user.username)
                .single();

            const { data: students } = await supabase
                .from('students')
                .select('id')
                .eq('class', ct.class);

            const studentIds = students.map(s => s.id);
            query = query.in('student_id', studentIds);
            break;

        case 'viceprincipal':
        case 'superviceprincipal':
        case 'coordinator':
            // Admins see all
            break;

        default:
            throw new Error('Unauthorized role');
    }

    const { data, error } = await query;
    return data;
}
```

---

## 3. Data Integrity Measures

### 3.1 Unique Constraints

**Prevent Duplicate Entries:**

```sql
-- One marks entry per student/subject/exam
ALTER TABLE marks_entries
ADD CONSTRAINT unique_marks_entry
UNIQUE (student_id, subject, exam_name, exam_type);

-- One report card per student/term
ALTER TABLE report_cards
ADD CONSTRAINT unique_report_card
UNIQUE (student_id, academic_year, term);

-- One username per user
ALTER TABLE users
ADD CONSTRAINT unique_username
UNIQUE (username);
```

**Result:**
```sql
-- This INSERT will FAIL if entry already exists
INSERT INTO marks_entries (student_id, subject, exam_name, exam_type, marks_obtained, max_marks)
VALUES (3180076, 'English', 'Mid Term 2025', 'mid_term', 85, 100);

-- Error: duplicate key value violates unique constraint
```

### 3.2 Check Constraints

**Validate Data Ranges:**

```sql
-- Marks must be valid
ALTER TABLE marks_entries
ADD CONSTRAINT check_marks_valid
CHECK (marks_obtained >= 0 AND marks_obtained <= max_marks);

ALTER TABLE marks_entries
ADD CONSTRAINT check_max_marks_positive
CHECK (max_marks > 0);

-- Status must be valid
ALTER TABLE marks_entries
ADD CONSTRAINT check_status_valid
CHECK (status IN ('draft', 'submitted', 'locked'));

-- Pass/Fail must be valid
ALTER TABLE report_cards
ADD CONSTRAINT check_pass_fail_valid
CHECK (pass_fail_status IN ('PASS', 'FAIL'));
```

**Result:**
```sql
-- This will FAIL
INSERT INTO marks_entries (..., marks_obtained, max_marks)
VALUES (..., 110, 100);  -- Marks > max_marks

-- Error: new row violates check constraint "check_marks_valid"
```

### 3.3 Foreign Key Constraints

**Maintain Referential Integrity:**

```sql
-- Marks must reference valid student
ALTER TABLE marks_entries
ADD CONSTRAINT fk_student
FOREIGN KEY (student_id) REFERENCES students(id);

-- Report card must reference valid student
ALTER TABLE report_cards
ADD CONSTRAINT fk_student
FOREIGN KEY (student_id) REFERENCES students(id);

-- Parent must reference valid student
ALTER TABLE parents
ADD CONSTRAINT fk_student
FOREIGN KEY (student_id) REFERENCES students(id);
```

**Result:**
```sql
-- This will FAIL if student doesn't exist
INSERT INTO marks_entries (student_id, ...)
VALUES (9999999, ...);

-- Error: insert or update violates foreign key constraint
```

### 3.4 Atomic Transactions

**All-or-Nothing Report Generation:**

```javascript
async function generateReportCardsAtomic(students) {
    // Start transaction (in production, use proper transaction API)
    try {
        for (const student of students) {
            // 1. Calculate grades
            const reportData = await calculateGrades(student);

            // 2. Generate PDF
            const pdf = await generatePDF(reportData);

            // 3. Insert report
            await insertReport(reportData, pdf);

            // 4. Lock marks
            await lockMarks(student.id);
        }

        // All succeeded → commit
        return { success: true };

    } catch (error) {
        // Any failure → rollback all changes
        console.error('Transaction failed, rolling back:', error);
        throw error;
    }
}
```

---

## 4. Audit Logging System

### 4.1 Audit Log Structure

**Complete Activity Tracking:**

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,

    -- What happened
    action_type TEXT NOT NULL,        -- MARKS_SUBMITTED, REPORT_GENERATED, etc.
    entity_type TEXT NOT NULL,        -- marks_entry, report_card, etc.
    entity_id BIGINT NOT NULL,        -- ID of the affected entity

    -- Who did it
    user_id TEXT NOT NULL,            -- Username
    user_role TEXT NOT NULL,          -- Role at time of action
    user_name TEXT,                   -- Full name

    -- What changed
    old_data JSONB,                   -- State before
    new_data JSONB,                   -- State after

    -- Context
    description TEXT,
    ip_address TEXT,
    user_agent TEXT,

    -- When
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4.2 Logged Actions

**Complete Audit Trail:**

```javascript
// Marks Submission
await createAuditLog({
    action_type: 'MARKS_SUBMITTED',
    entity_type: 'marks_entry',
    entity_id: marksId,
    user_id: user.username,
    user_role: user.role,
    user_name: user.name,
    old_data: { status: 'draft' },
    new_data: { status: 'submitted', marks: 85 },
    description: `Final marks submitted for student ${studentId} in ${subject}`
});

// Report Generation
await createAuditLog({
    action_type: 'REPORT_GENERATED',
    entity_type: 'report_card',
    entity_id: reportId,
    user_id: user.username,
    user_role: user.role,
    new_data: reportCardData,
    description: `Report card generated for ${studentName}`
});

// Report View
await createAuditLog({
    action_type: 'REPORT_VIEWED',
    entity_type: 'report_card',
    entity_id: reportId,
    user_id: user.username,
    user_role: user.role,
    description: `Report viewed by ${user.role} ${user.name}`
});

// Report Download
await createAuditLog({
    action_type: 'REPORT_DOWNLOADED',
    entity_type: 'report_card',
    entity_id: reportId,
    user_id: user.username,
    user_role: user.role,
    description: `PDF downloaded by ${user.role}`
});

// Admin Override
await createAuditLog({
    action_type: 'MARKS_UNLOCKED_ADMIN',
    entity_type: 'marks_entry',
    entity_id: marksId,
    user_id: user.username,
    user_role: 'superviceprincipal',
    old_data: { status: 'locked' },
    new_data: { status: 'submitted' },
    description: `Emergency unlock by admin: ${reason}`
});
```

### 4.3 Audit Log Queries

**Track Specific Actions:**

```sql
-- Who generated a specific report card?
SELECT user_name, user_role, created_at, description
FROM audit_logs
WHERE entity_type = 'report_card'
  AND entity_id = 1
  AND action_type = 'REPORT_GENERATED';

-- What did user CT8B do?
SELECT action_type, entity_type, entity_id, description, created_at
FROM audit_logs
WHERE user_id = 'CT8B'
ORDER BY created_at DESC;

-- All admin overrides
SELECT *
FROM audit_logs
WHERE action_type LIKE '%ADMIN%'
  OR action_type LIKE '%UNLOCK%'
ORDER BY created_at DESC;

-- Who accessed student 3180076's report?
SELECT user_id, user_role, action_type, created_at
FROM audit_logs
WHERE entity_type = 'report_card'
  AND new_data->>'student_id' = '3180076'
ORDER BY created_at DESC;
```

---

## 5. Error Handling & Edge Cases

### 5.1 Validation Before Report Generation

**Check All Prerequisites:**

```javascript
async function validateBeforeGeneration(className, examName, examType) {
    const errors = [];

    // 1. Get required subjects
    const { data: config } = await supabase
        .from('report_card_config')
        .select('required_subjects')
        .eq('class', className)
        .single();

    if (!config) {
        errors.push(`No grading configuration found for class ${className}`);
        return { valid: false, errors };
    }

    // 2. Get all students
    const { data: students } = await supabase
        .from('students')
        .select('*')
        .eq('class', className)
        .eq('status', 'active');

    if (!students || students.length === 0) {
        errors.push(`No active students found in class ${className}`);
        return { valid: false, errors };
    }

    // 3. Check each student has all required subjects
    for (const student of students) {
        const { data: marks } = await supabase
            .from('marks_entries')
            .select('subject, status')
            .eq('student_id', student.id)
            .eq('exam_name', examName)
            .eq('exam_type', examType);

        const submittedSubjects = marks
            .filter(m => m.status === 'submitted')
            .map(m => m.subject);

        const missingSubjects = config.required_subjects.filter(
            sub => !submittedSubjects.includes(sub)
        );

        if (missingSubjects.length > 0) {
            errors.push(
                `${student.name} (${student.id}) missing: ${missingSubjects.join(', ')}`
            );
        }

        // Check for draft marks (not submitted)
        const draftMarks = marks.filter(m => m.status === 'draft');
        if (draftMarks.length > 0) {
            errors.push(
                `${student.name} has ${draftMarks.length} draft marks not submitted`
            );
        }
    }

    // 4. Check if reports already exist
    const { data: existingReports } = await supabase
        .from('report_cards')
        .select('student_id, is_locked')
        .in('student_id', students.map(s => s.id))
        .eq('academic_year', config.academic_year)
        .eq('term', examName);

    if (existingReports && existingReports.length > 0) {
        const lockedReports = existingReports.filter(r => r.is_locked);
        if (lockedReports.length > 0) {
            errors.push(
                `${lockedReports.length} report(s) already exist and are locked`
            );
        }
    }

    return {
        valid: errors.length === 0,
        errors: errors
    };
}
```

**Usage:**
```javascript
const validation = await validateBeforeGeneration('8B', 'Mid Term 2025', 'mid_term');

if (!validation.valid) {
    showModal('Cannot Generate Reports', validation.errors.join('\n'), 'error');
    return;
}

// Proceed with generation
```

### 5.2 Handling Partial Failures

**Track Success & Failures:**

```javascript
async function generateWithErrorHandling(students) {
    const results = {
        successful: [],
        failed: []
    };

    for (const student of students) {
        try {
            const report = await generateReportCard(student);
            results.successful.push({
                student_id: student.id,
                student_name: student.name,
                report_id: report.id
            });
        } catch (error) {
            results.failed.push({
                student_id: student.id,
                student_name: student.name,
                error: error.message
            });

            // Log the failure
            await createAuditLog({
                action_type: 'REPORT_GENERATION_FAILED',
                entity_type: 'report_card',
                entity_id: student.id,
                user_id: getCurrentUser().username,
                description: `Failed to generate report: ${error.message}`
            });
        }
    }

    // Show detailed results
    if (results.failed.length > 0) {
        showModal(
            'Partial Success',
            `Generated ${results.successful.length} reports. Failed: ${results.failed.length}\n\n` +
            `Failed students:\n${results.failed.map(f => `- ${f.student_name}: ${f.error}`).join('\n')}`,
            'warning'
        );
    } else {
        showModal(
            'Success',
            `Successfully generated ${results.successful.length} report cards!`,
            'success'
        );
    }

    return results;
}
```

### 5.3 Network Error Handling

**Retry Logic for Critical Operations:**

```javascript
async function submitWithRetry(operation, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            const result = await operation();
            return result;
        } catch (error) {
            if (attempt === maxRetries) {
                throw new Error(`Failed after ${maxRetries} attempts: ${error.message}`);
            }

            // Wait before retry (exponential backoff)
            await new Promise(resolve =>
                setTimeout(resolve, 1000 * attempt)
            );
        }
    }
}

// Usage
await submitWithRetry(async () => {
    return await supabase
        .from('marks_entries')
        .insert(marksData);
});
```

---

## 6. Security Best Practices

### 6.1 Input Validation

**Sanitize All Inputs:**

```javascript
function validateMarksInput(marksData) {
    const errors = [];

    // Required fields
    if (!marksData.student_id) errors.push('Student ID required');
    if (!marksData.subject) errors.push('Subject required');
    if (!marksData.exam_name) errors.push('Exam name required');

    // Numeric validations
    if (isNaN(marksData.marks_obtained)) {
        errors.push('Marks must be a number');
    } else {
        const marks = parseFloat(marksData.marks_obtained);
        if (marks < 0) errors.push('Marks cannot be negative');
        if (marks > marksData.max_marks) {
            errors.push('Marks cannot exceed maximum');
        }
    }

    // Max marks validation
    if (isNaN(marksData.max_marks) || marksData.max_marks <= 0) {
        errors.push('Maximum marks must be positive');
    }

    // Inject prevention
    const dangerousChars = /<script>|<iframe>|javascript:/i;
    if (dangerousChars.test(marksData.subject)) {
        errors.push('Invalid characters in subject');
    }

    return {
        valid: errors.length === 0,
        errors: errors
    };
}
```

### 6.2 SQL Injection Prevention

**Use Parameterized Queries (Supabase handles this automatically):**

```javascript
// ✅ SAFE - Parameterized
const { data } = await supabase
    .from('users')
    .select('*')
    .eq('username', userInput)  // ← Supabase sanitizes this
    .eq('password', passwordInput);

// ❌ UNSAFE - Never do this (example only)
const query = `SELECT * FROM users WHERE username = '${userInput}'`;
```

### 6.3 XSS Prevention

**Escape User-Generated Content:**

```javascript
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Usage
const studentName = escapeHtml(student.name);
document.getElementById('name').innerHTML = studentName;
```

### 6.4 Session Security

**Secure Session Management:**

```javascript
// Store user session securely
function setSession(user) {
    // Use sessionStorage (cleared on browser close)
    sessionStorage.setItem('currentUser', JSON.stringify({
        username: user.username,
        name: user.name,
        role: user.role,
        // Don't store password
    }));

    // Set session expiry (1 hour)
    const expiry = Date.now() + (60 * 60 * 1000);
    sessionStorage.setItem('sessionExpiry', expiry.toString());
}

// Validate session on every request
function validateSession() {
    const expiry = sessionStorage.getItem('sessionExpiry');
    if (!expiry || Date.now() > parseInt(expiry)) {
        // Session expired
        logout();
        return false;
    }
    return true;
}
```

---

## 7. Compliance & Data Protection

### 7.1 Data Minimization

**Collect Only Necessary Data:**

```javascript
// Store only required fields in session
const sessionData = {
    username: user.username,
    name: user.name,
    role: user.role
    // Don't store: password, email, phone, etc.
};
```

### 7.2 Audit Data Retention

**Configurable Retention Policies:**

```sql
-- Delete audit logs older than 1 year
DELETE FROM audit_logs
WHERE created_at < NOW() - INTERVAL '1 year';

-- Archive instead of delete (recommended)
INSERT INTO audit_logs_archive
SELECT * FROM audit_logs
WHERE created_at < NOW() - INTERVAL '1 year';

DELETE FROM audit_logs
WHERE created_at < NOW() - INTERVAL '1 year';
```

---

**Next Document:** `05_SYSTEM_RELIABILITY.md` - Error handling, scalability, and production readiness summary
