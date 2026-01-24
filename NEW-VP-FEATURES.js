// ============================================
// NEW VP FEATURES - ADD TO dashboard.html
// ============================================
// Copy these functions to dashboard.html before the closing </script> tag
// Then add the menu items and switch cases as instructed in IMPLEMENTATION-GUIDE.md
// ============================================

// ============================================
// 1. HOMEWORK MANAGEMENT
// ============================================
async function renderHomeworkManagement() {
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    // Fetch all classes
    const { data: classes } = await client
        .from('classes')
        .select('*')
        .order('name');

    // Fetch recent homework
    const { data: homework } = await client
        .from('homework')
        .select('*')
        .order('date', { ascending: false })
        .limit(20);

    contentArea.innerHTML = `
        <div class="card">
            <h3>📚 HOMEWORK MANAGEMENT</h3>
            <p style="color: #666; margin-bottom: 20px;">Create and manage homework assignments</p>

            <!-- Create Homework Form -->
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                <h4>➕ Create New Homework</h4>
                <form id="createHomeworkForm">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div class="form-group">
                            <label>Class *</label>
                            <select id="hwClass" required>
                                <option value="">-- Select Class --</option>
                                ${classes?.map(c => `<option value="${c.name}">${c.name}</option>`).join('')}
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Subject *</label>
                            <input type="text" id="hwSubject" placeholder="e.g., Mathematics" required>
                        </div>
                        <div class="form-group">
                            <label>Title *</label>
                            <input type="text" id="hwTitle" placeholder="e.g., Chapter 5 Exercises" required>
                        </div>
                        <div class="form-group">
                            <label>Due Date *</label>
                            <input type="date" id="hwDueDate" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <textarea id="hwDescription" rows="3" placeholder="Homework details..."></textarea>
                    </div>
                    <button type="submit" class="btn-primary">Create Homework</button>
                </form>
            </div>

            <!-- Recent Homework -->
            <h4>📋 Recent Homework</h4>
            <div style="overflow-x: auto;">
                <table style="width: 100%;">
                    <thead>
                        <tr>
                            <th>Class</th>
                            <th>Subject</th>
                            <th>Title</th>
                            <th>Assigned Date</th>
                            <th>Due Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${homework && homework.length > 0 ? homework.map(hw => `
                            <tr>
                                <td>${hw.class}</td>
                                <td>${hw.subject}</td>
                                <td>${hw.title}</td>
                                <td>${new Date(hw.date).toLocaleDateString()}</td>
                                <td>${hw.due_date ? new Date(hw.due_date).toLocaleDateString() : 'N/A'}</td>
                                <td>
                                    <button onclick="deleteHomework(${hw.id})" class="btn-danger" style="padding: 5px 10px; font-size: 12px;">Delete</button>
                                </td>
                            </tr>
                        `).join('') : '<tr><td colspan="6" style="text-align: center;">No homework assigned yet</td></tr>'}
                    </tbody>
                </table>
            </div>
        </div>
    `;

    document.getElementById('createHomeworkForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const user = window.auth.getCurrentUser();
        const hwClass = document.getElementById('hwClass').value;
        const subject = document.getElementById('hwSubject').value.trim();
        const title = document.getElementById('hwTitle').value.trim();
        const dueDate = document.getElementById('hwDueDate').value;
        const description = document.getElementById('hwDescription').value.trim();

        try {
            showLoading();
            const { error } = await client
                .from('homework')
                .insert([{
                    class: hwClass,
                    subject: subject,
                    title: title,
                    description: description,
                    date: new Date().toISOString().split('T')[0],
                    due_date: dueDate,
                    assigned_by: user.username
                }]);

            if (error) throw error;

            hideLoading();
            showModal('Success', 'Homework created successfully!', 'success');
            renderHomeworkManagement();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to create homework', 'error');
        }
    });
}

window.deleteHomework = async function(homeworkId) {
    showModal('Confirm Delete', 'Are you sure you want to delete this homework?', 'warning', true, async function() {
        try {
            showLoading();
            const client = window.supabaseClient.getClient();
            const { error } = await client
                .from('homework')
                .delete()
                .eq('id', homeworkId);

            if (error) throw error;

            hideLoading();
            showModal('Success', 'Homework deleted successfully!', 'success');
            renderHomeworkManagement();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to delete homework', 'error');
        }
    });
};

// ============================================
// 2. CLASS TIMETABLE MANAGEMENT
// ============================================
async function renderTimetableManagement() {
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    // Fetch all classes
    const { data: classes } = await client
        .from('classes')
        .select('*')
        .order('name');

    contentArea.innerHTML = `
        <div class="card">
            <h3>🗓️ CLASS TIMETABLE MANAGEMENT</h3>
            <p style="color: #666; margin-bottom: 20px;">Manage class timetables</p>

            <!-- Select Class -->
            <div style="margin-bottom: 30px;">
                <label>Select Class:</label>
                <select id="timetableClassSelect" onchange="loadClassTimetable(this.value)" style="padding: 10px; width: 300px; margin-left: 10px;">
                    <option value="">-- Select Class --</option>
                    ${classes?.map(c => `<option value="${c.name}">${c.name}</option>`).join('')}
                </select>
            </div>

            <div id="timetableContent">
                <p style="color: #999;">Select a class to view/edit timetable</p>
            </div>
        </div>
    `;
}

window.loadClassTimetable = async function(className) {
    if (!className) {
        document.getElementById('timetableContent').innerHTML = '<p style="color: #999;">Select a class to view/edit timetable</p>';
        return;
    }

    try {
        showLoading();
        const client = window.supabaseClient.getClient();

        const { data: timetable, error } = await client
            .from('timetables')
            .select('*')
            .eq('class', className)
            .maybeSingle();

        const contentDiv = document.getElementById('timetableContent');

        if (timetable && timetable.periods) {
            const periods = JSON.parse(timetable.periods);
            contentDiv.innerHTML = `
                <h4>Timetable for ${className}</h4>
                <div style="overflow-x: auto;">
                    <table style="width: 100%;">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Monday</th>
                                <th>Tuesday</th>
                                <th>Wednesday</th>
                                <th>Thursday</th>
                                <th>Friday</th>
                                <th>Saturday</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${periods.map(p => `
                                <tr>
                                    <td><strong>${p.time}</strong></td>
                                    <td>${p.mon || '-'}</td>
                                    <td>${p.tue || '-'}</td>
                                    <td>${p.wed || '-'}</td>
                                    <td>${p.thu || '-'}</td>
                                    <td>${p.fri || '-'}</td>
                                    <td>${p.sat || '-'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
                <button onclick="editTimetableJSON('${className}')" class="btn-primary" style="margin-top: 20px;">Edit Timetable (JSON)</button>
            `;
        } else {
            contentDiv.innerHTML = `
                <p>No timetable found for ${className}</p>
                <button onclick="createNewTimetable('${className}')" class="btn-primary">Create Timetable</button>
            `;
        }

        hideLoading();
    } catch (error) {
        hideLoading();
        showModal('Error', error.message || 'Failed to load timetable', 'error');
    }
};

window.editTimetableJSON = function(className) {
    showModal('Edit Timetable',
        `<p>Editing timetable for ${className} requires JSON format.</p>
         <p>Use the existing timetable format or contact admin for advanced editing.</p>`,
        'info');
};

window.createNewTimetable = function(className) {
    showModal('Create Timetable',
        `<p>Creating new timetable for ${className}.</p>
         <p>Contact admin to set up timetable template.</p>`,
        'info');
};

// ============================================
// 3. TEACHER SCHEDULE MANAGEMENT
// ============================================
async function renderTeacherSchedule() {
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    const { data: teachers } = await client
        .from('teachers')
        .select('*')
        .eq('status', 'active')
        .order('name');

    contentArea.innerHTML = `
        <div class="card">
            <h3>👨‍🏫 TEACHER SCHEDULE MANAGEMENT</h3>
            <p style="color: #666; margin-bottom: 20px;">Manage teacher schedules and duties</p>

            <!-- Select Teacher -->
            <div style="margin-bottom: 30px;">
                <label>Select Teacher:</label>
                <select id="teacherScheduleSelect" onchange="loadTeacherSchedule(this.value)" style="padding: 10px; width: 300px; margin-left: 10px;">
                    <option value="">-- Select Teacher --</option>
                    ${teachers?.map(t => `<option value="${t.id}">${t.name} (${t.id})</option>`).join('')}
                </select>
            </div>

            <div id="scheduleContent">
                <p style="color: #999;">Select a teacher to view schedule</p>
            </div>
        </div>
    `;
}

window.loadTeacherSchedule = async function(teacherId) {
    if (!teacherId) {
        document.getElementById('scheduleContent').innerHTML = '<p style="color: #999;">Select a teacher to view schedule</p>';
        return;
    }

    try {
        showLoading();
        const client = window.supabaseClient.getClient();

        // Get teacher duties
        const { data: duties } = await client
            .from('teacher_duties')
            .select('*')
            .eq('teacher_id', teacherId)
            .order('duty_date', { ascending: false })
            .limit(10);

        // Get teacher timetable
        const { data: timetable } = await client
            .from('teacher_timetables')
            .select('*')
            .eq('teacher_id', teacherId)
            .maybeSingle();

        const contentDiv = document.getElementById('scheduleContent');
        contentDiv.innerHTML = `
            <h4>Schedule for ${teacherId}</h4>

            ${timetable ? `
                <h5>Weekly Timetable:</h5>
                <p style="color: #666;">Timetable data available (JSON format)</p>
            ` : '<p>No timetable assigned</p>'}

            <h5 style="margin-top: 30px;">Recent Duties:</h5>
            ${duties && duties.length > 0 ? `
                <table style="width: 100%;">
                    <thead>
                        <tr>
                            <th>Duty</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Location</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${duties.map(d => `
                            <tr>
                                <td>${d.duty_name}</td>
                                <td>${new Date(d.duty_date).toLocaleDateString()}</td>
                                <td>${d.duty_time}</td>
                                <td>${d.location || 'N/A'}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            ` : '<p>No duties assigned</p>'}
        `;

        hideLoading();
    } catch (error) {
        hideLoading();
        showModal('Error', error.message || 'Failed to load teacher schedule', 'error');
    }
};

// ============================================
// 4. EXAM SCHEDULE MANAGEMENT
// ============================================
async function renderExamScheduleManagement() {
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    const { data: classes } = await client
        .from('classes')
        .select('*')
        .order('name');

    const { data: exams } = await client
        .from('exam_schedules')
        .select('*')
        .order('date', { ascending: false })
        .limit(20);

    contentArea.innerHTML = `
        <div class="card">
            <h3>📝 EXAM SCHEDULE MANAGEMENT</h3>
            <p style="color: #666; margin-bottom: 20px;">Create and manage exam schedules</p>

            <!-- Create Exam Form -->
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                <h4>➕ Schedule New Exam</h4>
                <form id="createExamForm">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <div class="form-group">
                            <label>Class *</label>
                            <select id="examClass" required>
                                <option value="">-- Select Class --</option>
                                ${classes?.map(c => `<option value="${c.name}">${c.name}</option>`).join('')}
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Subject *</label>
                            <input type="text" id="examSubject" placeholder="e.g., Mathematics" required>
                        </div>
                        <div class="form-group">
                            <label>Exam Name *</label>
                            <input type="text" id="examName" placeholder="e.g., Mid-Term Exam" required>
                        </div>
                        <div class="form-group">
                            <label>Date *</label>
                            <input type="date" id="examDate" required>
                        </div>
                        <div class="form-group">
                            <label>Time</label>
                            <input type="text" id="examTime" placeholder="e.g., 9:00 AM">
                        </div>
                        <div class="form-group">
                            <label>Duration</label>
                            <input type="text" id="examDuration" placeholder="e.g., 2 hours">
                        </div>
                    </div>
                    <button type="submit" class="btn-primary">Schedule Exam</button>
                </form>
            </div>

            <!-- Exam List -->
            <h4>📋 Scheduled Exams</h4>
            <div style="overflow-x: auto;">
                <table style="width: 100%;">
                    <thead>
                        <tr>
                            <th>Class</th>
                            <th>Exam Name</th>
                            <th>Subject</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Duration</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${exams && exams.length > 0 ? exams.map(exam => `
                            <tr>
                                <td>${exam.class}</td>
                                <td>${exam.exam_name}</td>
                                <td>${exam.subject}</td>
                                <td>${new Date(exam.date).toLocaleDateString()}</td>
                                <td>${exam.time || 'N/A'}</td>
                                <td>${exam.duration || 'N/A'}</td>
                                <td>
                                    <button onclick="deleteExam(${exam.id})" class="btn-danger" style="padding: 5px 10px; font-size: 12px;">Delete</button>
                                </td>
                            </tr>
                        `).join('') : '<tr><td colspan="7" style="text-align: center;">No exams scheduled yet</td></tr>'}
                    </tbody>
                </table>
            </div>
        </div>
    `;

    document.getElementById('createExamForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const examClass = document.getElementById('examClass').value;
        const subject = document.getElementById('examSubject').value.trim();
        const examName = document.getElementById('examName').value.trim();
        const date = document.getElementById('examDate').value;
        const time = document.getElementById('examTime').value.trim();
        const duration = document.getElementById('examDuration').value.trim();

        try {
            showLoading();
            const { error } = await client
                .from('exam_schedules')
                .insert([{
                    class: examClass,
                    subject: subject,
                    exam_name: examName,
                    date: date,
                    time: time || null,
                    duration: duration || null
                }]);

            if (error) throw error;

            hideLoading();
            showModal('Success', 'Exam scheduled successfully!', 'success');
            renderExamScheduleManagement();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to schedule exam', 'error');
        }
    });
}

window.deleteExam = async function(examId) {
    showModal('Confirm Delete', 'Are you sure you want to delete this exam?', 'warning', true, async function() {
        try {
            showLoading();
            const client = window.supabaseClient.getClient();
            const { error } = await client
                .from('exam_schedules')
                .delete()
                .eq('id', examId);

            if (error) throw error;

            hideLoading();
            showModal('Success', 'Exam deleted successfully!', 'success');
            renderExamScheduleManagement();
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to delete exam', 'error');
        }
    });
};

// Functions continue in next message...
