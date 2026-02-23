// ============================================
// ENHANCED RENDER PROFILE FUNCTION
// ============================================
// Replace the existing renderProfile() function (line ~2105) with this enhanced version
// Features: Glassmorphism, gradient backgrounds, animations, modern card layout
// Security: All user data properly escaped with escapeHTML()

async function renderProfile() {
    const currentUser = window.auth.getCurrentUser();
    const contentArea = document.getElementById('contentArea');
    const client = window.supabaseClient.getClient();

    let teacherData = null;
    let classTeacherData = null;
    let studentData = null;

    // Fetch role-specific data
    if (currentUser.role === 'teacher') {
        const { data } = await client
            .from('teachers')
            .select('*')
            .eq('id', currentUser.username)
            .maybeSingle();
        teacherData = data;
    } else if (currentUser.role === 'classteacher') {
        const { data } = await client
            .from('class_teachers')
            .select('*')
            .eq('id', currentUser.username)
            .maybeSingle();
        classTeacherData = data;
    } else if (currentUser.role === 'student') {
        const { data } = await client
            .from('students')
            .select('*')
            .eq('id', currentUser.username)
            .maybeSingle();
        studentData = data;
    }

    // Get initials for avatar - SECURITY: Use escapeHTML
    const nameForInitials = currentUser.name || currentUser.username || 'User';
    const initials = nameForInitials.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);

    // Get role display
    const roleDisplay = formatRole(currentUser.role);
    const roleEmoji = {
        'student': '📚',
        'teacher': '👨‍🏫',
        'classteacher': '👨‍🏫',
        'coordinator': '📋',
        'viceprincipal': '🎓',
        'superviceprincipal': '🎓',
        'hassan': '👑',
        'parent': '👨‍👩‍👧'
    }[currentUser.role] || '👤';

    contentArea.innerHTML = `
        <style>
            .profile-container {
                max-width: 1200px;
                margin: 0 auto;
                animation: fadeInUp 0.6s ease-out;
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .profile-header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 20px;
                padding: 40px;
                position: relative;
                overflow: hidden;
                margin-bottom: 30px;
                box-shadow: 0 20px 60px rgba(102, 126, 234, 0.3);
            }

            .profile-header::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
                animation: pulse 15s ease-in-out infinite;
            }

            @keyframes pulse {
                0%, 100% { transform: scale(1); opacity: 0.5; }
                50% { transform: scale(1.1); opacity: 0.8; }
            }

            .profile-header-content {
                position: relative;
                z-index: 1;
                display: flex;
                align-items: center;
                gap: 30px;
            }

            .profile-avatar-large {
                width: 120px;
                height: 120px;
                border-radius: 50%;
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 48px;
                font-weight: bold;
                color: white;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                border: 5px solid rgba(255,255,255,0.3);
                animation: avatarFloat 3s ease-in-out infinite;
            }

            @keyframes avatarFloat {
                0%, 100% { transform: translateY(0px); }
                50% { transform: translateY(-10px); }
            }

            .profile-header-info {
                flex: 1;
                color: white;
            }

            .profile-header-name {
                font-size: 36px;
                font-weight: 700;
                margin: 0 0 10px 0;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
            }

            .profile-header-role {
                display: inline-block;
                padding: 8px 20px;
                background: rgba(255,255,255,0.2);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                font-size: 16px;
                font-weight: 500;
                margin-bottom: 10px;
                border: 1px solid rgba(255,255,255,0.3);
            }

            .profile-header-id {
                font-size: 14px;
                opacity: 0.9;
                font-weight: 500;
            }

            .profile-cards-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin-bottom: 20px;
            }

            .profile-glass-card {
                background: rgba(255, 255, 255, 0.7);
                backdrop-filter: blur(10px);
                border-radius: 16px;
                padding: 25px;
                border: 1px solid rgba(255, 255, 255, 0.5);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                transition: all 0.3s ease;
                animation: slideIn 0.5s ease-out;
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateX(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .profile-glass-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
                background: rgba(255, 255, 255, 0.85);
            }

            .profile-card-title {
                font-size: 18px;
                font-weight: 600;
                color: #667eea;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .profile-card-title::before {
                content: '';
                width: 4px;
                height: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 2px;
            }

            .profile-info-item {
                margin-bottom: 15px;
                padding-bottom: 15px;
                border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            }

            .profile-info-item:last-child {
                margin-bottom: 0;
                padding-bottom: 0;
                border-bottom: none;
            }

            .profile-info-label {
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #999;
                margin-bottom: 5px;
                font-weight: 600;
            }

            .profile-info-value {
                font-size: 16px;
                color: #333;
                font-weight: 500;
            }

            .profile-edit-btn {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 12px 30px;
                border-radius: 25px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                transition: all 0.3s ease;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }

            .profile-edit-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
            }

            .profile-edit-form {
                background: white;
                border-radius: 16px;
                padding: 30px;
                margin-top: 20px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            }

            .profile-form-group {
                margin-bottom: 20px;
            }

            .profile-form-label {
                display: block;
                font-size: 14px;
                font-weight: 600;
                color: #333;
                margin-bottom: 8px;
            }

            .profile-form-input {
                width: 100%;
                padding: 12px 15px;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                font-size: 15px;
                transition: all 0.3s ease;
                box-sizing: border-box;
            }

            .profile-form-input:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }

            .profile-form-input:read-only {
                background: #f5f5f5;
                cursor: not-allowed;
            }

            .profile-btn-group {
                display: flex;
                gap: 15px;
                margin-top: 30px;
            }

            .profile-btn-primary {
                flex: 1;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .profile-btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            }

            .profile-btn-secondary {
                flex: 1;
                background: white;
                color: #667eea;
                border: 2px solid #667eea;
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .profile-btn-secondary:hover {
                background: #667eea;
                color: white;
            }
        </style>

        <div class="profile-container">
            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-header-content">
                    <div class="profile-avatar-large">${escapeHTML(initials)}</div>
                    <div class="profile-header-info">
                        <h1 class="profile-header-name">${escapeHTML(nameForInitials)}</h1>
                        <div class="profile-header-role">${roleEmoji} ${escapeHTML(roleDisplay)}</div>
                        <div class="profile-header-id">ID: ${escapeHTML(currentUser.username)}</div>
                    </div>
                </div>
            </div>

            <div id="profileViewMode">
                <!-- Personal Information Card -->
                <div class="profile-cards-grid">
                    <div class="profile-glass-card">
                        <div class="profile-card-title">Personal Information</div>
                        <div class="profile-info-item">
                            <div class="profile-info-label">Full Name</div>
                            <div class="profile-info-value">${escapeHTML(currentUser.name || 'Not provided')}</div>
                        </div>
                        <div class="profile-info-item">
                            <div class="profile-info-label">Username</div>
                            <div class="profile-info-value">${escapeHTML(currentUser.username)}</div>
                        </div>
                        <div class="profile-info-item">
                            <div class="profile-info-label">Role</div>
                            <div class="profile-info-value">${escapeHTML(roleDisplay)}</div>
                        </div>
                    </div>

                    ${studentData ? `
                        <div class="profile-glass-card">
                            <div class="profile-card-title">Academic Information</div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Class</div>
                                <div class="profile-info-value">${escapeHTML(studentData.class || 'Not assigned')}</div>
                            </div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Roll Number</div>
                                <div class="profile-info-value">${escapeHTML(studentData.roll_number || 'Not assigned')}</div>
                            </div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Student ID</div>
                                <div class="profile-info-value">${escapeHTML(studentData.id || '')}</div>
                            </div>
                        </div>
                    ` : ''}

                    ${teacherData ? `
                        <div class="profile-glass-card">
                            <div class="profile-card-title">Teaching Information</div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Subjects Teaching</div>
                                <div class="profile-info-value">${escapeHTML(teacherData.subjects || 'Not assigned')}</div>
                            </div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Classes Teaching</div>
                                <div class="profile-info-value">${escapeHTML(teacherData.classes || 'Not assigned')}</div>
                            </div>
                        </div>
                    ` : ''}

                    ${classTeacherData ? `
                        <div class="profile-glass-card">
                            <div class="profile-card-title">Class Teacher Information</div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Assigned Class</div>
                                <div class="profile-info-value">${escapeHTML(classTeacherData.class || 'Not assigned')}</div>
                            </div>
                            <div class="profile-info-item">
                                <div class="profile-info-label">Teacher ID</div>
                                <div class="profile-info-value">${escapeHTML(classTeacherData.id || '')}</div>
                            </div>
                        </div>
                    ` : ''}
                </div>

                ${(currentUser.role === 'teacher' || currentUser.role === 'classteacher') ? `
                    <div style="text-align: center; margin-top: 30px;">
                        <button type="button" class="profile-edit-btn" onclick="toggleProfileEdit()">
                            <span>✏️</span>
                            <span>Edit Profile</span>
                        </button>
                    </div>
                ` : ''}
            </div>

            <div id="profileEditMode" style="display: none;">
                <div class="profile-edit-form">
                    <h3 style="margin-bottom: 20px; color: #667eea;">Edit Profile Information</h3>
                    <form id="profileEditForm">
                        <div class="profile-form-group">
                            <label class="profile-form-label">Full Name *</label>
                            <input type="text" id="editName" class="profile-form-input" value="${escapeHTML(currentUser.name || '')}" required>
                        </div>
                        <div class="profile-form-group">
                            <label class="profile-form-label">Username</label>
                            <input type="text" class="profile-form-input" value="${escapeHTML(currentUser.username)}" readonly>
                        </div>
                        ${teacherData ? `
                            <div class="profile-form-group">
                                <label class="profile-form-label">Subjects Teaching (comma separated)</label>
                                <input type="text" id="editSubjects" class="profile-form-input" value="${escapeHTML(teacherData.subjects || '')}" placeholder="e.g., Mathematics, Physics">
                            </div>
                            <div class="profile-form-group">
                                <label class="profile-form-label">Classes Teaching (comma separated) *</label>
                                <input type="text" id="editClasses" class="profile-form-input" value="${escapeHTML(teacherData.classes || '')}" placeholder="e.g., 8B, 10A" required>
                            </div>
                        ` : ''}
                        <div class="profile-btn-group">
                            <button type="submit" class="profile-btn-primary">💾 Save Changes</button>
                            <button type="button" class="profile-btn-secondary" onclick="toggleProfileEdit()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    `;

    // Add form submit handler
    const editForm = document.getElementById('profileEditForm');
    if (editForm) {
        editForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            await saveProfileChanges(teacherData, classTeacherData);
        });
    }
}
