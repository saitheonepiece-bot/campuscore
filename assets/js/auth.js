// Authentication Module
class Auth {
    constructor() {
        this.currentUser = null;
    }

    async login(username, password) {
        try {
            const client = window.supabaseClient.getClient();

            // Query users table for matching username and password
            const { data, error } = await client
                .from('users')
                .select('*')
                .eq('username', username)
                .eq('password', password)
                .single();

            if (error || !data) {
                throw new Error('Invalid User ID or password');
            }

            // Store user info with auto-detected role from database
            this.currentUser = {
                username: data.username,
                name: data.name,
                role: data.role
            };

            // Save to sessionStorage securely
            sessionStorage.setItem('currentUser', JSON.stringify(this.currentUser));

            return this.currentUser;
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    }

    async register(userData) {
        try {
            const client = window.supabaseClient.getClient();

            // Check if username already exists
            const { data: existingUser } = await client
                .from('users')
                .select('username')
                .eq('username', userData.username)
                .maybeSingle();

            if (existingUser) {
                throw new Error('Username already exists');
            }

            // Insert new user
            const { data, error } = await client
                .from('users')
                .insert([{
                    username: userData.username,
                    password: userData.password,
                    name: userData.name,
                    role: userData.role
                }])
                .select()
                .maybeSingle();

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Registration error:', error);
            throw error;
        }
    }

    logout() {
        this.currentUser = null;
        sessionStorage.removeItem('currentUser');
        window.location.href = 'index.html';
    }

    getCurrentUser() {
        if (!this.currentUser) {
            const stored = sessionStorage.getItem('currentUser');
            if (stored) {
                this.currentUser = JSON.parse(stored);
            }
        }
        return this.currentUser;
    }

    isAuthenticated() {
        return this.getCurrentUser() !== null;
    }

    requireAuth() {
        if (!this.isAuthenticated()) {
            window.location.href = 'index.html';
            return false;
        }
        return true;
    }

    async changePassword(oldPassword, newPassword) {
        try {
            const user = this.getCurrentUser();
            if (!user) {
                throw new Error('Not authenticated');
            }

            const client = window.supabaseClient.getClient();

            // Verify old password
            const { data: userData } = await client
                .from('users')
                .select('password')
                .eq('username', user.username)
                .single();

            if (!userData || userData.password !== oldPassword) {
                throw new Error('Current password is incorrect');
            }

            // Update password
            const { error } = await client
                .from('users')
                .update({ password: newPassword })
                .eq('username', user.username);

            if (error) {
                throw error;
            }

            return true;
        } catch (error) {
            console.error('Change password error:', error);
            throw error;
        }
    }
}

// Create singleton instance
const auth = new Auth();
window.auth = auth;
