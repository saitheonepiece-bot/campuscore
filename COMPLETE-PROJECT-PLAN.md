# CampusCore - Complete Project Plan
**Date:** February 21, 2026
**Status:** In Progress
**Objective:** Fix all issues, implement all requested features, NO data loss

---

## 📋 REQUIREMENTS SUMMARY

**Total Items:** 35 requirements
**Categorized into:** 8 major subsystems
**Estimated Total Time:** 80-120 hours
**Priority Levels:** Critical (P0), High (P1), Medium (P2), Low (P3)

---

## 🔴 PHASE 1: CRITICAL BUG FIXES (P0)
**Timeline:** Session 1 (Current)
**Estimated:** 3-4 hours

### 1.1 VP Tab Critical Fixes
- [ ] **Student Deletion Not Working** (30 min)
  - Current: Delete button exists but doesn't work
  - Fix: Implement proper deletion with confirmation
  - Files: dashboard.html (renderRemoveStudent function)
  - Test: Delete a test student, verify removal from database

- [ ] **Parent Management Showing Error** (30 min)
  - Current: Error when accessing parent management
  - Fix: Debug and fix parent data loading
  - Files: dashboard.html (renderManageParents function)
  - Test: Navigate to parent management, verify data loads

- [ ] **Delete Holiday Not Working** (20 min)
  - Current: Delete button doesn't remove holidays
  - Fix: Implement deleteHoliday function
  - Files: dashboard.html (renderHolidays section)
  - Test: Delete a holiday, verify removal

- [ ] **Exam Schedule Parent Info Error** (20 min)
  - Current: "Parent information not found" error
  - Fix: Check parent_id relationships
  - Files: dashboard.html (renderExamSchedule function)
  - Test: View exam schedule, verify no errors

### 1.2 Teacher Tab Critical Fixes
- [ ] **Homework Management Error** (30 min)
  - Current: Showing error when accessed
  - Fix: Debug and fix homework loading
  - Files: dashboard.html (renderHomeworkManagement)
  - Test: Access homework management, verify works

- [ ] **Teacher Schedule Error** (20 min)
  - Current: Not loading properly
  - Fix: Fix schedule data fetching
  - Files: dashboard.html (renderTeacherSchedule)
  - Test: View teacher schedule

- [ ] **Marks Approval Error** (30 min)
  - Current: Not working
  - Fix: Implement marks approval workflow
  - Files: dashboard.html (renderMarksApproval)
  - Test: Approve/reject marks

### 1.3 Student Tab Critical Fixes
- [ ] **Attendance Showing Error** (20 min)
  - Current: Error when viewing attendance
  - Fix: Fix attendance data loading
  - Files: dashboard.html (student attendance section)
  - Test: Student views attendance

### 1.4 Coordinator Tab Critical Fixes
- [ ] **CCA Calendar Upload Not Working** (30 min)
  - Current: Cannot upload CCA calendar
  - Fix: Implement file upload functionality
  - Files: dashboard.html (renderCoordinator section)
  - Database: Add cca_calendar table if needed
  - Test: Upload CCA calendar file

- [ ] **Manage Timetable Not Working** (30 min)
  - Current: Cannot manage timetable
  - Fix: Implement timetable management
  - Files: dashboard.html
  - Test: Upload/edit timetable

- [ ] **View Timetable Not Working** (20 min)
  - Current: Cannot view timetable
  - Fix: Fix timetable display
  - Files: dashboard.html
  - Test: View timetable as coordinator

### 1.5 Dropdown Menus Fix
- [ ] **All Dropdowns Not Working** (40 min)
  - Current: Collapsible menus not expanding
  - Fix: JavaScript for menu toggle
  - Files: dashboard.html (renderMenu function)
  - Test: Click all dropdown sections (MAIN, ACADEMIC, ADMIN, REPORTS)

**Phase 1 Total:** ~5 hours

---

## 🟠 PHASE 2: HIGH PRIORITY FEATURES (P1)
**Timeline:** Session 2
**Estimated:** 6-8 hours

### 2.1 Issue Escalation Workflow
- [ ] **Teacher → Coordinator → VP Workflow** (2 hours)
  - Teacher reports issue
  - Goes to Coordinator
  - Coordinator can escalate to VP (grade-based)
  - Grade 6,7,8 → VP001
  - Grade 9,10 → VP002
  - Files: dashboard.html, new tables needed
  - Database: Add issue_escalations table
  - Test: Create issue, escalate through workflow

### 2.2 Coordinator Class Management
- [ ] **Create New Classes** (30 min)
  - Coordinator can create classes
  - Files: dashboard.html (add to coordinator menu)
  - Test: Create class as coordinator

- [ ] **Appoint Teachers to Classes** (30 min)
  - Coordinator can assign class teachers
  - Files: dashboard.html
  - Test: Assign teacher to class

### 2.3 Exam Management for Coordinator
- [ ] **Remove Exams Option** (30 min)
  - Add delete/remove exam functionality
  - Files: dashboard.html (coordinator exam section)
  - Test: Remove an exam

### 2.4 Report Card Generation
- [ ] **Fix Report Card Generation** (1.5 hours)
  - Current: Not working
  - Fix: Debug and fix generation
  - Files: dashboard.html (renderReportCards)
  - Test: Generate report card for student

### 2.5 Class Teacher Registration
- [ ] **Add Class Teacher Registration** (45 min)
  - Add option in VP registration tab
  - Files: dashboard.html (renderRegister)
  - Database: class_teachers table exists
  - Test: Register a class teacher

### 2.6 Timetable Image Display
- [ ] **Show Coordinator's Timetable Image in Student Tab** (30 min)
  - When coordinator uploads timetable image
  - Same image shows in student tab
  - Files: dashboard.html
  - Database: Add timetable_images table
  - Test: Upload as coordinator, view as student

**Phase 2 Total:** ~7 hours

---

## 🟡 PHASE 3: MARKS WORKFLOW SYSTEM (P1)
**Timeline:** Session 2-3
**Estimated:** 4-5 hours

### 3.1 New Marks Workflow
- [ ] **Teacher Uploads Marks** (1 hour)
  - Teacher enters marks
  - Can edit before submission
  - Submit to marks_approval queue
  - Files: dashboard.html (upload marks section)
  - Database: Add marks_workflow table
  - Test: Upload marks as teacher

- [ ] **Marks Approval Queue** (1 hour)
  - Shows in Class Teacher tab
  - Shows in Coordinator tab
  - Approve/Reject functionality
  - Files: dashboard.html
  - Test: Approve/reject marks

- [ ] **Approved Marks → Parents** (45 min)
  - After approval, visible to parents
  - Like report card workflow
  - Files: dashboard.html (parent view)
  - Test: View approved marks as parent

- [ ] **Rejected Marks → Notifications** (45 min)
  - Teacher gets notification
  - Can edit and resubmit
  - Files: dashboard.html
  - Database: Add notifications table
  - Test: Reject marks, teacher edits, resubmits

- [ ] **Remove Manual Marks Entry** (15 min)
  - Delete manual marks upload section
  - Files: dashboard.html (teacher menu)
  - Test: Verify removed from menu

- [ ] **Link Exam Results with Marks Upload** (30 min)
  - Exam results shows uploaded marks
  - Files: dashboard.html
  - Test: Upload marks, view in exam results

**Phase 3 Total:** ~5 hours

---

## 🟢 PHASE 4: STUDENT SHUFFLING FEATURE (P1)
**Timeline:** Session 3
**Estimated:** 3-4 hours

### 4.1 Student Shuffling System
- [ ] **PIN Protection System** (1 hour)
  - Opening PIN: VP321
  - Reshuffle PIN: VP123
  - Export PDF PIN: VP000
  - Files: dashboard.html (VP tab)
  - Database: Add vp_pins table
  - Test: Access with correct PIN

- [ ] **Shuffle Students UI** (1.5 hours)
  - Select class
  - Show students in table
  - Shuffle button (requires VP123)
  - Export PDF button (requires VP000)
  - Files: dashboard.html
  - Test: Shuffle students, view table

- [ ] **Shuffle Algorithm** (45 min)
  - Randomly redistribute students
  - Show new arrangement in table
  - Confirm before applying
  - Files: dashboard.html
  - Test: Shuffle multiple times

- [ ] **Export Shuffled Classes to PDF** (45 min)
  - Generate PDF with new arrangement
  - Include all student details
  - Files: dashboard.html (PDF generation)
  - Test: Export PDF

- [ ] **PIN Management in Change Password Tab** (30 min)
  - Add section to change all 3 PINs
  - Requires current PIN verification
  - Files: dashboard.html (renderChangePassword)
  - Database: Update vp_pins table
  - Test: Change all PINs

**Phase 4 Total:** ~4.5 hours

---

## 🔵 PHASE 5: AUTHENTICATION & SECURITY (P1)
**Timeline:** Session 3-4
**Estimated:** 4-5 hours

### 5.1 Forgot Password Feature
- [ ] **Forgot Password Link on Login** (2 hours)
  - Add "Forgot Password" link
  - Email input form
  - Send reset email (needs email service)
  - Files: index.html, dashboard.html
  - Database: Add password_reset_tokens table
  - External: Email service (SendGrid, AWS SES, or SMTP)
  - Test: Request reset, receive email, reset password

- [ ] **Email Storage in Registration** (30 min)
  - Add email field to registration
  - Store in users/parents/teachers table
  - Files: dashboard.html (renderRegister)
  - Database: Add email column to relevant tables
  - Test: Register with email

### 5.2 Security Enhancements
- [ ] **SQL Injection Protection** (1 hour)
  - Use parameterized queries (already using Supabase)
  - Validate all inputs
  - Files: dashboard.html (all database operations)
  - Test: Try SQL injection attacks

- [ ] **XSS Protection** (30 min)
  - Sanitize all user inputs
  - Escape HTML in outputs
  - Files: dashboard.html (all innerHTML operations)
  - Test: Try XSS attacks

- [ ] **CSRF Protection** (30 min)
  - Implement CSRF tokens
  - Files: dashboard.html
  - Test: Verify CSRF protection

- [ ] **Rate Limiting** (30 min)
  - Limit login attempts
  - Limit API calls
  - Files: dashboard.html (auth.js)
  - Test: Multiple failed logins

- [ ] **Remove Phone Number from VP Registration** (10 min)
  - Remove phone field
  - Update form validation
  - Files: dashboard.html (renderRegister)
  - Test: Register VP without phone

**Phase 5 Total:** ~5 hours

---

## 🟣 PHASE 6: NOTIFICATIONS SYSTEM (P2)
**Timeline:** Session 4
**Estimated:** 3-4 hours

### 6.1 Real Notifications System
- [ ] **Database Schema** (30 min)
  - Create notifications table
  - user_id, type, message, read status, created_at
  - Files: New migration file
  - Database: notifications table
  - Test: Table created

- [ ] **Notification Generator** (1 hour)
  - Function to create notifications
  - Different types: marks_rejected, issue_escalated, etc.
  - Files: dashboard.html (utils section)
  - Test: Generate notification

- [ ] **Notification Display** (1 hour)
  - Bell icon with count
  - Dropdown showing notifications
  - Mark as read functionality
  - Files: dashboard.html (header section)
  - CSS: Notification styles
  - Test: View notifications

- [ ] **Real-time Updates** (1 hour)
  - Poll for new notifications (every 30 seconds)
  - Or use Supabase realtime
  - Files: dashboard.html
  - Test: Send notification, see update

**Phase 6 Total:** ~3.5 hours

---

## 🟤 PHASE 7: UI/UX IMPROVEMENTS (P2)
**Timeline:** Session 4-5
**Estimated:** 5-6 hours

### 7.1 Layout Improvements
- [ ] **Split-Pane Layout with Independent Scrolling** (2 hours)
  - Left: Sidebar menu (fixed scroll)
  - Right: Content area (independent scroll)
  - Files: dashboard.html, style.css
  - CSS: Flexbox/Grid layout
  - Test: Scroll both independently

- [ ] **Parent/Teacher Name Display** (30 min)
  - Parent tab: Student name on left, parent name at top
  - Teacher tab: Same pattern
  - Files: dashboard.html (renderTab function)
  - Test: View as parent/teacher

- [ ] **Enhanced Bio Page Design** (2.5 hours)
  - Study examples:
    - https://ashwath1427.github.io/DPS-BLOG/#about
    - https://dpsndglblog.lovable.app/
  - Modern gradient backgrounds
  - Animated elements
  - Better typography
  - Files: style.css, possibly new index page
  - Test: View bio page

- [ ] **Dropdown Menu Improvements** (30 min)
  - Smooth animations
  - Better icons
  - Highlight active section
  - Files: style.css, dashboard.html
  - Test: Click all dropdowns

**Phase 7 Total:** ~5.5 hours

---

## ⚪ PHASE 8: DATA FORMAT & CONSOLIDATION (P2)
**Timeline:** Session 5
**Estimated:** 3-4 hours

### 8.1 Registration Consolidation
- [ ] **Merge Student/Parent Registration** (1 hour)
  - Single form for both
  - Creates student + parent + user accounts
  - Files: dashboard.html (renderRegister)
  - Test: Register student, verify parent created

- [ ] **Remove Junior/Senior VP Options** (30 min)
  - Keep only VP001 and VP002
  - Update registration dropdown
  - Update role checks
  - Files: dashboard.html (multiple places)
  - Test: Register VP, only see VP001/VP002

- [ ] **Date Format Fix (DD-MM-YYYY)** (45 min)
  - Excel upload date parsing
  - Display dates in DD-MM-YYYY
  - Files: dashboard.html (bulk upload section)
  - Test: Upload Excel with dates

**Phase 8 Total:** ~2.5 hours

---

## ⚫ PHASE 9: ANALYTICS ENHANCEMENTS (P2)
**Timeline:** Session 5
**Estimated:** 2 hours

### 9.1 Teacher Rating Analytics
- [ ] **Show Average Rating in Analytics** (2 hours)
  - Calculate average rating per teacher
  - Display in analytics dashboard
  - Chart/graph visualization
  - Files: dashboard.html (renderTeacherAnalytics)
  - Test: View teacher analytics with ratings

**Phase 9 Total:** ~2 hours

---

## 🔴 PHASE 10: UNIFIED LOGIN SYSTEM (P3 - MAJOR REFACTOR)
**Timeline:** Session 6+ (Future)
**Estimated:** 20-30 hours

### 10.1 Architecture Redesign
⚠️ **WARNING: This is a complete rewrite of the authentication and role system**

**Current System:**
- Multiple role-based tabs
- Separate login flows
- Role-specific menus

**Proposed System:**
- 2 main tabs: VP001, VP002
- All others login with IDs (NGTR001, etc.)
- Unified role management
- Post-based permissions (Teacher, CT, Coordinator all in one)

**Implementation Steps:**
- [ ] Design new authentication flow (3 hours)
- [ ] Design new role/permission system (4 hours)
- [ ] Refactor menu system (4 hours)
- [ ] Migrate all existing functionality (8 hours)
- [ ] Update all role checks (3 hours)
- [ ] Extensive testing (6 hours)
- [ ] Data migration script (2 hours)

**Recommendation:** Do this as a **separate major version update** after all current issues are fixed.

**Phase 10 Total:** ~30 hours

---

## 📊 SUMMARY BY PRIORITY

| Priority | Phases | Items | Est. Hours |
|----------|--------|-------|------------|
| P0 - Critical | Phase 1 | 13 | 5 |
| P1 - High | Phases 2-5 | 35 | 21.5 |
| P2 - Medium | Phases 6-9 | 15 | 16.5 |
| P3 - Low | Phase 10 | 7 | 30 |
| **TOTAL** | **10 Phases** | **70 Items** | **73 Hours** |

---

## 🎯 RECOMMENDED EXECUTION PLAN

### Session 1 (Current - 4 hours)
✅ Phase 1: Critical bug fixes
✅ Start Phase 2: High priority features

### Session 2 (4 hours)
✅ Complete Phase 2
✅ Phase 3: Marks workflow

### Session 3 (4 hours)
✅ Phase 4: Student shuffling
✅ Start Phase 5: Security

### Session 4 (4 hours)
✅ Complete Phase 5
✅ Phase 6: Notifications

### Session 5 (4 hours)
✅ Phase 7: UI/UX
✅ Phases 8-9: Data & Analytics

### Session 6+ (Future)
✅ Phase 10: Unified login (major refactor)

---

## 🔒 DATA SAFETY GUARANTEE

Every change will follow these principles:

1. ✅ **No Data Deletion** - All existing data preserved
2. ✅ **No Feature Removal** - All current features maintained
3. ✅ **Backward Compatible** - Old data works with new system
4. ✅ **Database Backups** - Migration scripts are reversible
5. ✅ **Incremental Changes** - Small, tested changes
6. ✅ **Version Control** - All changes committed to Git

---

## 📝 TESTING CHECKLIST

After each phase:
- [ ] Manual testing of all affected features
- [ ] Verify no existing features broken
- [ ] Check database data integrity
- [ ] Test on different user roles
- [ ] Verify responsive design
- [ ] Check console for errors
- [ ] Test edge cases

---

## 📁 FILES TO BE MODIFIED

| File | Estimated Changes | Risk Level |
|------|------------------|------------|
| dashboard.html | 2000+ lines | High |
| style.css | 500+ lines | Medium |
| auth.js | 200+ lines | High |
| database.js | 300+ lines | Medium |
| index.html | 100+ lines | Low |
| supabase-schema.sql | New tables | Medium |

---

## 🗄️ NEW DATABASE TABLES NEEDED

1. `notifications` - For real notifications
2. `issue_escalations` - For issue workflow
3. `marks_workflow` - For marks approval
4. `vp_pins` - For shuffling PINs
5. `password_reset_tokens` - For forgot password
6. `timetable_images` - For timetable uploads
7. `cca_calendar` - For CCA calendar
8. `teacher_ratings` - For rating analytics (if not exists)

---

## 💾 MIGRATION SCRIPTS TO CREATE

1. `migration-add-notifications.sql`
2. `migration-add-workflow-tables.sql`
3. `migration-add-security-tables.sql`
4. `migration-add-email-columns.sql`
5. `migration-unified-login.sql` (Phase 10)

---

## 🚀 CURRENT SESSION PLAN

**Starting NOW:**

1. ⏱️ **00:00 - 00:30** - Fix VP tab critical bugs
2. ⏱️ **00:30 - 01:00** - Fix dropdown menus
3. ⏱️ **01:00 - 01:30** - Fix Coordinator tab features
4. ⏱️ **01:30 - 02:30** - Fix Teacher tab (marks workflow)
5. ⏱️ **02:30 - 03:00** - Fix Student/Parent tabs
6. ⏱️ **03:00 - 03:30** - Test all changes
7. ⏱️ **03:30 - 04:00** - Commit, document, create report

---

**Status:** 🟢 Ready to Begin
**Next Action:** Start Phase 1 - Critical Bug Fixes
**Commitment:** NO DATA LOSS, NO FEATURE REMOVAL

---

*This plan will be updated as work progresses.*
