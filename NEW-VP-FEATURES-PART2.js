// ============================================
// NEW VP FEATURES - PART 2
// ============================================
// Continuation of NEW-VP-FEATURES.js
// Add these after the previous functions
// ============================================

// ============================================
// 5. MANUAL MARKS UPLOAD
// ============================================
async function renderManualMarksUpload() {
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    const { data: classes } = await client
        .from('classes')
        .select('*')
        .order('name');

    const { data: students } = await client
        .from('students')
        .select('*')
        .eq('status', 'active')
        .order('name')
        .limit(100);

    contentArea.innerHTML = `
        <div class="card">
            <h3>📊 MANUAL MARKS UPLOAD</h3>
            <p style="color: #666; margin-bottom: 20px;">Upload marks for students manually</p>

            <!-- Upload Form -->
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                <h4>➕ Enter Marks</h4>
                <form id="manualMarksForm">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div class="form-group">
                            <label>Student *</label>
                            <select id="marksStudent" required onchange="loadStudentClass(this.value)">
                                <option value="">-- Select Student --</option>
                                ${students?.map(s => `<option value="${s.id}" data-class="${s.class}">${s.name} (${s.id}) - ${s.class}</option>`).join('')}
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Class</label>
                            <input type="text" id="marksClass" readonly style="background: #e9ecef;">
                        </div>
                        <div class="form-group">
                            <label>Exam Name *</label>
                            <input type="text" id="marksExam" placeholder="e.g., Mid-Term Exam" required>
                        </div>
                        <div class="form-group">
                            <label>Subject *</label>
                            <input type="text" id="marksSubject" placeholder="e.g., Mathematics" required>
                        </div>
                        <div class="form-group">
                            <label>Marks Obtained *</label>
                            <input type="number" id="marksObtained" placeholder="e.g., 85" min="0" required>
                        </div>
                        <div class="form-group">
                            <label>Total Marks *</label>
                            <input type="number" id="marksTotal" placeholder="e.g., 100" min="1" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Remarks</label>
                        <textarea id="marksRemarks" rows="2" placeholder="Optional remarks..."></textarea>
                    </div>
                    <button type="submit" class="btn-primary">Upload Marks</button>
                </form>
            </div>

            <!-- Recent Uploads -->
            <div id="recentMarksDiv">
                <p>Upload marks to see recent entries</p>
            </div>
        </div>
    `;

    document.getElementById('manualMarksForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const user = window.auth.getCurrentUser();
        const studentId = parseInt(document.getElementById('marksStudent').value);
        const examName = document.getElementById('marksExam').value.trim();
        const subject = document.getElementById('marksSubject').value.trim();
        const marksObtained = parseFloat(document.getElementById('marksObtained').value);
        const marksTotal = parseFloat(document.getElementById('marksTotal').value);
        const remarks = document.getElementById('marksRemarks').value.trim();

        // Calculate grade
        const percentage = (marksObtained / marksTotal) * 100;
        let grade = 'F';
        if (percentage >= 90) grade = 'A+';
        else if (percentage >= 80) grade = 'A';
        else if (percentage >= 70) grade = 'B+';
        else if (percentage >= 60) grade = 'B';
        else if (percentage >= 50) grade = 'C';
        else if (percentage >= 40) grade = 'D';

        try {
            showLoading();
            const { error } = await client
                .from('marks_submissions')
                .insert([{
                    student_id: studentId,
                    exam_name: examName,
                    subject: subject,
                    marks: marksObtained,
                    total_marks: marksTotal,
                    submitted_by: user.username
                }]);

            if (error) throw error;

            hideLoading();
            showModal('Success', `Marks uploaded successfully!\n\nMarks: ${marksObtained}/${marksTotal} (${percentage.toFixed(1)}%)\nGrade: ${grade}`, 'success');
            document.getElementById('manualMarksForm').reset();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to upload marks', 'error');
        }
    });
}

window.loadStudentClass = function(studentId) {
    const select = document.getElementById('marksStudent');
    const selected = select.options[select.selectedIndex];
    const studentClass = selected.getAttribute('data-class');
    document.getElementById('marksClass').value = studentClass || '';
};

// ============================================
// 6. BULK STUDENTS UPLOAD
// ============================================
async function renderBulkStudentsUpload() {
    const contentArea = document.getElementById('contentArea');

    contentArea.innerHTML = `
        <div class="card">
            <h3>📤 BULK STUDENTS UPLOAD</h3>
            <p style="color: #666; margin-bottom: 20px;">Upload multiple students at once from CSV/Excel</p>

            <!-- Instructions -->
            <div style="background: #e3f2fd; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                <h4>📋 Instructions:</h4>
                <ol style="margin: 10px 0; padding-left: 20px;">
                    <li>Download the template CSV file below</li>
                    <li>Fill in student data (ID, Name, Class, Parent Name, Phone)</li>
                    <li>Save as CSV or keep as Excel (.xlsx)</li>
                    <li>Upload the file using the form below</li>
                    <li>Review the preview before importing</li>
                </ol>
                <button onclick="downloadTemplate()" class="btn-secondary">📥 Download Template (CSV)</button>
            </div>

            <!-- Upload Form -->
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                <h4>➕ Upload File</h4>
                <form id="bulkUploadForm">
                    <div class="form-group">
                        <label>Select File *</label>
                        <input type="file" id="bulkFile" accept=".csv,.xlsx,.xls,.txt" required>
                        <small style="color: #666; display: block; margin-top: 5px;">
                            Accepts: CSV (.csv), Excel (.xlsx, .xls), or Text (.txt)
                        </small>
                    </div>
                    <button type="submit" class="btn-primary">Parse & Preview</button>
                </form>
            </div>

            <!-- Preview Area -->
            <div id="previewArea" style="display: none;">
                <h4>📋 Preview Data</h4>
                <p style="color: #666;">Review the data below before importing:</p>
                <div id="previewTable"></div>
                <button onclick="confirmBulkImport()" class="btn-primary" style="margin-top: 20px;">✅ Confirm & Import All</button>
                <button onclick="cancelBulkImport()" class="btn-secondary" style="margin-top: 20px; margin-left: 10px;">❌ Cancel</button>
            </div>
        </div>
    `;

    document.getElementById('bulkUploadForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const fileInput = document.getElementById('bulkFile');
        const file = fileInput.files[0];

        if (!file) {
            showModal('Error', 'Please select a file', 'error');
            return;
        }

        try {
            showLoading();
            const text = await file.text();
            const students = parseCSV(text);

            if (students.length === 0) {
                throw new Error('No valid data found in file');
            }

            // Store in window for later import
            window.bulkStudentsData = students;

            // Show preview
            const previewDiv = document.getElementById('previewArea');
            const tableDiv = document.getElementById('previewTable');

            tableDiv.innerHTML = `
                <p><strong>${students.length} students found</strong></p>
                <div style="overflow-x: auto; max-height: 400px;">
                    <table style="width: 100%;">
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Name</th>
                                <th>Class</th>
                                <th>Parent Name</th>
                                <th>Parent Phone</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${students.map(s => `
                                <tr>
                                    <td>${s.id}</td>
                                    <td>${s.name}</td>
                                    <td>${s.class}</td>
                                    <td>${s.parentName || 'N/A'}</td>
                                    <td>${s.parentPhone || 'N/A'}</td>
                                    <td><span style="color: #27ae60;">✓ Valid</span></td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `;

            previewDiv.style.display = 'block';
            hideLoading();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to parse file', 'error');
        }
    });
}

// Helper function to parse CSV
function parseCSV(text) {
    const lines = text.trim().split('\n');
    const students = [];

    // Skip header row
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;

        const parts = line.split(',').map(p => p.trim().replace(/^["']|["']$/g, ''));

        if (parts.length >= 3) {
            students.push({
                id: parts[0],
                name: parts[1],
                class: parts[2],
                parentName: parts[3] || '',
                parentPhone: parts[4] || ''
            });
        }
    }

    return students;
}

window.downloadTemplate = function() {
    const csv = `Student ID,Student Name,Class,Parent Name,Parent Phone
4000001,Test Student 1,8B,Parent 1,9876543210
4000002,Test Student 2,10A,Parent 2,9876543211
4000003,Test Student 3,8B,Parent 3,9876543212`;

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'students_template.csv';
    a.click();
    window.URL.revokeObjectURL(url);

    showModal('Success', 'Template downloaded! Fill it with student data and upload.', 'success');
};

window.confirmBulkImport = async function() {
    const students = window.bulkStudentsData;
    if (!students || students.length === 0) {
        showModal('Error', 'No data to import', 'error');
        return;
    }

    try {
        showLoading();
        const client = window.supabaseClient.getClient();
        let successCount = 0;
        let errorCount = 0;

        for (const student of students) {
            try {
                const parentId = `P${student.id}A`;

                // Insert student
                const { error: studentError } = await client
                    .from('students')
                    .insert([{
                        id: parseInt(student.id),
                        name: student.name,
                        class: student.class,
                        parent_id: parentId,
                        status: 'active'
                    }]);

                if (studentError) throw studentError;

                // Insert parent
                if (student.parentName) {
                    await client.from('parents').insert([{
                        id: parentId,
                        name: student.parentName,
                        student_id: parseInt(student.id),
                        phone: student.parentPhone || null
                    }]);

                    // Insert user
                    await client.from('users').insert([{
                        username: parentId,
                        password: 'parent123',
                        name: student.parentName,
                        role: 'parent'
                    }]);
                }

                successCount++;
            } catch (err) {
                console.error(`Failed to import student ${student.id}:`, err);
                errorCount++;
            }
        }

        hideLoading();
        showModal('Import Complete',
            `✅ Imported: ${successCount} students\n❌ Failed: ${errorCount} students\n\nAll parent passwords: parent123`,
            'success');

        // Reset
        window.bulkStudentsData = null;
        document.getElementById('previewArea').style.display = 'none';
        document.getElementById('bulkUploadForm').reset();
    } catch (error) {
        hideLoading();
        showModal('Error', error.message || 'Bulk import failed', 'error');
    }
};

window.cancelBulkImport = function() {
    window.bulkStudentsData = null;
    document.getElementById('previewArea').style.display = 'none';
    document.getElementById('bulkUploadForm').reset();
};

// ============================================
// 7. MARKS APPROVAL SYSTEM
// ============================================
async function renderMarksApproval() {
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    // Fetch all pending marks (assuming we have a status field or use created_at)
    const { data: pendingMarks } = await client
        .from('marks_submissions')
        .select(`
            *,
            students (name, class)
        `)
        .order('created_at', { ascending: false })
        .limit(50);

    contentArea.innerHTML = `
        <div class="card">
            <h3>✅ MARKS APPROVAL SYSTEM</h3>
            <p style="color: #666; margin-bottom: 20px;">Review and approve pending marks submissions</p>

            <!-- Stats -->
            <div class="performance-overview" style="margin-bottom: 30px;">
                <div class="perf-stat">
                    <div class="perf-value">${pendingMarks?.length || 0}</div>
                    <div class="perf-label">📋 Total Submissions</div>
                    <div class="perf-sublabel">Pending review</div>
                </div>
                <div class="perf-stat">
                    <div class="perf-value">${pendingMarks?.filter(m => !m.approved_at).length || 0}</div>
                    <div class="perf-label">⏳ Pending</div>
                    <div class="perf-sublabel">Need approval</div>
                </div>
                <div class="perf-stat">
                    <div class="perf-value">${pendingMarks?.filter(m => m.approved_at).length || 0}</div>
                    <div class="perf-label">✓ Approved</div>
                    <div class="perf-sublabel">Completed</div>
                </div>
            </div>

            <!-- Pending Marks Table -->
            <h4>📋 Marks Submissions</h4>
            <div style="overflow-x: auto;">
                <table style="width: 100%;">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Class</th>
                            <th>Exam</th>
                            <th>Subject</th>
                            <th>Marks</th>
                            <th>Percentage</th>
                            <th>Submitted By</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${pendingMarks && pendingMarks.length > 0 ? pendingMarks.map(mark => {
                            const percentage = mark.total_marks ? ((mark.marks / mark.total_marks) * 100).toFixed(1) : 'N/A';
                            const isApproved = mark.approved_at != null;

                            return `
                                <tr>
                                    <td>${mark.students?.name || 'Unknown'}</td>
                                    <td>${mark.students?.class || 'N/A'}</td>
                                    <td>${mark.exam_name}</td>
                                    <td>${mark.subject}</td>
                                    <td><strong>${mark.marks}/${mark.total_marks}</strong></td>
                                    <td>${percentage}%</td>
                                    <td>${mark.submitted_by || 'System'}</td>
                                    <td>
                                        ${isApproved
                                            ? '<span style="color: #27ae60;">✓ Approved</span>'
                                            : '<span style="color: #f39c12;">⏳ Pending</span>'}
                                    </td>
                                    <td>
                                        ${!isApproved
                                            ? `<button onclick="approveMarks(${mark.id})" class="btn-primary" style="padding: 5px 10px; font-size: 12px;">Approve</button>`
                                            : '-'}
                                    </td>
                                </tr>
                            `;
                        }).join('') : '<tr><td colspan="9" style="text-align: center;">No marks submissions found</td></tr>'}
                    </tbody>
                </table>
            </div>
        </div>
    `;
}

window.approveMarks = async function(markId) {
    showModal('Confirm Approval', 'Approve this marks entry?', 'info', true, async function() {
        try {
            showLoading();
            const client = window.supabaseClient.getClient();
            const user = window.auth.getCurrentUser();

            const { error } = await client
                .from('marks_submissions')
                .update({
                    approved_at: new Date().toISOString(),
                    approved_by: user.username
                })
                .eq('id', markId);

            if (error) throw error;

            hideLoading();
            showModal('Success', 'Marks approved successfully!', 'success');
            renderMarksApproval();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to approve marks', 'error');
        }
    });
};

// ============================================
// END OF PART 2
// ============================================
