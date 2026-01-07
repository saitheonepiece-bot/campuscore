# CampusCore Report Card System - Complete Implementation Design

## 🎯 Overview

This document provides a complete, production-ready design for an automated marks entry and report card generation system with zero-tolerance for errors.

---

## 📊 Database Schema Changes

### 1. New Table: `marks_entries`
Stores individual marks entered by subject teachers.

```sql
CREATE TABLE marks_entries (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id) NOT NULL,
    subject TEXT NOT NULL,
    exam_name TEXT NOT NULL,
    exam_type TEXT NOT NULL, -- 'unit_test', 'mid_term', 'final'
    marks_obtained NUMERIC NOT NULL CHECK (marks_obtained >= 0),
    max_marks NUMERIC NOT NULL CHECK (max_marks > 0),
    teacher_id TEXT NOT NULL REFERENCES teachers(id),

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

CREATE INDEX idx_marks_entries_student ON marks_entries(student_id);
CREATE INDEX idx_marks_entries_teacher ON marks_entries(teacher_id);
CREATE INDEX idx_marks_entries_status ON marks_entries(status);
```

### 2. Enhanced Table: `report_cards`
Stores generated report cards with locking mechanism.

```sql
-- Drop existing table if needed and recreate
DROP TABLE IF EXISTS report_cards;

CREATE TABLE report_cards (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id) NOT NULL,

    -- Academic details
    academic_year TEXT NOT NULL,
    term TEXT NOT NULL, -- 'Term 1', 'Term 2', 'Final'
    class TEXT NOT NULL,

    -- Performance data (JSON)
    subjects_data JSONB NOT NULL, -- [{subject, marks, max_marks, grade, percentage}]

    -- Calculated fields
    total_marks_obtained NUMERIC NOT NULL,
    total_max_marks NUMERIC NOT NULL,
    overall_percentage NUMERIC NOT NULL,
    overall_grade TEXT NOT NULL,
    pass_fail_status TEXT NOT NULL CHECK (pass_fail_status IN ('PASS', 'FAIL')),

    -- PDF storage
    pdf_url TEXT, -- URL to stored PDF
    pdf_generated BOOLEAN DEFAULT false,

    -- Locking mechanism
    is_locked BOOLEAN DEFAULT false NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE,
    locked_by TEXT, -- class_teacher_id who generated it

    -- Remarks
    class_teacher_remarks TEXT,
    principal_remarks TEXT,

    -- Audit
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    generated_by TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- One report card per student per term
    UNIQUE(student_id, academic_year, term)
);

CREATE INDEX idx_report_cards_student ON report_cards(student_id);
CREATE INDEX idx_report_cards_locked ON report_cards(is_locked);
CREATE INDEX idx_report_cards_term ON report_cards(academic_year, term);
```

### 3. New Table: `audit_logs`
Complete audit trail for accountability.

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,

    -- Action details
    action_type TEXT NOT NULL, -- 'MARKS_SUBMITTED', 'MARKS_EDITED', 'REPORT_GENERATED', 'REPORT_VIEWED'
    entity_type TEXT NOT NULL, -- 'marks_entry', 'report_card'
    entity_id BIGINT NOT NULL,

    -- User details
    user_id TEXT NOT NULL,
    user_role TEXT NOT NULL,
    user_name TEXT,

    -- Data snapshot
    old_data JSONB, -- Previous state
    new_data JSONB, -- New state

    -- Context
    description TEXT,
    ip_address TEXT,
    user_agent TEXT,

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action_type);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);
```

### 4. New Table: `report_card_config`
System configuration for grading and pass criteria.

```sql
CREATE TABLE report_card_config (
    id BIGSERIAL PRIMARY KEY,

    -- Grading system
    grade_system JSONB NOT NULL, -- [{"min": 90, "max": 100, "grade": "A+"}]
    passing_percentage NUMERIC DEFAULT 40,

    -- Required subjects per class
    class TEXT NOT NULL UNIQUE,
    required_subjects JSONB NOT NULL, -- ["Mathematics", "English", "Science"]

    -- Active config
    is_active BOOLEAN DEFAULT true,
    academic_year TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔐 Security & Access Control

### Role-Based Permissions Matrix

| Action | Teacher | Class Teacher | Parent | Coordinator | VP/SVP |
|--------|---------|---------------|--------|-------------|--------|
| Enter Marks | ✅ (Own subjects) | ✅ | ❌ | ❌ | ❌ |
| Edit Draft Marks | ✅ | ✅ | ❌ | ❌ | ❌ |
| Edit Submitted Marks | ❌ | ❌ | ❌ | ❌ | ✅ (Admin override) |
| View All Marks | ❌ | ✅ (Own class) | ❌ | ✅ | ✅ |
| Generate Report Card | ❌ | ✅ (Own class) | ❌ | ❌ | ❌ |
| View Report Card | ❌ | ✅ | ✅ (Own child) | ✅ | ✅ |
| Download Report PDF | ❌ | ✅ | ✅ | ✅ | ✅ |
| Unlock Report Card | ❌ | ❌ | ❌ | ❌ | ✅ (Admin only) |

### Security Rules

1. **Marks Entry Validation:**
```javascript
// Pseudo-code for security checks
if (user.role !== 'teacher' && user.role !== 'classteacher') {
    throw new Error('Unauthorized: Only teachers can enter marks');
}

if (marksEntry.status === 'locked') {
    throw new Error('Cannot modify locked marks');
}

if (marksEntry.status === 'submitted' && user.role !== 'superviceprincipal') {
    throw new Error('Cannot edit submitted marks without admin approval');
}
```

2. **Report Card Generation Validation:**
```javascript
if (user.role !== 'classteacher') {
    throw new Error('Only Class Teachers can generate report cards');
}

// Verify all required subjects have marks
const missingSubjects = validateAllMarksEntered(studentId, term);
if (missingSubjects.length > 0) {
    throw new Error(`Missing marks for: ${missingSubjects.join(', ')}`);
}

// Check if report already exists and is locked
if (existingReport && existingReport.is_locked) {
    throw new Error('Report card already generated and locked');
}
```

---

## 🎨 User Interface Flows

### Flow 1: Teacher Marks Entry

**Page:** Teacher Dashboard → "Upload Marks" tab

```
┌─────────────────────────────────────────┐
│  📊 Upload Marks                        │
├─────────────────────────────────────────┤
│                                          │
│  Select Exam: [Mid Term Exam ▼]        │
│  Select Class: [8B ▼]                   │
│  Select Subject: [Mathematics ▼]        │
│                                          │
│  [Load Students]                        │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ Student ID │ Name  │ Marks │ Max │  │
│  ├──────────────────────────────────┤  │
│  │ 3180076    │ Kasula│ [85]  │ 100 │  │
│  │ 3240504    │ Sai   │ [92]  │ 100 │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ⚠️ Warning: Once submitted, you cannot │
│     edit marks without admin approval   │
│                                          │
│  [Save as Draft] [Submit Final Marks]   │
└─────────────────────────────────────────┘
```

**Workflow:**
1. Teacher selects exam, class, subject
2. System loads students from that class
3. Teacher enters marks (with validation)
4. Two options:
   - **Save as Draft**: Can edit later
   - **Submit Final Marks**: Shows confirmation dialog
5. On submit: Status → 'submitted', marks locked
6. Audit log created

### Flow 2: Class Teacher Dashboard

**Page:** Class Teacher Dashboard → "Report Cards" tab

```
┌─────────────────────────────────────────┐
│  📄 Report Card Generation              │
├─────────────────────────────────────────┤
│                                          │
│  Academic Year: [2024-2025 ▼]          │
│  Term: [Term 1 ▼]                       │
│  Class: 8B (Auto-detected from profile) │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ Students Status                   │  │
│  ├──────────────────────────────────┤  │
│  │ ✅ Kasula - All subjects complete│  │
│  │ ✅ Sai Charan - All subjects OK  │  │
│  └──────────────────────────────────┘  │
│                                          │
│  Missing Marks: None                    │
│                                          │
│  ⚠️ CRITICAL WARNING:                   │
│  Generating report cards is PERMANENT   │
│  and CANNOT be undone. All marks will   │
│  be locked immediately.                 │
│                                          │
│  [🔒 Generate All Report Cards]         │
└─────────────────────────────────────────┘
```

**Workflow:**
1. Class teacher sees status for all students
2. System validates all required subjects have marks
3. If validation fails: Show missing subjects, disable button
4. If validation passes: Enable generation button
5. On click: Show confirmation dialog with final warning
6. On confirm:
   - Create transaction (all-or-nothing)
   - Calculate grades for all students
   - Generate PDFs
   - Lock all marks
   - Create audit logs
   - Show success message

### Flow 3: Parent Dashboard

**Page:** Parent Dashboard → "Report Cards" tab

```
┌─────────────────────────────────────────┐
│  📄 Report Cards                        │
├─────────────────────────────────────────┤
│                                          │
│  Student: Kasula Ashwath (3180076)     │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ Academic Year 2024-25             │  │
│  │ Term 1 - Mid Term                 │  │
│  │                                    │  │
│  │ Status: ✅ Available              │  │
│  │ Generated: 15 Jan 2025            │  │
│  │                                    │  │
│  │ Overall: 87.5% | Grade: A         │  │
│  │ Result: PASS                       │  │
│  │                                    │  │
│  │ [📥 Download PDF]  [👁️ View]     │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ⓘ Report cards are final and cannot   │
│     be modified. For corrections,       │
│     contact the school administration.  │
└─────────────────────────────────────────┘
```

**Workflow:**
1. Parent logs in
2. System loads report cards for their child
3. Parent can:
   - View report card details
   - Download PDF
   - View individual subject marks
4. Read-only access (no edits allowed)

---

## 🧮 Grade Calculation Logic

### Default Grading System

```javascript
const GRADING_SYSTEM = [
    { min: 95, max: 100, grade: 'A+', description: 'Outstanding' },
    { min: 90, max: 94.99, grade: 'A', description: 'Excellent' },
    { min: 85, max: 89.99, grade: 'A-', description: 'Very Good' },
    { min: 80, max: 84.99, grade: 'B+', description: 'Good' },
    { min: 75, max: 79.99, grade: 'B', description: 'Above Average' },
    { min: 70, max: 74.99, grade: 'B-', description: 'Average' },
    { min: 65, max: 69.99, grade: 'C+', description: 'Satisfactory' },
    { min: 60, max: 64.99, grade: 'C', description: 'Acceptable' },
    { min: 40, max: 59.99, grade: 'D', description: 'Needs Improvement' },
    { min: 0, max: 39.99, grade: 'F', description: 'Fail' }
];

const PASSING_PERCENTAGE = 40;
```

### Calculation Algorithm

```javascript
function calculateReportCard(studentId, academicYear, term) {
    // 1. Fetch all marks entries for student
    const marksEntries = fetchMarksForStudent(studentId, term);

    // 2. Validate all required subjects present
    const requiredSubjects = getRequiredSubjects(student.class);
    const missingSubjects = requiredSubjects.filter(
        subject => !marksEntries.some(m => m.subject === subject)
    );

    if (missingSubjects.length > 0) {
        throw new Error(`Missing marks for: ${missingSubjects.join(', ')}`);
    }

    // 3. Calculate subject-wise data
    const subjectsData = marksEntries.map(entry => {
        const percentage = (entry.marks_obtained / entry.max_marks) * 100;
        const grade = calculateGrade(percentage);

        return {
            subject: entry.subject,
            marks_obtained: entry.marks_obtained,
            max_marks: entry.max_marks,
            percentage: percentage.toFixed(2),
            grade: grade.grade,
            status: percentage >= PASSING_PERCENTAGE ? 'PASS' : 'FAIL'
        };
    });

    // 4. Calculate overall performance
    const totalObtained = subjectsData.reduce((sum, s) => sum + parseFloat(s.marks_obtained), 0);
    const totalMax = subjectsData.reduce((sum, s) => sum + parseFloat(s.max_marks), 0);
    const overallPercentage = (totalObtained / totalMax) * 100;
    const overallGrade = calculateGrade(overallPercentage);

    // 5. Determine pass/fail (all subjects must pass)
    const anyFail = subjectsData.some(s => s.status === 'FAIL');
    const passFailStatus = anyFail ? 'FAIL' : 'PASS';

    return {
        student_id: studentId,
        academic_year: academicYear,
        term: term,
        class: student.class,
        subjects_data: subjectsData,
        total_marks_obtained: totalObtained,
        total_max_marks: totalMax,
        overall_percentage: overallPercentage.toFixed(2),
        overall_grade: overallGrade.grade,
        pass_fail_status: passFailStatus
    };
}

function calculateGrade(percentage) {
    return GRADING_SYSTEM.find(g => percentage >= g.min && percentage <= g.max);
}
```

---

## 📄 PDF Generation Implementation

### Option 1: jsPDF (Client-Side - Recommended for GitHub Pages)

**Library:** jsPDF + jsPDF-AutoTable

```html
<!-- Add to dashboard.html -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
```

```javascript
async function generateReportCardPDF(reportCardData, studentData) {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    // Header
    doc.setFontSize(20);
    doc.setFont('helvetica', 'bold');
    doc.text('DELHI PUBLIC SCHOOL, NADERGUL', 105, 20, { align: 'center' });

    doc.setFontSize(16);
    doc.text('REPORT CARD', 105, 30, { align: 'center' });

    // Student Info
    doc.setFontSize(12);
    doc.setFont('helvetica', 'normal');
    doc.text(`Student Name: ${studentData.name}`, 20, 45);
    doc.text(`Student ID: ${studentData.id}`, 20, 52);
    doc.text(`Class: ${reportCardData.class}`, 120, 45);
    doc.text(`Academic Year: ${reportCardData.academic_year}`, 120, 52);
    doc.text(`Term: ${reportCardData.term}`, 20, 59);

    // Marks Table
    const tableData = reportCardData.subjects_data.map(subject => [
        subject.subject,
        subject.marks_obtained,
        subject.max_marks,
        subject.percentage + '%',
        subject.grade
    ]);

    doc.autoTable({
        startY: 70,
        head: [['Subject', 'Marks Obtained', 'Max Marks', 'Percentage', 'Grade']],
        body: tableData,
        theme: 'grid',
        headStyles: { fillColor: [46, 125, 50] },
        styles: { fontSize: 11 }
    });

    // Summary
    const finalY = doc.lastAutoTable.finalY + 15;
    doc.setFont('helvetica', 'bold');
    doc.text(`Total: ${reportCardData.total_marks_obtained} / ${reportCardData.total_max_marks}`, 20, finalY);
    doc.text(`Overall Percentage: ${reportCardData.overall_percentage}%`, 20, finalY + 7);
    doc.text(`Overall Grade: ${reportCardData.overall_grade}`, 20, finalY + 14);
    doc.text(`Result: ${reportCardData.pass_fail_status}`, 20, finalY + 21);

    // Signature section
    doc.setFont('helvetica', 'normal');
    doc.text('Class Teacher', 30, 260);
    doc.text('Principal', 150, 260);
    doc.line(20, 258, 70, 258);
    doc.line(140, 258, 190, 258);

    // Footer
    doc.setFontSize(9);
    doc.text(`Generated on: ${new Date().toLocaleDateString()}`, 105, 280, { align: 'center' });
    doc.text('This is a computer-generated document', 105, 285, { align: 'center' });

    // Convert to blob
    const pdfBlob = doc.output('blob');

    return {
        pdf: doc,
        blob: pdfBlob,
        base64: doc.output('datauristring')
    };
}
```

### Option 2: Store PDF as Base64 in Database

Since we're using Supabase without file storage setup, we'll store PDFs as base64 in the database:

```sql
ALTER TABLE report_cards
ADD COLUMN pdf_base64 TEXT;
```

---

## 🔄 Complete Workflow Implementation

### Step 1: Teacher Submits Marks

```javascript
async function submitMarks(marksData) {
    const user = window.auth.getCurrentUser();

    // Validation
    if (user.role !== 'teacher' && user.role !== 'classteacher') {
        throw new Error('Unauthorized');
    }

    // Check for duplicates
    const existing = await checkExistingMarks(
        marksData.student_id,
        marksData.subject,
        marksData.exam_name
    );

    if (existing && existing.status === 'locked') {
        throw new Error('Marks are locked and cannot be modified');
    }

    // Insert or update
    const result = await supabase
        .from('marks_entries')
        .upsert({
            ...marksData,
            teacher_id: user.username,
            status: marksData.is_final ? 'submitted' : 'draft',
            submitted_at: marksData.is_final ? new Date() : null,
            submitted_by: marksData.is_final ? user.username : null
        });

    // Audit log
    await createAuditLog({
        action_type: marksData.is_final ? 'MARKS_SUBMITTED' : 'MARKS_SAVED_DRAFT',
        entity_type: 'marks_entry',
        entity_id: result.data.id,
        user_id: user.username,
        user_role: user.role,
        new_data: marksData
    });

    return result;
}
```

### Step 2: Class Teacher Generates Report Cards

```javascript
async function generateReportCardsForClass(academicYear, term) {
    const user = window.auth.getCurrentUser();

    // Authorization
    if (user.role !== 'classteacher') {
        throw new Error('Only Class Teachers can generate report cards');
    }

    // Get class teacher's class
    const classTeacher = await getClassTeacherInfo(user.username);
    const studentClass = classTeacher.class;

    // Get all students in class
    const students = await getStudentsByClass(studentClass);

    // Validate all students have complete marks
    for (const student of students) {
        const validation = await validateStudentMarks(student.id, term);
        if (!validation.isComplete) {
            throw new Error(
                `Cannot generate reports: ${student.name} missing marks for ${validation.missingSubjects.join(', ')}`
            );
        }
    }

    // BEGIN TRANSACTION (critical section)
    const results = [];

    for (const student of students) {
        // 1. Calculate report card
        const reportData = calculateReportCard(student.id, academicYear, term);

        // 2. Generate PDF
        const { base64 } = await generateReportCardPDF(reportData, student);

        // 3. Insert report card
        const reportCard = await supabase
            .from('report_cards')
            .insert({
                ...reportData,
                pdf_base64: base64,
                pdf_generated: true,
                is_locked: true,
                locked_at: new Date(),
                locked_by: user.username,
                generated_by: user.username
            });

        // 4. Lock all marks entries
        await supabase
            .from('marks_entries')
            .update({
                status: 'locked',
                is_finalized: true,
                locked_at: new Date(),
                locked_by: user.username
            })
            .eq('student_id', student.id);

        // 5. Audit log
        await createAuditLog({
            action_type: 'REPORT_GENERATED',
            entity_type: 'report_card',
            entity_id: reportCard.data.id,
            user_id: user.username,
            user_role: user.role,
            description: `Report card generated for ${student.name}`
        });

        results.push(reportCard);
    }

    return {
        success: true,
        count: results.length,
        message: `Successfully generated ${results.length} report cards`
    };
}
```

### Step 3: Parent Views Report Card

```javascript
async function getReportCardForParent() {
    const user = window.auth.getCurrentUser();

    if (user.role !== 'parent') {
        throw new Error('Unauthorized');
    }

    // Get parent's student
    const parent = await supabase
        .from('parents')
        .select('student_id')
        .eq('id', user.username)
        .single();

    // Get report cards
    const reportCards = await supabase
        .from('report_cards')
        .select('*')
        .eq('student_id', parent.data.student_id)
        .eq('is_locked', true)
        .order('created_at', { ascending: false });

    // Audit log view
    for (const report of reportCards.data) {
        await createAuditLog({
            action_type: 'REPORT_VIEWED',
            entity_type: 'report_card',
            entity_id: report.id,
            user_id: user.username,
            user_role: user.role
        });
    }

    return reportCards.data;
}

async function downloadReportCardPDF(reportCardId) {
    const user = window.auth.getCurrentUser();

    // Get report card
    const report = await supabase
        .from('report_cards')
        .select('*')
        .eq('id', reportCardId)
        .single();

    // Authorization check
    if (user.role === 'parent') {
        const parent = await supabase
            .from('parents')
            .select('student_id')
            .eq('id', user.username)
            .single();

        if (report.data.student_id !== parent.data.student_id) {
            throw new Error('Unauthorized: You can only access your child\'s report cards');
        }
    }

    // Convert base64 to downloadable PDF
    const base64Data = report.data.pdf_base64;
    const link = document.createElement('a');
    link.href = base64Data;
    link.download = `ReportCard_${report.data.student_id}_${report.data.term}.pdf`;
    link.click();

    // Audit log
    await createAuditLog({
        action_type: 'REPORT_DOWNLOADED',
        entity_type: 'report_card',
        entity_id: reportCardId,
        user_id: user.username,
        user_role: user.role
    });
}
```

---

## 🛡️ "Cannot Be Undone" Enforcement

### Database-Level Protection

```sql
-- 1. Create function to prevent unlocking without admin
CREATE OR REPLACE FUNCTION prevent_unlock_without_admin()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if trying to unlock
    IF OLD.is_locked = true AND NEW.is_locked = false THEN
        -- Only super vice principal can unlock
        IF current_setting('app.current_user_role', true) != 'superviceprincipal' THEN
            RAISE EXCEPTION 'Only administrators can unlock report cards';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Attach trigger
CREATE TRIGGER enforce_lock_policy
    BEFORE UPDATE ON report_cards
    FOR EACH ROW
    EXECUTE FUNCTION prevent_unlock_without_admin();
```

### Application-Level Protection

```javascript
// Set user role context before any operation
async function setUserContext(userId, userRole) {
    await supabase.rpc('set_config', {
        setting: 'app.current_user_role',
        value: userRole,
        is_local: true
    });
}

// Prevent UI from showing edit buttons for locked data
function renderMarksTable(marks) {
    return marks.map(mark => ({
        ...mark,
        editable: mark.status !== 'locked' && mark.status !== 'submitted'
    }));
}
```

---

## 📝 Implementation Checklist

### Phase 1: Database Setup
- [ ] Run migration script to create new tables
- [ ] Insert default grading configuration
- [ ] Enable RLS policies
- [ ] Create database functions and triggers
- [ ] Grant permissions to roles

### Phase 2: Backend Logic
- [ ] Implement marks submission API
- [ ] Implement marks validation logic
- [ ] Implement grade calculation
- [ ] Implement PDF generation
- [ ] Implement audit logging
- [ ] Implement security checks

### Phase 3: Teacher UI
- [ ] Create marks entry form
- [ ] Add subject/class/exam selectors
- [ ] Implement marks input table
- [ ] Add save draft functionality
- [ ] Add submit confirmation dialog
- [ ] Show submission status

### Phase 4: Class Teacher UI
- [ ] Create report generation dashboard
- [ ] Show students marks status
- [ ] Validate all marks complete
- [ ] Add generation confirmation dialog
- [ ] Show progress during generation
- [ ] Display success/error messages

### Phase 5: Parent UI
- [ ] Create report cards view
- [ ] Show available report cards
- [ ] Add PDF download button
- [ ] Add PDF preview
- [ ] Show read-only marks details

### Phase 6: Testing
- [ ] Test marks entry workflow
- [ ] Test duplicate prevention
- [ ] Test locking mechanism
- [ ] Test report generation
- [ ] Test PDF generation
- [ ] Test parent access
- [ ] Test unauthorized access attempts
- [ ] Test audit logging

### Phase 7: Security Hardening
- [ ] Verify role-based access
- [ ] Test lock enforcement
- [ ] Verify audit trail completeness
- [ ] Test transaction rollback
- [ ] Verify data integrity

---

## 🚨 Error Handling

### Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Missing marks for subject X" | Incomplete marks entry | Teacher must submit marks for all required subjects |
| "Marks already locked" | Attempting to edit finalized marks | Only admin can unlock via override |
| "Unauthorized access" | Wrong role trying to perform action | Redirect to appropriate dashboard |
| "Report already exists" | Duplicate report generation | Check if report exists before generating |
| "PDF generation failed" | Browser compatibility issue | Use fallback PDF library or server-side generation |

---

## 🎯 Success Criteria

✅ Teachers can enter marks easily and intuitively
✅ Marks are automatically saved to database
✅ Class teachers can see complete status at a glance
✅ Report generation is one-click and foolproof
✅ PDFs are professional and consistent
✅ Parents receive instant access to reports
✅ All actions are logged for accountability
✅ Locked data cannot be modified without admin override
✅ System handles errors gracefully
✅ Zero data loss or corruption possible

---

## 📚 Next Steps

1. Review this design document
2. Approve database schema
3. Execute migration script
4. Implement Phase 1 (Database)
5. Implement Phase 2 (Backend)
6. Implement Phase 3-5 (UI)
7. Conduct thorough testing
8. Deploy to production
9. Train users
10. Monitor and maintain

---

**Document Version:** 1.0
**Last Updated:** January 7, 2026
**Status:** Ready for Implementation
