# CampusCore Advanced Features - Quick Reference Card

## Overview
4 new advanced features implemented for the CampusCore dashboard system.

---

## Feature 1: Student Shuffling System 🔀

**Access**: Vice Principals only
**Menu Location**: Shuffle Students

### Security PINs:
- **Opening PIN**: VP321 (to access page)
- **Reshuffle PIN**: VP123 (to execute shuffle)
- **Export PIN**: VP000 (to export PDF)

### Quick Steps:
1. Click "Shuffle Students" → Enter VP321
2. Select grade (6-10) → Load Students
3. Review distribution → Click "Shuffle"
4. Enter VP123 → View results
5. Export PDF (VP000) or Apply to Database

**File**: `shuffle_students_feature.js` (615 lines)
**Insert at**: Line 8169 in dashboard.html

---

## Feature 2: PIN Management 🔑

**Access**: Vice Principals only
**Location**: Change Password tab

### What it does:
- VPs see 3 additional PIN fields
- Change Opening, Reshuffle, Export PINs
- Leave blank to keep current PIN
- Min 4 characters validation

**File**: `change_password_pin_management.js` (150 lines)
**Replace**: Line 1995 in dashboard.html

### Database:
```sql
ALTER TABLE users ADD COLUMN pin_open TEXT DEFAULT 'VP321';
ALTER TABLE users ADD COLUMN pin_shuffle TEXT DEFAULT 'VP123';
ALTER TABLE users ADD COLUMN pin_export TEXT DEFAULT 'VP000';
```

---

## Feature 3: Forgot Password 🔐

**Access**: All users
**Location**: Login page / Menu

### What it does:
- Enter username → Get registered email
- Contact administrator message
- No auto-email (placeholder for SMTP)

**File**: `forgot_password_feature.js` (120 lines)
**Insert**: After renderChangePassword() function

### Database:
```sql
ALTER TABLE users ADD COLUMN email TEXT;
```

---

## Feature 4: Email in Registration 📧

**Access**: VPs (via Register menu)
**Affected Forms**: Teacher, Coordinator, Class Teacher, Parent

### Changes needed:
1. Add email input fields (where missing)
2. Read email values in submit handlers
3. Include `email: email || null` in user inserts

**File**: `email_field_registration.txt` (detailed instructions)

---

## Implementation Checklist

### Database Setup (5 min):
```sql
-- Required columns
ALTER TABLE users ADD COLUMN email TEXT;
ALTER TABLE users ADD COLUMN pin_open TEXT DEFAULT 'VP321';
ALTER TABLE users ADD COLUMN pin_shuffle TEXT DEFAULT 'VP123';
ALTER TABLE users ADD COLUMN pin_export TEXT DEFAULT 'VP000';
```

### Code Integration (30 min):
- [ ] Insert shuffle_students_feature.js at line 8169
- [ ] Replace renderChangePassword() at line 1995
- [ ] Insert renderForgotPassword() after renderChangePassword()
- [ ] Update registration forms per email_field_registration.txt

### Testing (15 min):
- [ ] Test shuffle with all 3 PINs
- [ ] Test PIN management
- [ ] Test forgot password
- [ ] Test email fields in registration
- [ ] Test as VP, SVP, Hassan roles

---

## Files Delivered

| File | Size | Purpose |
|------|------|---------|
| `shuffle_students_feature.js` | 23KB | Complete shuffle system |
| `change_password_pin_management.js` | 6.9KB | PIN management |
| `forgot_password_feature.js` | 7.1KB | Password recovery |
| `email_field_registration.txt` | 4.4KB | Email integration guide |
| `IMPLEMENTATION_GUIDE.md` | 8KB | Step-by-step guide |
| `FEATURE_IMPLEMENTATION_SUMMARY.md` | 12KB | Complete documentation |

---

## Default Credentials

### Test PINs:
- Opening: **VP321**
- Reshuffle: **VP123**
- Export: **VP000**

### Test User:
- Username: **Hassan** (or any VP account)
- Role: viceprincipal/superviceprincipal/hassan

---

## Quick Troubleshooting

**PINs don't work?**
→ Check database columns exist and have default values

**Email not showing?**
→ Verify email column exists and users have email addresses

**Shuffle not accessible?**
→ Confirm user role is VP/SVP/Hassan

**PDF won't generate?**
→ Check browser allows pop-ups and print dialog

---

## Support Files

📁 **Main Code Files**:
- shuffle_students_feature.js
- change_password_pin_management.js
- forgot_password_feature.js

📄 **Documentation**:
- IMPLEMENTATION_GUIDE.md
- FEATURE_IMPLEMENTATION_SUMMARY.md
- email_field_registration.txt

🔍 **Quick Reference**:
- This file (QUICK_REFERENCE_ADVANCED_FEATURES.md)

---

## Contact

For implementation assistance:
- Review IMPLEMENTATION_GUIDE.md
- Check FEATURE_IMPLEMENTATION_SUMMARY.md
- Follow email_field_registration.txt

---

**Version**: 1.0
**Date**: February 23, 2026
**Status**: Ready for Production
**Total Lines**: ~885 lines of new code
