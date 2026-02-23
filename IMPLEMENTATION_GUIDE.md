# CampusCore Advanced Features - Implementation Guide

This guide provides step-by-step instructions for implementing all advanced features requested.

## Overview of Features

1. ✅ **Student Shuffling System with PIN Protection**
2. ✅ **PIN Management in Change Password Tab**
3. ✅ **Forgot Password with Email Verification**
4. ✅ **Email Field Support in Registration Forms**
5. ✅ **Class Teacher Registration** (Already Complete)

---

## Feature 1: Student Shuffling System

### Status: Menu item added ✅, Function implementation ready

### What was done:
- Added 'Shuffle Students' menu item to VP and SVP menus (lines 211, 234)

### What needs to be done:

1. **Insert the shuffle students code** from `shuffle_students_feature.js` into `dashboard.html` at line **8169** (just before `async function renderRemoveStudent()`)

2. **The feature includes:**
   - Opening PIN (VP321) - to access the page
   - Reshuffle PIN (VP123) - to trigger shuffle
   - Export PDF PIN (VP000) - to export results
   - Grade selection (6, 7, 8, 9, 10)
   - Current distribution display
   - Shuffle logic with balanced distribution
   - PDF export via print dialog
   - Database update functionality

---

## Feature 2: PIN Management in Change Password

### Status: Code ready in separate file

### What needs to be done:

1. **Replace the existing `renderChangePassword()` function** (starting at line ~1995) with the code from `change_password_pin_management.js`

2. **Add database columns** to the `users` table in Supabase:
   ```sql
   ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_open TEXT DEFAULT 'VP321';
   ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_shuffle TEXT DEFAULT 'VP123';
   ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_export TEXT DEFAULT 'VP000';
   ```

3. **Features included:**
   - VPs see three additional PIN fields
   - PINs are stored in the database
   - Default values: VP321, VP123, VP000
   - Validation: minimum 4 characters
   - Update only if fields are filled

---

## Feature 3: Forgot Password Feature

### Status: Code ready in separate file

### What needs to be done:

1. **Add the `renderForgotPassword()` function** from `forgot_password_feature.js` to `dashboard.html`
   - Insert it anywhere among the other render functions (suggested: after `renderChangePassword()`)

2. **The switch case entry already exists** at line 618-620:
   ```javascript
   case 'forgotpassword':
       renderForgotPassword();
       break;
   ```

3. **Add database column** for email:
   ```sql
   ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
   ```

4. **Features included:**
   - User enters username
   - System displays registered email if available
   - Shows contact administrator message
   - No actual email sending (requires backend setup)
   - Placeholder for future SMTP integration

5. **Optional: Add "Forgot Password" link to login page**
   - Find the login form in the HTML
   - Add this below the login button:
   ```html
   <div style="text-align: center; margin-top: 15px;">
       <a href="#" onclick="event.preventDefault(); renderForgotPassword(); return false;" style="color: #3498db; text-decoration: none;">
           Forgot Password?
       </a>
   </div>
   ```

---

## Feature 4: Email Field in Registration Forms

### Status: Instructions ready in text file

### What needs to be done:

Follow the detailed instructions in `email_field_registration.txt`:

1. **Teacher Registration** - Email field exists, just needs to be added to user creation
2. **Coordinator Registration** - Add email field to form and user creation
3. **Class Teacher Registration** - Email field exists, add to user creation
4. **Parent Registration** - Add parent email field to student/parent registration

### Quick Summary:
- Add `email` input fields where missing
- Read email values in form submission handlers
- Include `email: email || null` in user insert statements

---

## Feature 5: Class Teacher Registration

### Status: ✅ ALREADY COMPLETE

- Class teacher registration option exists (line 8370)
- Full form implementation from lines 9001-9163
- Creates both `class_teachers` table entry and `users` table entry
- Assigns class teacher to class
- Email field already present

---

## Database Schema Requirements

### Required Columns in `users` table:

```sql
-- Email column (for all users)
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;

-- PIN columns (for VPs)
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_open TEXT DEFAULT 'VP321';
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_shuffle TEXT DEFAULT 'VP123';
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin_export TEXT DEFAULT 'VP000';
```

Run these SQL commands in your Supabase SQL Editor.

---

## Implementation Steps (Recommended Order)

### Step 1: Update Database Schema
1. Open Supabase SQL Editor
2. Run the SQL commands above to add columns
3. Verify columns were created successfully

### Step 2: Add Email Fields to Registration Forms
1. Open `dashboard.html`
2. Follow instructions in `email_field_registration.txt`
3. Test each registration form after changes

### Step 3: Implement Change Password with PINs
1. Find `function renderChangePassword()` at line ~1995
2. Replace entire function with code from `change_password_pin_management.js`
3. Test password change and PIN management

### Step 4: Implement Forgot Password
1. Copy `renderForgotPassword()` function from `forgot_password_feature.js`
2. Insert after `renderChangePassword()` function
3. Optionally add "Forgot Password" link to login page
4. Test with users who have email addresses

### Step 5: Implement Student Shuffling
1. Find line 8169 (before `async function renderRemoveStudent()`)
2. Insert entire code from `shuffle_students_feature.js`
3. Test shuffle functionality with default PINs:
   - Opening PIN: VP321
   - Reshuffle PIN: VP123
   - Export PIN: VP000

### Step 6: Comprehensive Testing

Test each feature:
- [ ] Student shuffle with all 3 PINs
- [ ] PIN management in change password
- [ ] Forgot password retrieval
- [ ] Email field in all registration forms
- [ ] Class teacher registration

---

## Default PIN Values

- **Opening PIN**: VP321 (access shuffle students page)
- **Reshuffle PIN**: VP123 (confirm shuffle action)
- **Export PIN**: VP000 (export PDF)

VPs can change these PINs in the Change Password page.

---

## Troubleshooting

### If PINs don't work:
1. Check database columns exist
2. Verify default values are set
3. Check browser console for errors

### If email doesn't show in forgot password:
1. Ensure `email` column exists in `users` table
2. Check that registration forms are saving email
3. Verify user has email in database

### If shuffle doesn't work:
1. Check user role is 'viceprincipal', 'superviceprincipal', or 'hassan'
2. Verify `verifyVPPin()` function is present
3. Check browser console for errors

---

## Security Notes

1. **PINs are stored in plaintext** - For production, consider hashing
2. **Email verification** - Currently shows email without additional verification
3. **PDF export** - Uses browser print dialog, no server-side generation
4. **Database updates** - Shuffle applies changes directly, ensure backup before testing

---

## Future Enhancements

1. **Email Sending**: Integrate with Supabase Edge Functions or external SMTP service
2. **PIN Hashing**: Hash PINs for better security
3. **Audit Log**: Track shuffle operations
4. **Bulk Email**: Send shuffle results to all parents
5. **Advanced Shuffle**: Add criteria like gender balance, academic performance, etc.

---

## Support

If you encounter issues:
1. Check browser console for error messages
2. Verify database schema matches requirements
3. Test with default PIN values first
4. Ensure user has correct role permissions

---

## Completion Checklist

- [x] Menu items added
- [ ] Database columns created
- [ ] Shuffle students function inserted
- [ ] Change password function replaced
- [ ] Forgot password function added
- [ ] Email fields added to registration
- [ ] All features tested

---

**Last Updated**: February 23, 2026
**Implementation Status**: Code ready, needs integration into dashboard.html
