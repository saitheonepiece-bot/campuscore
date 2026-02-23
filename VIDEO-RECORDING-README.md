# 🎥 CampusCore Dashboard Video Recording

This guide explains how to record automated demo videos for different user roles in CampusCore.

---

## 📋 Prerequisites

1. **Node.js installed** (version 14 or higher)
2. **Playwright installed** (already done via `npm install`)
3. **Valid user accounts** in your Supabase database

---

## 🚀 Quick Start

### Step 1: Start the Local Server

Open a terminal and run:

```bash
npm run server
```

This will start a local HTTP server on `http://localhost:8000`

**Keep this terminal open!**

---

### Step 2: Record Demo Videos

Open a **NEW terminal** (keep the server running) and run:

```bash
npm run record
```

This will:
- Open a browser for each user role
- Log in automatically
- Navigate through different tabs
- Test the search functionality
- Record everything as a video
- Save videos to `./videos/` directory

---

## 📹 Videos Created

After recording completes, you'll have 5 videos:

1. **parent-demo.webm** - Parent dashboard walkthrough
2. **student-demo.webm** - Student dashboard walkthrough
3. **teacher-demo.webm** - Teacher dashboard walkthrough
4. **coordinator-demo.webm** - Coordinator dashboard walkthrough
5. **vp-demo.webm** - Vice Principal dashboard walkthrough

---

## 🔧 Customization

### Modify User Credentials

Edit `record-demos.js` and update the `users` array:

```javascript
const users = [
    {
        role: 'Parent',
        username: 'P3240504A',  // Change this
        password: 'parent123',   // Change this
        tabs: ['home', 'attendance', 'viewhomework']  // Customize tabs
    },
    // ... more users
];
```

### Adjust Recording Settings

In `record-demos.js`, you can modify:

```javascript
// Browser speed
slowMo: 500  // milliseconds between actions

// Video resolution
viewport: { width: 1920, height: 1080 }

// Wait times
await page.waitForTimeout(3000);  // adjust timing
```

---

## 🎬 What Gets Recorded

For each user role, the script will:

1. ✅ Navigate to login page
2. ✅ Enter credentials and log in
3. ✅ Navigate through role-specific tabs:
   - **Parent/Student**: Home, Attendance, Homework, Results, Timetable
   - **Teacher**: Home, Attendance, Homework, Marks Workflow, Schedule, Issues
   - **Coordinator**: Home, CCA Calendar, Timetable Management, Exams, Issues
   - **VP**: Home, Registration, Class Structure, Holidays, Exam Schedule, Issues
4. ✅ Test search functionality
5. ✅ Scroll through content
6. ✅ Return to home page

Total recording time per role: ~2-3 minutes

---

## ⚠️ Troubleshooting

### Server Not Running
```
Error: net::ERR_CONNECTION_REFUSED
```
**Solution:** Make sure `npm run server` is running in a separate terminal

### Login Failed
```
Error: Timeout waiting for selector
```
**Solution:**
- Check that your username/password are correct
- Verify users exist in Supabase database
- Check Supabase connection in dashboard.html

### Videos Not Saving
**Solution:**
- Check that `./videos/` directory exists
- Ensure you have write permissions
- Wait for the script to fully complete before checking

### Browser Crashes
**Solution:**
- Reduce `slowMo` value (less delay between actions)
- Increase timeout values
- Close other applications to free up memory

---

## 🎯 Demo User Accounts

Make sure these accounts exist in your Supabase database:

| Role | Username | Password | Purpose |
|------|----------|----------|---------|
| Parent | P3240504A | parent123 | Parent of Sai Charan |
| Student | S3240504A | student123 | Student Sai Charan |
| Teacher | T001 | teacher123 | General teacher |
| Coordinator | C001 | coordinator123 | Department coordinator |
| VP | VP001 | vp123 | Vice Principal |

**⚠️ Update these credentials in `record-demos.js` to match your database!**

---

## 📊 Video Specifications

- **Format:** WebM
- **Resolution:** 1920x1080 (Full HD)
- **FPS:** ~30 fps
- **Codec:** VP8/VP9
- **Audio:** None (screen recording only)

---

## 🔄 Converting Videos

To convert WebM to MP4 (if needed):

```bash
# Install ffmpeg first
brew install ffmpeg  # macOS
# or
apt-get install ffmpeg  # Linux

# Convert
ffmpeg -i videos/parent-demo.webm -c:v libx264 videos/parent-demo.mp4
```

---

## 📝 Manual Recording

If you prefer to record manually:

1. Start server: `npm run server`
2. Open browser manually
3. Use screen recording software (QuickTime, OBS, etc.)
4. Navigate through dashboard manually

---

## 🎨 Advanced Features

### Record Specific Role Only

Edit `record-demos.js` and comment out unwanted users:

```javascript
// Record only parent
for (const user of users) {
    if (user.role === 'Parent') {
        await recordDashboard(user);
    }
}
```

### Add Custom Actions

Add more interactions in the recording loop:

```javascript
// Click a specific button
await page.click('#specificButton');

// Fill a form
await page.fill('#inputField', 'test data');

// Take a screenshot
await page.screenshot({ path: 'screenshot.png' });
```

---

## 📁 File Structure

```
campuscore/
├── record-demos.js          # Main recording script
├── start-server.js          # Local HTTP server
├── package.json            # NPM scripts
└── videos/                 # Output directory
    ├── parent-demo.webm
    ├── student-demo.webm
    ├── teacher-demo.webm
    ├── coordinator-demo.webm
    └── vp-demo.webm
```

---

## ✅ Checklist Before Recording

- [ ] Supabase database is set up and accessible
- [ ] All demo user accounts exist with correct credentials
- [ ] Local server is running (`npm run server`)
- [ ] Playwright and Chromium are installed
- [ ] `videos/` directory is writable
- [ ] Updated credentials in `record-demos.js` if needed

---

## 🆘 Support

If you encounter issues:

1. Check the console output for error messages
2. Verify Supabase connection in browser console
3. Test manual login at http://localhost:8000
4. Check that all user accounts exist in database
5. Review Playwright documentation: https://playwright.dev

---

## 🎉 Success!

When complete, you'll see:

```
✅ All recordings complete!
📁 Videos saved in ./videos/ directory

Videos created:
  - parent-demo.webm
  - student-demo.webm
  - teacher-demo.webm
  - coordinator-demo.webm
  - vp-demo.webm
```

---

**Last Updated:** February 23, 2026
**Created By:** CampusCore Development Team
