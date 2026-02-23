// ========== SHUFFLE STUDENTS FEATURE ==========
// Insert this code BEFORE the "async function renderRemoveStudent()" function (around line 8170)

// PIN verification helper function for VP features
async function verifyVPPin(pinType, enteredPin) {
    const client = window.supabaseClient.getClient();
    const currentUser = window.auth.getCurrentUser();

    // Get stored PINs from users table
    const { data: userData, error } = await client
        .from('users')
        .select('pin_open, pin_shuffle, pin_export')
        .eq('username', currentUser.username)
        .maybeSingle();

    if (error) {
        console.error('Error fetching PINs:', error);
        return false;
    }

    // Default PINs if not set in database
    const defaultPins = {
        open: 'VP321',
        shuffle: 'VP123',
        export: 'VP000'
    };

    const storedPins = {
        open: userData?.pin_open || defaultPins.open,
        shuffle: userData?.pin_shuffle || defaultPins.shuffle,
        export: userData?.pin_export || defaultPins.export
    };

    return storedPins[pinType] === enteredPin;
}

// Shuffle Students function for VPs
async function renderShuffleStudents() {
    const contentArea = document.getElementById('contentArea');
    const currentUser = window.auth.getCurrentUser();

    // Check if user is VP/SVP/Hassan
    if (!['viceprincipal', 'superviceprincipal', 'hassan'].includes(currentUser.role)) {
        contentArea.innerHTML = `
            <div class="card">
                <h3>🔀 Shuffle Students</h3>
                <p style="color: #e74c3c;">Access denied. This feature is only available for Vice Principals.</p>
            </div>
        `;
        return;
    }

    // Show PIN entry screen
    contentArea.innerHTML = `
        <div class="card">
            <h3>🔀 Shuffle Students</h3>
            <p style="color: #666; margin-bottom: 20px;">
                This feature allows you to shuffle and redistribute students across sections within a grade.
            </p>

            <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <strong>⚠️ Security Protected Feature</strong>
                <p style="margin-top: 8px; color: #856404;">Please enter the opening PIN to access this feature.</p>
            </div>

            <div style="max-width: 400px;">
                <div class="form-group">
                    <label>Enter Opening PIN:</label>
                    <input type="password" id="openingPin" placeholder="Enter PIN" style="width: 100%;">
                </div>
                <button class="btn-primary" onclick="verifyAndOpenShuffleStudents()">Access Shuffle Students</button>
            </div>
        </div>
    `;
}

// Verify PIN and show shuffle interface
window.verifyAndOpenShuffleStudents = async function() {
    const pin = document.getElementById('openingPin').value.trim();

    if (!pin) {
        showModal('Error', 'Please enter the opening PIN', 'error');
        return;
    }

    try {
        showLoading();
        const isValid = await verifyVPPin('open', pin);
        hideLoading();

        if (!isValid) {
            showModal('Error', 'Invalid PIN. Access denied.', 'error');
            return;
        }

        // PIN is valid, show the shuffle interface
        showShuffleInterface();
    } catch (error) {
        hideLoading();
        showModal('Error', 'Error verifying PIN: ' + error.message, 'error');
    }
};

// Show shuffle interface after PIN verification
async function showShuffleInterface() {
    const contentArea = document.getElementById('contentArea');

    contentArea.innerHTML = `
        <div class="card">
            <h3>🔀 Shuffle Students - Select Grade</h3>
            <p style="color: #666; margin-bottom: 20px;">
                Select a grade to shuffle students across sections.
            </p>

            <div style="max-width: 500px;">
                <div class="form-group">
                    <label>Select Grade:</label>
                    <select id="gradeSelect" style="width: 100%;">
                        <option value="">-- Select Grade --</option>
                        <option value="6">Grade 6</option>
                        <option value="7">Grade 7</option>
                        <option value="8">Grade 8</option>
                        <option value="9">Grade 9</option>
                        <option value="10">Grade 10</option>
                    </select>
                </div>
                <button class="btn-primary" onclick="loadGradeStudents()">Load Students</button>
                <button class="btn-secondary" onclick="renderTab('shufflestudents')">Cancel</button>
            </div>
        </div>
    `;
}

// Load students for selected grade
window.loadGradeStudents = async function() {
    const grade = document.getElementById('gradeSelect').value;

    if (!grade) {
        showModal('Error', 'Please select a grade', 'error');
        return;
    }

    try {
        showLoading();
        const client = window.supabaseClient.getClient();

        // Fetch all students in the selected grade
        const { data: students, error } = await client
            .from('students')
            .select('*')
            .ilike('class', `${grade}%`)
            .eq('status', 'active')
            .order('class', { ascending: true })
            .order('name', { ascending: true });

        if (error) throw error;

        hideLoading();

        if (!students || students.length === 0) {
            showModal('Info', `No active students found in Grade ${grade}`, 'info');
            return;
        }

        // Group students by current class/section
        const studentsByClass = {};
        students.forEach(student => {
            const className = student.class;
            if (!studentsByClass[className]) {
                studentsByClass[className] = [];
            }
            studentsByClass[className].push(student);
        });

        // Display current distribution
        displayCurrentDistribution(grade, students, studentsByClass);

    } catch (error) {
        hideLoading();
        showModal('Error', 'Error loading students: ' + error.message, 'error');
    }
};

// Display current distribution
function displayCurrentDistribution(grade, students, studentsByClass) {
    const contentArea = document.getElementById('contentArea');

    const classNames = Object.keys(studentsByClass).sort();

    contentArea.innerHTML = `
        <div class="card">
            <h3>🔀 Shuffle Students - Grade ${grade}</h3>
            <p style="color: #666;">Total Students: <strong>${students.length}</strong></p>

            <div style="margin-top: 20px;">
                <h4>Current Distribution:</h4>
                <table style="width: 100%; margin-top: 15px;">
                    <thead>
                        <tr>
                            <th>Class/Section</th>
                            <th>Number of Students</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${classNames.map(className => `
                            <tr>
                                <td><strong>${className}</strong></td>
                                <td>${studentsByClass[className].length}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            </div>

            <div style="margin-top: 30px;">
                <h4>All Students:</h4>
                <div style="max-height: 300px; overflow-y: auto; margin-top: 15px; border: 1px solid #ddd; border-radius: 5px;">
                    <table style="width: 100%;">
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Name</th>
                                <th>Current Class</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${students.map(s => `
                                <tr>
                                    <td>${s.id}</td>
                                    <td>${s.name}</td>
                                    <td><span class="badge badge-normal">${s.class}</span></td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            </div>

            <div style="margin-top: 30px; background: #fff3cd; padding: 15px; border-radius: 8px;">
                <strong>⚠️ Shuffle Confirmation Required</strong>
                <p style="margin-top: 8px; color: #856404;">Click the button below to shuffle these students. You will need to enter the Reshuffle PIN.</p>
            </div>

            <div class="btn-group" style="margin-top: 20px;">
                <button class="btn-primary" onclick="promptShufflePin(${grade})">Shuffle Students</button>
                <button class="btn-secondary" onclick="showShuffleInterface()">Back</button>
            </div>
        </div>
    `;

    // Store students in window for later use
    window.currentGradeStudents = { grade, students };
}

// Prompt for shuffle PIN
window.promptShufflePin = async function(grade) {
    const contentArea = document.getElementById('contentArea');

    contentArea.innerHTML = `
        <div class="card">
            <h3>🔀 Shuffle Students - Confirm Action</h3>

            <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <strong>⚠️ Reshuffle PIN Required</strong>
                <p style="margin-top: 8px; color: #856404;">Please enter the Reshuffle PIN to proceed with shuffling Grade ${grade} students.</p>
            </div>

            <div style="max-width: 400px;">
                <div class="form-group">
                    <label>Enter Reshuffle PIN:</label>
                    <input type="password" id="reshufflePin" placeholder="Enter PIN" style="width: 100%;">
                </div>
                <div class="btn-group">
                    <button class="btn-primary" onclick="executeShuffle()">Confirm Shuffle</button>
                    <button class="btn-secondary" onclick="loadGradeStudents()">Cancel</button>
                </div>
            </div>
        </div>
    `;
};

// Execute the shuffle
window.executeShuffle = async function() {
    const pin = document.getElementById('reshufflePin').value.trim();

    if (!pin) {
        showModal('Error', 'Please enter the reshuffle PIN', 'error');
        return;
    }

    try {
        showLoading();
        const isValid = await verifyVPPin('shuffle', pin);

        if (!isValid) {
            hideLoading();
            showModal('Error', 'Invalid Reshuffle PIN. Action cancelled.', 'error');
            return;
        }

        // Perform the shuffle
        const { grade, students } = window.currentGradeStudents;

        // Get unique sections from current students
        const sections = [...new Set(students.map(s => s.class))].sort();
        const numSections = sections.length;

        if (numSections === 0) {
            hideLoading();
            showModal('Error', 'No sections found for this grade', 'error');
            return;
        }

        // Shuffle students randomly
        const shuffledStudents = [...students].sort(() => Math.random() - 0.5);

        // Calculate students per section (balanced distribution)
        const studentsPerSection = Math.floor(students.length / numSections);
        const remainder = students.length % numSections;

        // Assign students to sections
        const newDistribution = [];
        let currentIndex = 0;

        for (let i = 0; i < numSections; i++) {
            const sectionSize = studentsPerSection + (i < remainder ? 1 : 0);
            const sectionLetter = sections[i].replace(/^\d+/, ''); // Extract letter (e.g., 'A' from '8A')
            const sectionStudents = shuffledStudents.slice(currentIndex, currentIndex + sectionSize);

            sectionStudents.forEach(student => {
                newDistribution.push({
                    studentId: student.id,
                    studentName: student.name,
                    oldClass: student.class,
                    newClass: `${grade}${sectionLetter}`
                });
            });

            currentIndex += sectionSize;
        }

        hideLoading();

        // Store the shuffle result
        window.shuffleResult = newDistribution;

        // Display results
        displayShuffleResults(grade, newDistribution);

    } catch (error) {
        hideLoading();
        showModal('Error', 'Error during shuffle: ' + error.message, 'error');
    }
};

// Display shuffle results
function displayShuffleResults(grade, newDistribution) {
    const contentArea = document.getElementById('contentArea');

    // Group by new class
    const byNewClass = {};
    newDistribution.forEach(item => {
        if (!byNewClass[item.newClass]) {
            byNewClass[item.newClass] = [];
        }
        byNewClass[item.newClass].push(item);
    });

    const classes = Object.keys(byNewClass).sort();

    contentArea.innerHTML = `
        <div class="card">
            <h3>✅ Shuffle Complete - Grade ${grade}</h3>
            <p style="color: #27ae60; font-weight: bold;">Students have been shuffled successfully!</p>
            <p style="color: #666;">Total Students: ${newDistribution.length}</p>

            <div style="margin-top: 20px;">
                <h4>New Distribution Summary:</h4>
                <table style="width: 100%; margin-top: 15px;">
                    <thead>
                        <tr>
                            <th>Class/Section</th>
                            <th>Number of Students</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${classes.map(className => `
                            <tr>
                                <td><strong>${className}</strong></td>
                                <td>${byNewClass[className].length}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            </div>

            <div style="margin-top: 30px;">
                <h4>Detailed Student List:</h4>
                ${classes.map(className => `
                    <div style="margin-top: 20px;">
                        <h5 style="background: #3498db; color: white; padding: 10px; border-radius: 5px;">${className} (${byNewClass[className].length} students)</h5>
                        <table style="width: 100%; margin-top: 10px;">
                            <thead>
                                <tr>
                                    <th>Student ID</th>
                                    <th>Name</th>
                                    <th>Previous Class</th>
                                    <th>New Class</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${byNewClass[className].map(s => `
                                    <tr>
                                        <td>${s.studentId}</td>
                                        <td>${s.studentName}</td>
                                        <td><span class="badge badge-normal">${s.oldClass}</span></td>
                                        <td><span class="badge badge-success">${s.newClass}</span></td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                `).join('')}
            </div>

            <div style="margin-top: 30px; background: #e8f5e9; padding: 15px; border-radius: 8px;">
                <strong>📊 Actions Available:</strong>
                <ul style="margin-top: 10px; color: #2e7d32;">
                    <li>Export the results to PDF for records</li>
                    <li>Shuffle again if you're not satisfied with the distribution</li>
                    <li>Apply changes to update student records in the database</li>
                </ul>
            </div>

            <div class="btn-group" style="margin-top: 20px;">
                <button class="btn-primary" onclick="promptExportPDF()">Export to PDF</button>
                <button class="btn-secondary" onclick="applyShuffleChanges()">Apply Changes to Database</button>
                <button class="btn-secondary" onclick="promptShufflePin(${grade})">Shuffle Again</button>
                <button class="btn-secondary" onclick="showShuffleInterface()">Start Over</button>
            </div>
        </div>
    `;
}

// Prompt for export PIN
window.promptExportPDF = async function() {
    const pin = prompt('Enter Export PIN to generate PDF:');

    if (!pin) {
        return;
    }

    try {
        showLoading();
        const isValid = await verifyVPPin('export', pin);

        if (!isValid) {
            hideLoading();
            showModal('Error', 'Invalid Export PIN. Export cancelled.', 'error');
            return;
        }

        hideLoading();

        // Generate and print PDF
        exportShuffleToPDF();

    } catch (error) {
        hideLoading();
        showModal('Error', 'Error verifying PIN: ' + error.message, 'error');
    }
};

// Export shuffle results to PDF using print
function exportShuffleToPDF() {
    const { grade } = window.currentGradeStudents;
    const newDistribution = window.shuffleResult;

    // Group by new class
    const byNewClass = {};
    newDistribution.forEach(item => {
        if (!byNewClass[item.newClass]) {
            byNewClass[item.newClass] = [];
        }
        byNewClass[item.newClass].push(item);
    });

    const classes = Object.keys(byNewClass).sort();

    // Create a new window for printing
    const printWindow = window.open('', '', 'width=800,height=600');
    printWindow.document.write(`
        <html>
        <head>
            <title>Student Shuffle Results - Grade ${grade}</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    padding: 20px;
                    color: #333;
                }
                h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
                h2 { color: #3498db; margin-top: 30px; }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin-top: 15px;
                    margin-bottom: 30px;
                }
                th, td {
                    border: 1px solid #ddd;
                    padding: 10px;
                    text-align: left;
                }
                th {
                    background-color: #3498db;
                    color: white;
                }
                tr:nth-child(even) {
                    background-color: #f8f9fa;
                }
                .summary {
                    background: #e8f5e9;
                    padding: 15px;
                    border-radius: 5px;
                    margin: 20px 0;
                }
                .footer {
                    margin-top: 40px;
                    padding-top: 20px;
                    border-top: 2px solid #ddd;
                    color: #666;
                    font-size: 12px;
                }
            </style>
        </head>
        <body>
            <h1>Student Shuffle Results - Grade ${grade}</h1>
            <p><strong>Date:</strong> ${new Date().toLocaleDateString()} ${new Date().toLocaleTimeString()}</p>
            <p><strong>Total Students:</strong> ${newDistribution.length}</p>

            <div class="summary">
                <h3>Distribution Summary</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Class/Section</th>
                            <th>Number of Students</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${classes.map(className => `
                            <tr>
                                <td><strong>${className}</strong></td>
                                <td>${byNewClass[className].length}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            </div>

            ${classes.map(className => `
                <h2>${className} (${byNewClass[className].length} students)</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Student ID</th>
                            <th>Name</th>
                            <th>Previous Class</th>
                            <th>New Class</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${byNewClass[className].map(s => `
                            <tr>
                                <td>${s.studentId}</td>
                                <td>${s.studentName}</td>
                                <td>${s.oldClass}</td>
                                <td>${s.newClass}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `).join('')}

            <div class="footer">
                <p>This document was generated by CampusCore Student Shuffling System</p>
                <p>Generated on: ${new Date().toLocaleString()}</p>
            </div>
        </body>
        </html>
    `);

    printWindow.document.close();

    // Wait a moment for content to load, then print
    setTimeout(() => {
        printWindow.print();
        showModal('Success', 'PDF export initiated. Please use your browser\'s print dialog to save as PDF.', 'success');
    }, 500);
}

// Apply shuffle changes to database
window.applyShuffleChanges = async function() {
    if (!confirm('Are you sure you want to apply these changes to the database? This will update all student class assignments.')) {
        return;
    }

    try {
        showLoading();
        const client = window.supabaseClient.getClient();
        const newDistribution = window.shuffleResult;

        // Update each student's class in the database
        for (const item of newDistribution) {
            const { error } = await client
                .from('students')
                .update({ class: item.newClass })
                .eq('id', item.studentId);

            if (error) {
                console.error(`Error updating student ${item.studentId}:`, error);
            }
        }

        hideLoading();
        showModal('Success', `Successfully updated ${newDistribution.length} student records in the database!`, 'success');

        // Refresh the display
        setTimeout(() => {
            showShuffleInterface();
        }, 2000);

    } catch (error) {
        hideLoading();
        showModal('Error', 'Error applying changes: ' + error.message, 'error');
    }
};

// ========== END SHUFFLE STUDENTS FEATURE ==========
