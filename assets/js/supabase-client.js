// Supabase Client - using CDN for GitHub Pages compatibility
class SupabaseClient {
    constructor() {
        this.supabase = null;
        this.initialized = false;
    }

    async init() {
        if (this.initialized) return this.supabase;

        try {
            // Supabase client will be loaded from CDN in HTML
            if (typeof supabase === 'undefined') {
                throw new Error('Supabase library not loaded');
            }

            const SUPABASE_URL = 'https://xmjyryrmqeneulogmwep.supabase.co';
            const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtanlyeXJtcWVuZXVsb2dtd2VwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MTc5MzIsImV4cCI6MjA4MzE5MzkzMn0.cznke6hKAxEu9_S1xqjmGnIwpvAU-5KFMSiFvgxAB0E';

            this.supabase = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
            this.initialized = true;
            return this.supabase;
        } catch (error) {
            console.error('Failed to initialize Supabase:', error);
            throw error;
        }
    }

    getClient() {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized. Call init() first.');
        }
        return this.supabase;
    }
}

// Create singleton instance
const supabaseClient = new SupabaseClient();

// Export for use in other modules
window.supabaseClient = supabaseClient;
