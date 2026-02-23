// ========== FORGOT PASSWORD FEATURE ==========
// Add this function to handle forgot password functionality
// The menu item 'forgotpassword' is already in the switch case (line 618-620)

async function renderForgotPassword() {
    const contentArea = document.getElementById('contentArea');

    contentArea.innerHTML = `
        <div class="card">
            <h3>🔑 Forgot Password</h3>
            <p style="color: #666; margin-bottom: 20px;">
                Enter your username to retrieve your registered email address. You can then contact the administrator for a password reset.
            </p>

            <div style="background: #e3f2fd; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <strong>ℹ️ Note:</strong>
                <p style="margin-top: 8px; color: #1976d2;">
                    This system will display your registered email address. For security reasons, we cannot send emails automatically.
                    Please contact your administrator with this email to verify your identity and reset your password.
                </p>
            </div>

            <form id="forgotPasswordForm" style="max-width: 500px;">
                <div class="form-group">
                    <label>Username / User ID *</label>
                    <input type="text" id="usernameInput" placeholder="Enter your username" required>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn-primary">Retrieve Email</button>
                    <button type="button" class="btn-secondary" onclick="window.location.reload()">Back to Login</button>
                </div>
            </form>

            <div id="retrievalResult" style="margin-top: 20px;"></div>
        </div>
    `;

    // Add form submit handler
    document.getElementById('forgotPasswordForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const username = document.getElementById('usernameInput').value.trim();

        if (!username) {
            showModal('Error', 'Please enter your username', 'error');
            return;
        }

        try {
            showLoading();
            const client = window.supabaseClient.getClient();

            // Fetch user details
            const { data: user, error } = await client
                .from('users')
                .select('username, name, role, email')
                .eq('username', username)
                .maybeSingle();

            hideLoading();

            const resultDiv = document.getElementById('retrievalResult');

            if (error || !user) {
                resultDiv.innerHTML = `
                    <div style="background: #ffebee; padding: 15px; border-radius: 8px; color: #c62828;">
                        <strong>❌ User Not Found</strong>
                        <p style="margin-top: 8px;">No user with username "${username}" was found in the system.</p>
                        <p style="margin-top: 8px;">Please check the spelling and try again, or contact your administrator.</p>
                    </div>
                `;
                return;
            }

            // Check if email is registered
            if (user.email && user.email.trim() !== '') {
                resultDiv.innerHTML = `
                    <div style="background: #e8f5e9; padding: 15px; border-radius: 8px; color: #2e7d32;">
                        <strong>✅ Account Found</strong>
                        <p style="margin-top: 12px;"><strong>Username:</strong> ${user.username}</p>
                        <p><strong>Name:</strong> ${user.name || 'N/A'}</p>
                        <p><strong>Role:</strong> ${formatRole(user.role)}</p>
                        <p style="margin-top: 15px; font-size: 16px;">
                            <strong>Registered Email:</strong>
                            <span style="background: white; padding: 5px 10px; border-radius: 4px; display: inline-block; margin-top: 5px;">
                                ${user.email}
                            </span>
                        </p>
                        <hr style="margin: 20px 0; border: none; border-top: 1px solid #c8e6c9;">
                        <p style="margin-top: 15px;">
                            <strong>📧 Next Steps:</strong>
                        </p>
                        <ul style="margin-top: 10px; margin-left: 20px;">
                            <li>Contact your school administrator at this email address</li>
                            <li>Verify your identity by providing your name and user details</li>
                            <li>Request a password reset</li>
                        </ul>
                        <p style="margin-top: 15px; font-size: 14px; color: #666;">
                            For security reasons, password reset requests must be verified by an administrator.
                        </p>
                    </div>
                `;
            } else {
                // No email registered
                resultDiv.innerHTML = `
                    <div style="background: #fff3cd; padding: 15px; border-radius: 8px; color: #856404;">
                        <strong>⚠️ Email Not Registered</strong>
                        <p style="margin-top: 12px;"><strong>Username:</strong> ${user.username}</p>
                        <p><strong>Name:</strong> ${user.name || 'N/A'}</p>
                        <p><strong>Role:</strong> ${formatRole(user.role)}</p>
                        <hr style="margin: 15px 0; border: none; border-top: 1px solid #ffeaa7;">
                        <p style="margin-top: 15px;">
                            <strong>📞 Contact Administrator</strong>
                        </p>
                        <p style="margin-top: 10px;">
                            No email address is registered for this account. Please contact your school administrator directly to reset your password.
                        </p>
                        <p style="margin-top: 10px;">
                            Provide them with:
                        </p>
                        <ul style="margin-top: 8px; margin-left: 20px;">
                            <li>Username: <strong>${user.username}</strong></li>
                            <li>Your full name</li>
                            <li>Your role: <strong>${formatRole(user.role)}</strong></li>
                        </ul>
                    </div>
                `;
            }

        } catch (error) {
            hideLoading();
            showModal('Error', 'Error retrieving user information: ' + error.message, 'error');
        }
    });
}

// ========== ADD FORGOT PASSWORD LINK TO LOGIN PAGE ==========
// Find the login form in the HTML (search for "Login to Dashboard" or the login button)
// Add this link below the login button:
//
// <div style="text-align: center; margin-top: 15px;">
//     <a href="#" onclick="event.preventDefault(); renderForgotPassword(); return false;" style="color: #3498db; text-decoration: none;">
//         Forgot Password?
//     </a>
// </div>
//
// OR if you want to add it to the menu, add it to the renderTab switch case (already done at line 618-620)

// ========== END FORGOT PASSWORD FEATURE ==========
