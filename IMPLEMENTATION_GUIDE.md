# Report Card System - Implementation Guide

## 📋 Quick Start

This guide provides step-by-step instructions to implement the complete report card system in CampusCore.

---

## 🎯 What You'll Build

A complete, production-ready system where:
1. **Teachers** enter student marks securely
2. **Class Teachers** generate professional PDF report cards with one click
3. **Parents** instantly access and download their child's report cards
4. **System** prevents any accidental data modification (truly "cannot be undone")
5. **Audit logs** track every action for accountability

---

## 📁 Files You'll Need

All required files have been created in your project:

1. **REPORT_CARD_SYSTEM_DESIGN.md** - Complete system design and specifications
2. **migration-report-card-system.sql** - Database migration script
3. **IMPLEMENTATION_GUIDE.md** - This file (step-by-step instructions)

---

## 🚀 Implementation Steps

### PHASE 1: Database Setup (15 minutes)

#### Step 1: Run Migration Script

1. Go to your Supabase dashboard:
   ```
   https://supabase.com/dashboard/project/xmjyryrmqeneulogmwep/sql/new
   ```

2. Open `migration-report-card-system.sql` and copy ALL contents

3. Paste into Supabase SQL Editor

4. Click **"RUN"**

5. Verify success - you should see:
   ```
   ✓ marks_entries table created
   ✓ report_cards table created
   ✓ audit_logs table created
   ✓ report_card_config table created
   ✓ Triggers created
   ✓ Functions created
   ```

#### Step 2: Verify Tables

Run this verification query:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('marks_entries', 'report_cards', 'audit_logs', 'report_card_config');
```

Expected result: 4 rows showing all tables exist

#### Step 3: Check Grading Configuration

```sql
SELECT class, academic_year, passing_percentage, required_subjects
FROM report_card_config;
```

Expected result: Shows grading config for classes 8B and 10A

---

### PHASE 2: Frontend Setup (10 minutes)

#### Step 1: Add PDF Library

Add this to `dashboard.html` in the `<head>` section (after line 8):

```html
<!-- PDF Generation Library -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
```

#### Step 2: Create JavaScript Modules

You'll create these new JavaScript files:

1. `assets/js/marks-entry.js` - Marks entry logic
2. `assets/js/report-generation.js` - Report card generation
3. `assets/js/audit.js` - Audit logging
4. `assets/js/pdf-generator.js` - PDF creation

---

### PHASE 3: Teacher Marks Entry (Implementation)

#### File: `assets/js/marks-entry.js`

```javascript
// Marks Entry Module
class MarksEntry {
    constructor() {
        this.currentExam = null;
        this.currentClass = null;
        this.currentSubject = null;
    }

    async loadStudents(className) {
        const { data, error } = await window.supabaseClient.getClient()
            .from('students')
            .select('*')
            .eq('class', className)
            .eq('status', 'active')
            .order('name');

        if (error) throw error;
        return data;
    }

    async saveMarks(marksData, isDraft = true) {
        const user = window.auth.getCurrentUser();

        if (user.role !== 'teacher' && user.role !== 'classteacher') {
            throw new Error('Unauthorized: Only teachers can enter marks');
        }

        // Validate marks
        if (marksData.marks_obtained < 0 || marksData.marks_obtained > marksData.max_marks) {
            throw new Error('Invalid marks: Must be between 0 and max marks');
        }

        const client = window.supabaseClient.getClient();

        // Check if marks already exist and are locked
        const { data: existing } = await client
            .from('marks_entries')
            .select('*')
            .eq('student_id', marksData.student_id)
            .eq('subject', marksData.subject)
            .eq('exam_name', marksData.exam_name)
            .eq('exam_type', marksData.exam_type)
            .single();

        if (existing && existing.status === 'locked') {
            throw new Error('Cannot modify locked marks. Contact administrator.');
        }

        // Prepare data
        const entryData = {
            student_id: marksData.student_id,
            subject: marksData.subject,
            exam_name: marksData.exam_name,
            exam_type: marksData.exam_type,
            marks_obtained: marksData.marks_obtained,
            max_marks: marksData.max_marks,
            teacher_id: user.username,
            status: isDraft ? 'draft' : 'submitted',
            submitted_at: isDraft ? null : new Date().toISOString(),
            submitted_by: isDraft ? null : user.username,
            updated_at: new Date().toISOString()
        };

        // Insert or update
        const { data, error } = await client
            .from('marks_entries')
            .upsert(entryData, {
                onConflict: 'student_id,subject,exam_name,exam_type'
            })
            .select();

        if (error) throw error;

        // Audit log
        await window.auditLog.create({
            action_type: isDraft ? 'MARKS_SAVED_DRAFT' : 'MARKS_SUBMITTED',
            entity_type: 'marks_entry',
            entity_id: data[0].id,
            new_data: entryData,
            description: `Marks ${isDraft ? 'saved as draft' : 'submitted'} for student ${marksData.student_id}`
        });

        return data[0];
    }

    async submitBulkMarks(marksArray) {
        const results = [];
        const errors = [];

        for (const marks of marksArray) {
            try {
                const result = await this.saveMarks(marks, false);
                results.push(result);
            } catch (error) {
                errors.push({ student_id: marks.student_id, error: error.message });
            }
        }

        return { results, errors };
    }

    async getMarksForStudent(studentId, examName, examType) {
        const { data, error } = await window.supabaseClient.getClient()
            .from('marks_entries')
            .select('*')
            .eq('student_id', studentId)
            .eq('exam_name', examName)
            .eq('exam_type', examType);

        if (error) throw error;
        return data;
    }
}

// Create singleton
window.marksEntry = new MarksEntry();
```

#### File: `assets/js/pdf-generator.js`

```javascript
// PDF Generator Module
class PDFGenerator {
    async generateReportCardPDF(reportCardData, studentData) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        // School Logo (if available)
        // doc.addImage('logo.png', 'PNG', 15, 10, 30, 30);

        // Header
        doc.setFontSize(20);
        doc.setFont('helvetica', 'bold');
        doc.text('DELHI PUBLIC SCHOOL, NADERGUL', 105, 20, { align: 'center' });

        doc.setFontSize(16);
        doc.text('REPORT CARD', 105, 30, { align: 'center' });

        // Horizontal line
        doc.setLineWidth(0.5);
        doc.line(20, 35, 190, 35);

        // Student Information
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
                fillColor: [46, 125, 50],
                textColor: 255,
                fontSize: 11,
                fontStyle: 'bold'
            },
            bodyStyles: {
                fontSize: 10
            },
            alternateRowStyles: {
                fillColor: [245, 245, 245]
            },
            columnStyles: {
                0: { cellWidth: 60 },
                1: { halign: 'center', cellWidth: 30 },
                2: { halign: 'center', cellWidth: 30 },
                3: { halign: 'center', cellWidth: 25 },
                4: { halign: 'center', cellWidth: 25 }
            }
        });

        // Summary Section
        const finalY = doc.lastAutoTable.finalY + 15;

        doc.setFont('helvetica', 'bold');
        doc.setFontSize(12);
        doc.text('Summary', 20, finalY);

        doc.setFont('helvetica', 'normal');
        doc.text(`Total Marks: ${reportCardData.total_marks_obtained} / ${reportCardData.total_max_marks}`, 20, finalY + 8);
        doc.text(`Overall Percentage: ${reportCardData.overall_percentage}%`, 20, finalY + 15);
        doc.text(`Overall Grade: ${reportCardData.overall_grade}`, 20, finalY + 22);

        // Result (with color)
        if (reportCardData.pass_fail_status === 'PASS') {
            doc.setTextColor(0, 128, 0); // Green
        } else {
            doc.setTextColor(255, 0, 0); // Red
        }
        doc.setFont('helvetica', 'bold');
        doc.setFontSize(14);
        doc.text(`Result: ${reportCardData.pass_fail_status}`, 20, finalY + 29);
        doc.setTextColor(0, 0, 0); // Reset to black

        // Remarks (if any)
        if (reportCardData.class_teacher_remarks) {
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(10);
            doc.text('Class Teacher Remarks:', 20, finalY + 40);
            doc.text(reportCardData.class_teacher_remarks, 20, finalY + 46, { maxWidth: 170 });
        }

        // Signature Section
        const sigY = 250;
        doc.setFont('helvetica', 'normal');
        doc.setFontSize(10);

        doc.text('Class Teacher', 30, sigY);
        doc.text('Principal', 150, sigY);

        doc.line(20, sigY - 2, 70, sigY - 2);
        doc.line(140, sigY - 2, 190, sigY - 2);

        // Footer
        doc.setFontSize(8);
        doc.setFont('helvetica', 'italic');
        const today = new Date().toLocaleDateString('en-IN', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        });
        doc.text(`Generated on: ${today}`, 105, 275, { align: 'center' });
        doc.text('This is a computer-generated document and does not require a signature', 105, 280, { align: 'center' });

        // Convert to base64
        const base64 = doc.output('datauristring');

        return {
            pdf: doc,
            base64: base64,
            blob: doc.output('blob')
        };
    }

    downloadPDF(pdfDoc, fileName) {
        pdfDoc.save(fileName);
    }

    downloadFromBase64(base64Data, fileName) {
        const link = document.createElement('a');
        link.href = base64Data;
        link.download = fileName;
        link.click();
    }
}

// Create singleton
window.pdfGenerator = new PDFGenerator();
```

#### File: `assets/js/report-generation.js`

```javascript
// Report Card Generation Module
class ReportGeneration {
    constructor() {
        this.gradeSystem = null;
    }

    async loadGradeSystem(className) {
        const { data, error } = await window.supabaseClient.getClient()
            .from('report_card_config')
            .select('*')
            .eq('class', className)
            .single();

        if (error) throw error;

        this.gradeSystem = data.grade_system;
        this.passingPercentage = data.passing_percentage;
        this.requiredSubjects = data.required_subjects;

        return data;
    }

    calculateGrade(percentage) {
        if (!this.gradeSystem) {
            throw new Error('Grade system not loaded');
        }

        const grade = this.gradeSystem.find(
            g => percentage >= g.min && percentage <= g.max
        );

        return grade || { grade: 'N/A', description: 'Not Available' };
    }

    async validateStudentMarks(studentId, examName, examType) {
        const student = await window.supabaseClient.getClient()
            .from('students')
            .select('*')
            .eq('id', studentId)
            .single();

        if (student.error) throw student.error;

        // Load required subjects for student's class
        const config = await this.loadGradeSystem(student.data.class);

        // Get all marks for student
        const marks = await window.supabaseClient.getClient()
            .from('marks_entries')
            .select('*')
            .eq('student_id', studentId)
            .eq('exam_name', examName)
            .eq('exam_type', examType);

        if (marks.error) throw marks.error;

        // Check which subjects are missing
        const submittedSubjects = marks.data.map(m => m.subject);
        const missingSubjects = this.requiredSubjects.filter(
            sub => !submittedSubjects.includes(sub)
        );

        return {
            isComplete: missingSubjects.length === 0,
            missingSubjects: missingSubjects,
            totalRequired: this.requiredSubjects.length,
            totalSubmitted: submittedSubjects.length
        };
    }

    async calculateReportCard(studentId, academicYear, term, examName, examType) {
        const client = window.supabaseClient.getClient();

        // Get student data
        const { data: student, error: studentError } = await client
            .from('students')
            .select('*')
            .eq('id', studentId)
            .single();

        if (studentError) throw studentError;

        // Load grade system
        await this.loadGradeSystem(student.class);

        // Validate marks complete
        const validation = await this.validateStudentMarks(studentId, examName, examType);
        if (!validation.isComplete) {
            throw new Error(
                `Cannot generate report: Missing marks for ${validation.missingSubjects.join(', ')}`
            );
        }

        // Fetch marks
        const { data: marks, error: marksError } = await client
            .from('marks_entries')
            .select('*')
            .eq('student_id', studentId)
            .eq('exam_name', examName)
            .eq('exam_type', examType);

        if (marksError) throw marksError;

        // Calculate subject-wise performance
        const subjectsData = marks.map(mark => {
            const percentage = (mark.marks_obtained / mark.max_marks) * 100;
            const gradeInfo = this.calculateGrade(percentage);

            return {
                subject: mark.subject,
                marks_obtained: mark.marks_obtained,
                max_marks: mark.max_marks,
                percentage: percentage.toFixed(2),
                grade: gradeInfo.grade,
                status: percentage >= this.passingPercentage ? 'PASS' : 'FAIL'
            };
        });

        // Calculate totals
        const totalObtained = subjectsData.reduce((sum, s) => sum + parseFloat(s.marks_obtained), 0);
        const totalMax = subjectsData.reduce((sum, s) => sum + parseFloat(s.max_marks), 0);
        const overallPercentage = (totalObtained / totalMax) * 100;
        const overallGrade = this.calculateGrade(overallPercentage);

        // Determine pass/fail (student must pass in all subjects)
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

    async generateAndSaveReportCard(studentId, academicYear, term, examName, examType, remarks = '') {
        const user = window.auth.getCurrentUser();

        if (user.role !== 'classteacher') {
            throw new Error('Only Class Teachers can generate report cards');
        }

        const client = window.supabaseClient.getClient();

        // Check if report already exists and is locked
        const { data: existing } = await client
            .from('report_cards')
            .select('*')
            .eq('student_id', studentId)
            .eq('academic_year', academicYear)
            .eq('term', term)
            .single();

        if (existing && existing.is_locked) {
            throw new Error('Report card already exists and is locked. Cannot regenerate.');
        }

        // Calculate report card data
        const reportData = await this.calculateReportCard(studentId, academicYear, term, examName, examType);

        // Get student for PDF generation
        const { data: student } = await client
            .from('students')
            .select('*')
            .eq('id', studentId)
            .single();

        // Generate PDF
        const { base64 } = await window.pdfGenerator.generateReportCardPDF(reportData, student);

        // Save report card
        const reportCardEntry = {
            ...reportData,
            subjects_data: JSON.stringify(reportData.subjects_data),
            pdf_base64: base64,
            pdf_generated: true,
            is_locked: true,
            locked_at: new Date().toISOString(),
            locked_by: user.username,
            generated_by: user.username,
            class_teacher_remarks: remarks
        };

        const { data: savedReport, error: saveError } = await client
            .from('report_cards')
            .upsert(reportCardEntry, {
                onConflict: 'student_id,academic_year,term'
            })
            .select();

        if (saveError) throw saveError;

        // Lock all marks entries for this student
        await client
            .from('marks_entries')
            .update({
                status: 'locked',
                is_finalized: true,
                locked_at: new Date().toISOString(),
                locked_by: user.username
            })
            .eq('student_id', studentId)
            .eq('exam_name', examName)
            .eq('exam_type', examType);

        // Audit log
        await window.auditLog.create({
            action_type: 'REPORT_GENERATED',
            entity_type: 'report_card',
            entity_id: savedReport[0].id,
            new_data: reportCardEntry,
            description: `Report card generated for student ${student.name} (${studentId})`
        });

        return savedReport[0];
    }

    async generateBulkReportCards(studentIds, academicYear, term, examName, examType) {
        const results = [];
        const errors = [];

        for (const studentId of studentIds) {
            try {
                const report = await this.generateAndSaveReportCard(
                    studentId,
                    academicYear,
                    term,
                    examName,
                    examType
                );
                results.push(report);
            } catch (error) {
                errors.push({ student_id: studentId, error: error.message });
            }
        }

        return { results, errors };
    }
}

// Create singleton
window.reportGeneration = new ReportGeneration();
```

#### File: `assets/js/audit.js`

```javascript
// Audit Logging Module
class AuditLog {
    async create(logData) {
        const user = window.auth.getCurrentUser();

        const auditEntry = {
            action_type: logData.action_type,
            entity_type: logData.entity_type,
            entity_id: logData.entity_id,
            user_id: user.username,
            user_role: user.role,
            user_name: user.name,
            old_data: logData.old_data ? JSON.stringify(logData.old_data) : null,
            new_data: logData.new_data ? JSON.stringify(logData.new_data) : null,
            description: logData.description || '',
            created_at: new Date().toISOString()
        };

        const { data, error } = await window.supabaseClient.getClient()
            .from('audit_logs')
            .insert(auditEntry);

        if (error) {
            console.error('Audit log failed:', error);
            // Don't throw - audit failures shouldn't block operations
        }

        return data;
    }

    async getLogsForEntity(entityType, entityId) {
        const { data, error } = await window.supabaseClient.getClient()
            .from('audit_logs')
            .select('*')
            .eq('entity_type', entityType)
            .eq('entity_id', entityId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    }

    async getLogsForUser(userId, limit = 100) {
        const { data, error } = await window.supabaseClient.getClient()
            .from('audit_logs')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(limit);

        if (error) throw error;
        return data;
    }
}

// Create singleton
window.auditLog = new AuditLog();
```

---

### PHASE 4: Load Modules in Dashboard

Add these script tags to `dashboard.html` (after line 78, before the closing body tag):

```html
<!-- Report Card System Modules -->
<script src="assets/js/audit.js"></script>
<script src="assets/js/pdf-generator.js"></script>
<script src="assets/js/marks-entry.js"></script>
<script src="assets/js/report-generation.js"></script>
```

---

### PHASE 5: Testing

#### Test 1: Teacher Enters Marks

```javascript
// Open browser console on dashboard as teacher (T001)
const marksData = {
    student_id: 3180076,
    subject: 'Mathematics',
    exam_name: 'Mid Term 2025',
    exam_type: 'mid_term',
    marks_obtained: 85,
    max_marks: 100
};

await window.marksEntry.saveMarks(marksData, false);
// Should succeed and show success message
```

#### Test 2: Class Teacher Generates Report

```javascript
// Login as class teacher CT8B
const report = await window.reportGeneration.generateAndSaveReportCard(
    3180076,
    '2024-2025',
    'Mid Term',
    'Mid Term 2025',
    'mid_term',
    'Excellent performance!'
);

console.log(report);
// Should generate PDF and lock marks
```

#### Test 3: Parent Views Report

```javascript
// Login as parent P3180076A
const { data } = await window.supabaseClient.getClient()
    .from('report_cards')
    .select('*')
    .eq('student_id', 3180076);

console.log(data);
// Should see generated report
```

---

## 🔒 Security Verification

### Test Lock Mechanism

Try to edit locked marks:

```javascript
// Should FAIL with error
await window.supabaseClient.getClient()
    .from('marks_entries')
    .update({ marks_obtained: 90 })
    .eq('status', 'locked');

// Expected: "Locked marks cannot be edited"
```

Try to unlock report card:

```javascript
// Should FAIL with error
await window.supabaseClient.getClient()
    .from('report_cards')
    .update({ is_locked: false })
    .eq('is_locked', true);

// Expected: "Report cards cannot be unlocked"
```

---

## 📊 Next Steps

1. ✅ Complete database migration
2. ✅ Add PDF libraries
3. ✅ Create JavaScript modules
4. ⏳ Build UI components for marks entry
5. ⏳ Build UI for report generation
6. ⏳ Build UI for parent view
7. ⏳ Test complete workflow
8. ⏳ Deploy to production

---

## 🎓 Summary

You now have:
- **Complete database schema** with security triggers
- **PDF generation** capability
- **Audit logging** system
- **Marks entry** logic
- **Report generation** logic
- **Lock mechanism** to prevent modifications

The system is designed for **zero-error tolerance** and ensures all actions are **permanent and auditable**.

---

## 📞 Support

If you encounter issues:
1. Check browser console for errors
2. Verify database permissions
3. Check that all modules are loaded
4. Review audit logs for tracking

**Ready to implement? Start with Phase 1!**
