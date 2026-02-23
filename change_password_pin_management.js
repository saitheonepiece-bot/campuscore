// ========== CHANGE PASSWORD WITH PIN MANAGEMENT ==========
// This replaces the existing renderChangePassword() function (around line 2000)

function renderChangePassword() {
    const contentArea = document.getElementById('contentArea');
    const currentUser = window.auth.getCurrentUser();

    // Check if user is VP/SVP/Hassan for PIN management
    const isVP = ['viceprincipal', 'superviceprincipal', 'hassan'].includes(currentUser.role);

    contentArea.innerHTML = `
        <div class="card">
            <h3>🔐 Change Password</h3>
            <form id="changePasswordForm" class="form-section">
                <div class="form-row">
                    <div class="form-control">
                        <label>Current Password *</label>
                        <input type="password" id="currentPassword" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-control">
                        <label>New Password *</label>
                        <input type="password" id="newPassword" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-control">
                        <label>Confirm New Password *</label>
                        <input type="password" id="confirmPassword" required>
                    </div>
                </div>
                ${isVP ? `
                    <hr style="margin: 30px 0; border: none; border-top: 2px solid #e0e0e0;">
                    <h4 style="margin-bottom: 15px;">🔑 PIN Management (VP Only)</h4>
                    <p style="color: #666; margin-bottom: 20px;">
                        Manage your PINs for protected features. Leave blank to keep current PIN.
                    </p>
                    <div class="form-row">
                        <div class="form-control">
                            <label>Opening PIN (for Shuffle Students)</label>
                            <input type="text" id="pinOpen" placeholder="Current: VP321">
                            <small style="color: #999;">Used to access the Shuffle Students feature</small>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-control">
                            <label>Reshuffle PIN</label>
                            <input type="text" id="pinShuffle" placeholder="Current: VP123">
                            <small style="color: #999;">Used to confirm student shuffling action</small>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-control">
                            <label>Export PIN</label>
                            <input type="text" id="pinExport" placeholder="Current: VP000">
                            <small style="color: #999;">Used to export shuffle results to PDF</small>
                        </div>
                    </div>
                ` : ''}
                <div class="btn-group" style="margin-top: 20px;">
                    <button type="submit" class="btn-primary">Update Password${isVP ? ' & PINs' : ''}</button>
                    <button type="button" class="btn-secondary" onclick="renderTab('home')">Cancel</button>
                </div>
            </form>
        </div>
    `;

    // Add form submit handler
    document.getElementById('changePasswordForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const currentPassword = document.getElementById('currentPassword').value;
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (newPassword !== confirmPassword) {
            showModal('Error', 'New passwords do not match', 'error');
            return;
        }

        if (newPassword.length < 4) {
            showModal('Error', 'Password must be at least 4 characters long', 'error');
            return;
        }

        try {
            showLoading();
            const client = window.supabaseClient.getClient();

            // Change password
            await window.auth.changePassword(currentPassword, newPassword);

            // Update PINs if VP and any PIN fields are filled
            if (isVP) {
                const pinOpen = document.getElementById('pinOpen').value.trim();
                const pinShuffle = document.getElementById('pinShuffle').value.trim();
                const pinExport = document.getElementById('pinExport').value.trim();

                // Validate PIN lengths if provided
                if (pinOpen && pinOpen.length < 4) {
                    hideLoading();
                    showModal('Error', 'Opening PIN must be at least 4 characters long', 'error');
                    return;
                }
                if (pinShuffle && pinShuffle.length < 4) {
                    hideLoading();
                    showModal('Error', 'Reshuffle PIN must be at least 4 characters long', 'error');
                    return;
                }
                if (pinExport && pinExport.length < 4) {
                    hideLoading();
                    showModal('Error', 'Export PIN must be at least 4 characters long', 'error');
                    return;
                }

                // Update PINs in database (only if values provided)
                if (pinOpen || pinShuffle || pinExport) {
                    const updateData = {};
                    if (pinOpen) updateData.pin_open = pinOpen;
                    if (pinShuffle) updateData.pin_shuffle = pinShuffle;
                    if (pinExport) updateData.pin_export = pinExport;

                    const { error: pinError } = await client
                        .from('users')
                        .update(updateData)
                        .eq('username', currentUser.username);

                    if (pinError) {
                        console.error('Error updating PINs:', pinError);
                        hideLoading();
                        showModal('Warning', 'Password changed successfully, but there was an error updating PINs. You may need to contact an administrator.', 'warning');
                        return;
                    }

                    hideLoading();
                    showModal('Success', 'Password and PINs updated successfully!', 'success');
                } else {
                    hideLoading();
                    showModal('Success', 'Password changed successfully!', 'success');
                }
            } else {
                hideLoading();
                showModal('Success', 'Password changed successfully!', 'success');
            }

            renderTab('home');
        } catch (error) {
            hideLoading();
            showModal('Error', error.message || 'Failed to change password', 'error');
        }
    });
}

// ========== END CHANGE PASSWORD WITH PIN MANAGEMENT ==========
