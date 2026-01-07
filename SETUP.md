# CampusCore Setup Guide

This guide will walk you through setting up CampusCore from scratch.

## Prerequisites

- A Supabase account (free tier works fine)
- A GitHub account (for deployment)
- Basic knowledge of Git

## Step 1: Create a Supabase Project

1. **Go to Supabase**:
   - Visit [https://supabase.com](https://supabase.com)
   - Click "Start your project" or "Sign In"
   - Sign in with GitHub or create an account

2. **Create a New Project**:
   - Click "New Project"
   - Choose your organization (or create one)
   - Fill in the project details:
     - **Name**: `campuscore` (or any name you prefer)
     - **Database Password**: Choose a strong password (save it!)
     - **Region**: Choose the closest region to you
   - Click "Create new project"
   - Wait 2-3 minutes for the project to initialize

3. **Note Your Project Details**:
   - Once ready, go to **Settings** → **API**
   - Copy these values (you'll need them later):
     - **Project URL** (looks like: `https://xxxxx.supabase.co`)
     - **Project API keys** → **anon public** key

## Step 2: Set Up the Database

1. **Open the SQL Editor**:
   - In your Supabase dashboard, click on the **SQL Editor** icon in the left sidebar
   - Click "New query"

2. **Create the Database Schema**:
   - Open the file `supabase-schema.sql` from this project
   - Copy ALL the content (Ctrl+A, Ctrl+C or Cmd+A, Cmd+C)
   - Paste it into the SQL Editor
   - Click "Run" (or press Ctrl+Enter / Cmd+Return)
   - You should see "Success. No rows returned"

3. **Load Sample Data**:
   - Click "New query" again
   - Open the file `supabase-init-data.sql`
   - Copy ALL the content
   - Paste it into the SQL Editor
   - Click "Run"
   - You should see messages confirming data insertion

4. **Verify the Setup**:
   - Click on **Table Editor** in the left sidebar
   - You should see all the tables (users, students, parents, teachers, etc.)
   - Click on the `users` table
   - You should see 14 rows of user data

## Step 3: Configure the Application

1. **Update Supabase Credentials**:
   - Open the file `assets/js/supabase-client.js`
   - Find these lines:
     ```javascript
     const SUPABASE_URL = 'https://xmjyryrmqeneulogmwep.supabase.co';
     const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
     ```
   - Replace `SUPABASE_URL` with your Project URL
   - Replace `SUPABASE_KEY` with your anon public key

2. **Save the File**

## Step 4: Test Locally

1. **Open in Browser**:
   - Navigate to the `campuscore` folder
   - Double-click `index.html` to open it in your default browser
   - OR use a local server (recommended):
     ```bash
     # Using Python 3
     cd campuscore
     python3 -m http.server 8000

     # Then open http://localhost:8000 in your browser
     ```

2. **Test Login**:
   - Try logging in with these credentials:
     - **Role**: Parent
     - **Username**: `P3180076A`
     - **Password**: `parent123`
   - Click "Sign In"
   - You should be redirected to the dashboard

3. **Test Features**:
   - Click on different menu items (Dashboard, Attendance, Profile, etc.)
   - Try the "Change Password" feature
   - Try logging out and logging back in

## Step 5: Deploy to GitHub Pages

1. **Create a GitHub Repository**:
   - Go to [GitHub](https://github.com)
   - Click the "+" icon in the top right → "New repository"
   - Enter repository details:
     - **Name**: `campuscore` (or any name)
     - **Description**: "School Management System"
     - **Public** or **Private** (your choice, but GitHub Pages works better with Public)
   - Don't initialize with README (we already have one)
   - Click "Create repository"

2. **Push Your Code**:
   - Open Terminal/Command Prompt
   - Navigate to the campuscore folder:
     ```bash
     cd /path/to/campuscore
     ```
   - Initialize Git and push:
     ```bash
     git init
     git add .
     git commit -m "Initial commit: CampusCore with Supabase"
     git branch -M main
     git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
     git push -u origin main
     ```
   - Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual values

3. **Enable GitHub Pages**:
   - Go to your repository on GitHub
   - Click **Settings** (at the top)
   - Scroll down and click **Pages** in the left sidebar
   - Under "Source":
     - Select branch: **main**
     - Select folder: **/ (root)**
   - Click **Save**
   - Wait 1-2 minutes

4. **Access Your Live Site**:
   - GitHub will show you the URL (looks like: `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`)
   - Click on it or copy and paste into a new tab
   - You should see your login page!

## Step 6: Share with Your Teacher

1. **Share the URL**:
   - Give your teacher the GitHub Pages URL
   - Example: `https://yourusername.github.io/campuscore/`

2. **Share Login Credentials**:
   - Provide a list of test credentials (see README.md)
   - Or create a specific account for your teacher

3. **Demonstrate Features**:
   - Show different user roles
   - Demonstrate key features (attendance, homework, etc.)

## Troubleshooting

### Problem: "Failed to initialize application"
**Solution**:
- Check that you updated the Supabase credentials correctly
- Verify your Supabase project is active (not paused)
- Check the browser console (F12) for errors

### Problem: "Invalid username or password"
**Solution**:
- Make sure you ran the `supabase-init-data.sql` script
- Verify the username exists in the `users` table in Supabase
- Make sure the role selected matches the user's role

### Problem: "No data showing in dashboard"
**Solution**:
- Check that sample data was inserted (`supabase-init-data.sql`)
- Verify Row Level Security is disabled in Supabase
- Check the browser console for errors

### Problem: "GitHub Pages showing 404"
**Solution**:
- Make sure you enabled GitHub Pages in Settings → Pages
- Check that the branch is set to `main` and folder is `/` (root)
- Wait 2-5 minutes for deployment to complete
- Make sure `.nojekyll` file exists in the root

### Problem: "Can't see styles on GitHub Pages"
**Solution**:
- Check that `assets/css/style.css` exists
- Verify file paths in `index.html` and `dashboard.html` use relative paths
- Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)

## Advanced: Adding New Users

You can add new users directly in Supabase:

1. Go to **Table Editor** → **users**
2. Click **Insert** → **Insert row**
3. Fill in the details:
   - **username**: The login username
   - **password**: Plain text password (for now)
   - **name**: Display name
   - **role**: One of: `parent`, `teacher`, `coordinator`, `viceprincipal`, `superviceprincipal`, `classteacher`
4. Click **Save**

## Security Reminders

1. **Change Default Passwords**: In production, all users should change their passwords
2. **Enable RLS**: For production, enable Row Level Security in Supabase
3. **Use Password Hashing**: Implement proper password hashing (bcrypt/argon2)
4. **HTTPS Only**: Always use HTTPS in production (GitHub Pages uses HTTPS by default)

## Next Steps

- Implement all the "Coming Soon" features
- Add email notifications
- Implement file uploads for assignments
- Add more analytics and reporting
- Create mobile app version

## Support

If you encounter issues:
1. Check the browser console (F12 → Console tab)
2. Check Supabase logs (Dashboard → Logs)
3. Review the README.md for additional help
4. Create an issue in the GitHub repository

---

Good luck with your project!
