-- ============================================
-- Add Hassan Sir and Multi-Role Support
-- ============================================
-- Run this SQL in your Supabase SQL Editor

-- Create user_roles table for multi-role support
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGSERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('teacher', 'classteacher', 'coordinator', 'parent', 'viceprincipal', 'superviceprincipal', 'hassan')),
    assigned_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(username, role)
);

-- Add Hassan Sir user
INSERT INTO users (username, password, name, role) VALUES
('HASSAN001', 'hassan123', 'Hassan Sir', 'hassan')
ON CONFLICT (username) DO NOTHING;

-- Initialize Hassan Sir's primary role
INSERT INTO user_roles (username, role, assigned_by) VALUES
('HASSAN001', 'hassan', 'system')
ON CONFLICT (username, role) DO NOTHING;

-- Disable RLS on user_roles table
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- Success message
SELECT 'Hassan Sir added and multi-role system created successfully!' as message;
