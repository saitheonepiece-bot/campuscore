# CampusCore - Complete Workflow: Marks to Report Card

## 🔄 End-to-End Process Flow

This document details the COMPLETE workflow from teacher marks entry to parent accessing the final report card.

---

## Phase 1: Teacher Marks Entry

### Step 1.1: Teacher Login & Navigation

```
1. Teacher visits: https://campuscore.example.com
2. Enters credentials:
   - User ID: T001
   - Password: teacher123
3. System authenticates:
   - Queries: SELECT * FROM users WHERE username='T001' AND password='teacher123'
   - Result: {username: 'T001', name: 'English Teacher', role: 'teacher'}
   - Stores in session
4. Redirects to Teacher Dashboard
5. Dashboard renders teacher-specific menu
```

### Step 1.2: Marks Entry Interface

```
Teacher clicks: "Upload Marks" from sidebar

Interface loads:
┌─────────────────────────────────────┐
│  📊 Upload Marks                    │
├─────────────────────────────────────┤
│  Select Exam: [Mid Term 2025 ▼]    │
│  Select Class: [8B ▼]               │
│  Select Subject: [English ▼]        │
│                                      │
│  [Load Students] ← Button           │
└─────────────────────────────────────┘
```

### Step 1.3: Load Students

```javascript
// On "Load Students" click
async function loadStudents(className) {
    const { data: students } = await supabase
        .from('students')
        .select('*')
        .eq('class', className)
        .eq('status', 'active')
        .order('name');

    // Display in table
    renderMarksTable(students);
}
```

**Result:**
```
┌────────────────────────────────────────────────┐
│ Student ID │ Name           │ Marks │ Max Marks│
├────────────────────────────────────────────────┤
│ 3180076    │ Kasula Ashwath │ [85]  │ [100]    │
│ 3240504    │ Sai Charan     │ [92]  │ [100]    │
└────────────────────────────────────────────────┘
│                                                 │
│ ⚠️ Warning: Once submitted, you cannot edit    │
│    marks without admin approval                │
│                                                 │
│ [Save as Draft] [Submit Final Marks]           │
└─────────────────────────────────────────────────┘
```

### Step 1.4: Save as Draft

**Teacher Action:** Enters marks and clicks "Save as Draft"

**System Processing:**
```javascript
async function saveMarks(marksData, isDraft = true) {
    const user = window.auth.getCurrentUser();

    // Validation
    if (marksData.marks_obtained < 0 ||
        marksData.marks_obtained > marksData.max_marks) {
        throw new Error('Invalid marks');
    }

    // Save to database
    const { data, error } = await supabase
        .from('marks_entries')
        .upsert({
            student_id: marksData.student_id,
            subject: marksData.subject,
            exam_name: marksData.exam_name,
            exam_type: marksData.exam_type,
            marks_obtained: marksData.marks_obtained,
            max_marks: marksData.max_marks,
            teacher_id: user.username,
            status: 'draft',  // ← Can edit later
            submitted_at: null,
            submitted_by: null
        }, {
            onConflict: 'student_id,subject,exam_name,exam_type'
        });

    // Create audit log
    await createAuditLog({
        action_type: 'MARKS_SAVED_DRAFT',
        entity_type: 'marks_entry',
        entity_id: data[0].id,
        user_id: user.username,
        user_role: user.role,
        new_data: marksData
    });

    return data[0];
}
```

**Database State:**
```sql
-- marks_entries table
| id | student_id | subject | exam_name     | marks | max | teacher | status | submitted_at |
|----|------------|---------|---------------|-------|-----|---------|--------|--------------|
| 1  | 3180076    | English | Mid Term 2025 | 85    | 100 | T001    | draft  | NULL         |
| 2  | 3240504    | English | Mid Term 2025 | 92    | 100 | T001    | draft  | NULL         |
```

**Teacher sees:** ✅ "Marks saved as draft. You can edit them later."

---

### Step 1.5: Submit Final Marks

**Teacher Action:** Reviews marks and clicks "Submit Final Marks"

**System shows confirmation:**
```
┌─────────────────────────────────────┐
│  ⚠️ CONFIRM SUBMISSION              │
├─────────────────────────────────────┤
│  You are about to submit marks for: │
│  - Exam: Mid Term 2025              │
│  - Subject: English                 │
│  - Class: 8B                        │
│  - Students: 2                      │
│                                      │
│  ⚠️ WARNING:                        │
│  Once submitted, you CANNOT edit    │
│  these marks without admin approval │
│                                      │
│  Are you sure?                      │
│                                      │
│  [Cancel] [Yes, Submit Final Marks] │
└─────────────────────────────────────┘
```

**Teacher confirms → System processes:**

```javascript
async function submitFinalMarks(marksArray) {
    const user = window.auth.getCurrentUser();
    const results = [];

    for (const marks of marksArray) {
        // Update status to 'submitted'
        const { data, error } = await supabase
            .from('marks_entries')
            .update({
                status: 'submitted',  // ← Locked from teacher editing
                submitted_at: new Date().toISOString(),
                submitted_by: user.username
            })
            .eq('id', marks.id);

        // Audit log
        await createAuditLog({
            action_type: 'MARKS_SUBMITTED',
            entity_type: 'marks_entry',
            entity_id: marks.id,
            user_id: user.username,
            user_role: user.role,
            description: `Final marks submitted for student ${marks.student_id}`
        });

        results.push(data);
    }

    return results;
}
```

**Database State After Submission:**
```sql
| id | student_id | subject | exam_name     | marks | max | teacher | status    | submitted_at        | submitted_by |
|----|------------|---------|---------------|-------|-----|---------|-----------|---------------------|--------------|
| 1  | 3180076    | English | Mid Term 2025 | 85    | 100 | T001    | submitted | 2025-01-15 09:30:00 | T001         |
| 2  | 3240504    | English | Mid Term 2025 | 92    | 100 | T001    | submitted | 2025-01-15 09:30:00 | T001         |
```

**Visibility Change:**
- ✅ Class Teacher can now see these marks
- ❌ Teacher T001 cannot edit anymore (unless admin override)

---

## Phase 2: Other Teachers Submit Marks

All subject teachers repeat the process:

```sql
-- After all teachers submit
| id | student_id | subject        | exam_name     | marks | max | teacher | status    |
|----|------------|----------------|---------------|-------|-----|---------|-----------|
| 1  | 3180076    | English        | Mid Term 2025 | 85    | 100 | T001    | submitted |
| 2  | 3180076    | Mathematics    | Mid Term 2025 | 90    | 100 | T002    | submitted |
| 3  | 3180076    | Science        | Mid Term 2025 | 88    | 100 | T003    | submitted |
| 4  | 3180076    | Social Studies | Mid Term 2025 | 82    | 100 | T004    | submitted |
| 5  | 3180076    | Hindi          | Mid Term 2025 | 80    | 100 | T005    | submitted |
| 6  | 3240504    | English        | Mid Term 2025 | 92    | 100 | T001    | submitted |
| 7  | 3240504    | Mathematics    | Mid Term 2025 | 88    | 100 | T002    | submitted |
| 8  | 3240504    | Science        | Mid Term 2025 | 95    | 100 | T003    | submitted |
| 9  | 3240504    | Social Studies | Mid Term 2025 | 85    | 100 | T004    | submitted |
| 10 | 3240504    | Hindi          | Mid Term 2025 | 90    | 100 | T005    | submitted |
```

---

## Phase 3: Class Teacher Review

### Step 3.1: Class Teacher Login

```
1. Class Teacher logs in: CT8B / CLASS123
2. Role detected: 'classteacher'
3. Redirected to Class Teacher Dashboard
4. Clicks "Report Cards" tab
```

### Step 3.2: Report Generation Interface

```
┌─────────────────────────────────────────┐
│  📄 Report Card Generation              │
├─────────────────────────────────────────┤
│  Academic Year: [2024-2025 ▼]          │
│  Term: [Mid Term ▼]                     │
│  Exam: [Mid Term 2025 ▼]                │
│  Exam Type: [mid_term ▼]                │
│  Class: 8B (Auto-detected)              │
│                                          │
│  [Check Status]                         │
└─────────────────────────────────────────┘
```

### Step 3.3: Validation Check

**System queries database:**

```javascript
async function validateAllMarksComplete(className, examName, examType) {
    // Get required subjects for class
    const { data: config } = await supabase
        .from('report_card_config')
        .select('required_subjects')
        .eq('class', className)
        .single();

    const requiredSubjects = config.required_subjects;
    // ["English", "Mathematics", "Science", "Social Studies", "Hindi"]

    // Get all students in class
    const { data: students } = await supabase
        .from('students')
        .select('*')
        .eq('class', className)
        .eq('status', 'active');

    // Check each student
    const validationResults = [];

    for (const student of students) {
        // Get all marks for this student
        const { data: marks } = await supabase
            .from('marks_entries')
            .select('subject, status')
            .eq('student_id', student.id)
            .eq('exam_name', examName)
            .eq('exam_type', examType);

        // Check which subjects are missing
        const submittedSubjects = marks.map(m => m.subject);
        const missingSubjects = requiredSubjects.filter(
            sub => !submittedSubjects.includes(sub)
        );

        validationResults.push({
            student: student,
            submitted: submittedSubjects,
            missing: missingSubjects,
            isComplete: missingSubjects.length === 0,
            allSubmitted: marks.every(m => m.status === 'submitted')
        });
    }

    return validationResults;
}
```

**Result displayed to Class Teacher:**

```
┌─────────────────────────────────────────┐
│  Students Status                        │
├─────────────────────────────────────────┤
│  ✅ Kasula Ashwath (3180076)           │
│     All 5 subjects complete             │
│     Status: Ready for generation        │
│                                          │
│  ✅ Sai Charan (3240504)                │
│     All 5 subjects complete             │
│     Status: Ready for generation        │
│                                          │
│  Missing Marks: None                    │
│                                          │
│  [🔒 Generate All Report Cards]         │
└─────────────────────────────────────────┘
```

**If marks incomplete:**
```
┌─────────────────────────────────────────┐
│  ❌ Kasula Ashwath (3180076)           │
│     Missing: Hindi, Social Studies      │
│     Status: Cannot generate             │
│                                          │
│  Missing Marks: 2 subjects              │
│                                          │
│  [Generate All Report Cards] (DISABLED) │
└─────────────────────────────────────────┘
```

---

## Phase 4: Report Card Generation (CRITICAL)

### Step 4.1: Final Confirmation

**Class Teacher clicks "Generate All Report Cards"**

**System shows FINAL WARNING:**

```
┌─────────────────────────────────────────┐
│  ⚠️ CRITICAL WARNING                    │
├─────────────────────────────────────────┤
│  You are about to generate report cards │
│  for 2 students.                        │
│                                          │
│  ⚠️ THIS ACTION CANNOT BE UNDONE        │
│                                          │
│  Once generated:                        │
│  ✓ All marks will be LOCKED permanently │
│  ✓ Report cards will be FINALIZED       │
│  ✓ Parents will get INSTANT access      │
│  ✗ You CANNOT regenerate or modify      │
│                                          │
│  Only administrators can override this  │
│  in case of critical errors.            │
│                                          │
│  Are you absolutely sure?               │
│                                          │
│  Type "GENERATE" to confirm:            │
│  [_______________]                      │
│                                          │
│  [Cancel] [Confirm Generation]          │
└─────────────────────────────────────────┘
```

### Step 4.2: Generation Process

**Class Teacher types "GENERATE" and confirms**

**System executes (this is THE critical operation):**

```javascript
async function generateReportCardsForClass(academicYear, term, examName, examType, classTeacherId) {
    const user = window.auth.getCurrentUser();

    // Authorization check
    if (user.role !== 'classteacher') {
        throw new Error('Only Class Teachers can generate report cards');
    }

    // Get class teacher's class
    const { data: classTeacher } = await supabase
        .from('class_teachers')
        .select('class')
        .eq('id', user.username)
        .single();

    const studentClass = classTeacher.class;

    // Get all active students in class
    const { data: students } = await supabase
        .from('students')
        .select('*')
        .eq('class', studentClass)
        .eq('status', 'active')
        .order('name');

    // Validate ALL students have complete marks
    for (const student of students) {
        const validation = await validateStudentMarks(
            student.id,
            examName,
            examType
        );

        if (!validation.isComplete) {
            throw new Error(
                `Cannot generate: ${student.name} missing ${validation.missingSubjects.join(', ')}`
            );
        }
    }

    // BEGIN CRITICAL SECTION
    const generatedReports = [];
    const errors = [];

    for (const student of students) {
        try {
            // 1. Calculate report card data
            const reportData = await calculateReportCard(
                student.id,
                academicYear,
                term,
                examName,
                examType
            );

            // 2. Generate PDF
            const { base64 } = await generateReportCardPDF(
                reportData,
                student
            );

            // 3. Insert report card
            const { data: reportCard, error: insertError } = await supabase
                .from('report_cards')
                .insert({
                    student_id: student.id,
                    academic_year: academicYear,
                    term: term,
                    class: studentClass,
                    subjects_data: JSON.stringify(reportData.subjects_data),
                    total_marks_obtained: reportData.total_marks_obtained,
                    total_max_marks: reportData.total_max_marks,
                    overall_percentage: reportData.overall_percentage,
                    overall_grade: reportData.overall_grade,
                    pass_fail_status: reportData.pass_fail_status,
                    pdf_base64: base64,
                    pdf_generated: true,
                    is_locked: true,  // ← LOCKED PERMANENTLY
                    locked_at: new Date().toISOString(),
                    locked_by: user.username,
                    generated_by: user.username,
                    generated_at: new Date().toISOString()
                })
                .select()
                .single();

            if (insertError) throw insertError;

            // 4. LOCK ALL MARKS ENTRIES (PERMANENT)
            const { error: lockError } = await supabase
                .from('marks_entries')
                .update({
                    status: 'locked',        // ← Cannot edit
                    is_finalized: true,      // ← Finalized
                    locked_at: new Date().toISOString(),
                    locked_by: user.username
                })
                .eq('student_id', student.id)
                .eq('exam_name', examName)
                .eq('exam_type', examType);

            if (lockError) throw lockError;

            // 5. Create audit log
            await createAuditLog({
                action_type: 'REPORT_GENERATED',
                entity_type: 'report_card',
                entity_id: reportCard.id,
                user_id: user.username,
                user_role: user.role,
                new_data: reportData,
                description: `Report card generated for ${student.name} (${student.id})`
            });

            generatedReports.push(reportCard);

        } catch (error) {
            errors.push({
                student_id: student.id,
                student_name: student.name,
                error: error.message
            });
        }
    }

    // Return results
    return {
        success: true,
        generated: generatedReports.length,
        total: students.length,
        errors: errors
    };
}
```

### Step 4.3: Grade Calculation Logic

```javascript
async function calculateReportCard(studentId, academicYear, term, examName, examType) {
    // 1. Get student
    const { data: student } = await supabase
        .from('students')
        .select('*')
        .eq('id', studentId)
        .single();

    // 2. Load grading system for class
    const { data: config } = await supabase
        .from('report_card_config')
        .select('*')
        .eq('class', student.class)
        .single();

    const gradeSystem = config.grade_system;
    const passingPercentage = config.passing_percentage;

    // 3. Get all marks
    const { data: marks } = await supabase
        .from('marks_entries')
        .select('*')
        .eq('student_id', studentId)
        .eq('exam_name', examName)
        .eq('exam_type', examType);

    // 4. Calculate subject-wise grades
    const subjectsData = marks.map(mark => {
        const percentage = (mark.marks_obtained / mark.max_marks) * 100;

        // Find grade from grading system
        const gradeInfo = gradeSystem.find(
            g => percentage >= g.min && percentage <= g.max
        );

        return {
            subject: mark.subject,
            marks_obtained: mark.marks_obtained,
            max_marks: mark.max_marks,
            percentage: percentage.toFixed(2),
            grade: gradeInfo.grade,
            description: gradeInfo.description,
            status: percentage >= passingPercentage ? 'PASS' : 'FAIL'
        };
    });

    // 5. Calculate totals
    const totalObtained = subjectsData.reduce(
        (sum, s) => sum + parseFloat(s.marks_obtained), 0
    );
    const totalMax = subjectsData.reduce(
        (sum, s) => sum + parseFloat(s.max_marks), 0
    );
    const overallPercentage = (totalObtained / totalMax) * 100;

    // 6. Overall grade
    const overallGrade = gradeSystem.find(
        g => overallPercentage >= g.min && overallPercentage <= g.max
    );

    // 7. Pass/Fail (must pass ALL subjects)
    const anySubjectFailed = subjectsData.some(s => s.status === 'FAIL');
    const passFailStatus = anySubjectFailed ? 'FAIL' : 'PASS';

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
```

**Example Calculation:**
```javascript
// Input marks for student 3180076
[
    { subject: 'English', marks: 85, max: 100 },
    { subject: 'Mathematics', marks: 90, max: 100 },
    { subject: 'Science', marks: 88, max: 100 },
    { subject: 'Social Studies', marks: 82, max: 100 },
    { subject: 'Hindi', marks: 80, max: 100 }
]

// Calculated result
{
    subjects_data: [
        { subject: 'English', marks: 85, max: 100, percentage: 85.00, grade: 'A-', status: 'PASS' },
        { subject: 'Mathematics', marks: 90, max: 100, percentage: 90.00, grade: 'A', status: 'PASS' },
        { subject: 'Science', marks: 88, max: 100, percentage: 88.00, grade: 'A-', status: 'PASS' },
        { subject: 'Social Studies', marks: 82, max: 100, percentage: 82.00, grade: 'B+', status: 'PASS' },
        { subject: 'Hindi', marks: 80, max: 100, percentage: 80.00, grade: 'B+', status: 'PASS' }
    ],
    total_marks_obtained: 425,
    total_max_marks: 500,
    overall_percentage: 85.00,
    overall_grade: 'A-',
    pass_fail_status: 'PASS'
}
```

---

## Phase 5: PDF Generation

### Step 5.1: PDF Creation with jsPDF

```javascript
async function generateReportCardPDF(reportCardData, studentData) {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    // === HEADER ===
    doc.setFontSize(20);
    doc.setFont('helvetica', 'bold');
    doc.text('DELHI PUBLIC SCHOOL, NADERGUL', 105, 20, { align: 'center' });

    doc.setFontSize(16);
    doc.text('REPORT CARD', 105, 30, { align: 'center' });

    doc.setLineWidth(0.5);
    doc.line(20, 35, 190, 35);

    // === STUDENT INFO ===
    doc.setFontSize(12);
    doc.setFont('helvetica', 'normal');
    doc.text(`Student Name: ${studentData.name}`, 20, 45);
    doc.text(`Student ID: ${studentData.id}`, 20, 52);
    doc.text(`Class: ${reportCardData.class}`, 120, 45);
    doc.text(`Academic Year: ${reportCardData.academic_year}`, 120, 52);
    doc.text(`Term: ${reportCardData.term}`, 20, 59);

    // === MARKS TABLE ===
    const tableData = reportCardData.subjects_data.map(subject => [
        subject.subject,
        subject.marks_obtained.toString(),
        subject.max_marks.toString(),
        subject.percentage + '%',
        subject.grade
    ]);

    doc.autoTable({
        startY: 70,
        head: [['Subject', 'Marks Obtained', 'Maximum Marks', 'Percentage', 'Grade']],
        body: tableData,
        theme: 'grid',
        headStyles: {
            fillColor: [46, 125, 50],  // Green
            textColor: 255,
            fontSize: 11,
            fontStyle: 'bold'
        },
        bodyStyles: {
            fontSize: 10
        },
        alternateRowStyles: {
            fillColor: [245, 245, 245]
        }
    });

    // === SUMMARY ===
    const finalY = doc.lastAutoTable.finalY + 15;

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(12);
    doc.text('Summary', 20, finalY);

    doc.setFont('helvetica', 'normal');
    doc.text(`Total Marks: ${reportCardData.total_marks_obtained} / ${reportCardData.total_max_marks}`, 20, finalY + 8);
    doc.text(`Overall Percentage: ${reportCardData.overall_percentage}%`, 20, finalY + 15);
    doc.text(`Overall Grade: ${reportCardData.overall_grade}`, 20, finalY + 22);

    // Result (colored)
    if (reportCardData.pass_fail_status === 'PASS') {
        doc.setTextColor(0, 128, 0);  // Green
    } else {
        doc.setTextColor(255, 0, 0);  // Red
    }
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(14);
    doc.text(`Result: ${reportCardData.pass_fail_status}`, 20, finalY + 29);
    doc.setTextColor(0, 0, 0);

    // === SIGNATURES ===
    const sigY = 250;
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(10);
    doc.text('Class Teacher', 30, sigY);
    doc.text('Principal', 150, sigY);
    doc.line(20, sigY - 2, 70, sigY - 2);
    doc.line(140, sigY - 2, 190, sigY - 2);

    // === FOOTER ===
    doc.setFontSize(8);
    doc.setFont('helvetica', 'italic');
    const today = new Date().toLocaleDateString('en-IN');
    doc.text(`Generated on: ${today}`, 105, 275, { align: 'center' });
    doc.text('This is a computer-generated document', 105, 280, { align: 'center' });

    // === CONVERT TO BASE64 ===
    const base64 = doc.output('datauristring');

    return {
        pdf: doc,
        base64: base64,
        blob: doc.output('blob')
    };
}
```

**Generated PDF stored as:**
```
pdf_base64: "data:application/pdf;base64,JVBERi0xLjMKJf////8KOCAwIG9iago8PAovVHlwZS..."
```

---

## Phase 6: Automatic Parent Delivery

### Step 6.1: Database State After Generation

```sql
-- report_cards table
| id | student_id | academic_year | term     | overall_% | grade | pass_fail | is_locked | pdf_generated | locked_by | pdf_base64            |
|----|------------|---------------|----------|-----------|-------|-----------|-----------|---------------|-----------|-----------------------|
| 1  | 3180076    | 2024-2025     | Mid Term | 85.00     | A-    | PASS      | true      | true          | CT8B      | data:application/pdf... |
| 2  | 3240504    | 2024-2025     | Mid Term | 90.00     | A     | PASS      | true      | true          | CT8B      | data:application/pdf... |

-- marks_entries (ALL LOCKED)
| id | student_id | subject | status | is_finalized | locked_at           | locked_by |
|----|------------|---------|--------|--------------|---------------------|-----------|
| 1  | 3180076    | English | locked | true         | 2025-01-15 10:30:00 | CT8B      |
| 2  | 3180076    | Math    | locked | true         | 2025-01-15 10:30:00 | CT8B      |
| ...all marks locked...
```

### Step 6.2: Parent Login (Immediate Access)

```
1. Parent logs in: P3180076A / parent123
2. Role detected: 'parent'
3. Dashboard loads
4. Parent clicks "Report Cards"
```

**System queries:**
```javascript
async function getReportCardsForParent() {
    const user = window.auth.getCurrentUser();

    // Get parent's student
    const { data: parent } = await supabase
        .from('parents')
        .select('student_id')
        .eq('id', user.username)
        .single();

    // Get all report cards for this student
    const { data: reportCards } = await supabase
        .from('report_cards')
        .select('*')
        .eq('student_id', parent.student_id)
        .eq('is_locked', true)  // Only show finalized reports
        .order('generated_at', { ascending: false });

    // Audit log
    await createAuditLog({
        action_type: 'REPORT_VIEWED',
        entity_type: 'report_card',
        entity_id: reportCards[0]?.id,
        user_id: user.username,
        user_role: user.role
    });

    return reportCards;
}
```

**Parent sees:**
```
┌─────────────────────────────────────────┐
│  📄 Report Cards                        │
├─────────────────────────────────────────┤
│  Student: Kasula Ashwath (3180076)     │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ Academic Year 2024-25             │  │
│  │ Term: Mid Term                    │  │
│  │                                    │  │
│  │ Status: ✅ Available              │  │
│  │ Generated: 15 Jan 2025, 10:30 AM  │  │
│  │                                    │  │
│  │ Overall: 85% | Grade: A-          │  │
│  │ Result: PASS                       │  │
│  │                                    │  │
│  │ [📥 Download PDF]  [👁️ View]     │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Step 6.3: PDF Download

**Parent clicks "Download PDF"**

```javascript
async function downloadReportCardPDF(reportCardId) {
    const user = window.auth.getCurrentUser();

    // Get report card
    const { data: report } = await supabase
        .from('report_cards')
        .select('*')
        .eq('id', reportCardId)
        .single();

    // Authorization check
    if (user.role === 'parent') {
        const { data: parent } = await supabase
            .from('parents')
            .select('student_id')
            .eq('id', user.username)
            .single();

        if (report.student_id !== parent.student_id) {
            throw new Error('Unauthorized');
        }
    }

    // Download PDF
    const link = document.createElement('a');
    link.href = report.pdf_base64;
    link.download = `ReportCard_${report.student_id}_${report.term}.pdf`;
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

**Result:** Professional PDF downloads instantly to parent's device

---

## Complete Timeline

```
Time: 09:00 AM
├─ Teacher T001 logs in
├─ Enters English marks for 8B
├─ Saves as draft
│
Time: 09:15 AM
├─ Reviews marks
├─ Submits final marks
├─ Marks locked for editing
│
Time: 09:30 AM - 10:00 AM
├─ Other teachers submit their subjects
│
Time: 10:15 AM
├─ Class Teacher CT8B logs in
├─ Clicks "Report Cards"
├─ Validates all marks complete
│
Time: 10:30 AM
├─ Clicks "Generate Report Cards"
├─ Confirms final warning
├─ System generates 2 report cards
├─ PDFs created
├─ ALL marks locked permanently
├─ Report cards saved to database
│
Time: 10:31 AM
├─ Parent P3180076A logs in
├─ Sees new report card available
├─ Downloads PDF
├─ Views results
│
Total time from start to parent access: 1 hour 31 minutes
```

---

**Next Document:** `04_SECURITY_AND_AUDIT.md` - Security measures, permissions, and audit logging
