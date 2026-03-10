# CampusCore - Quick Start Guide
## New Features Implementation

---

## 🚀 Quick Steps to Get Started

### Step 1: Update Test Students to Grade 8

1. **Open Supabase Dashboard**
   - Go to your Supabase project
   - Click on "SQL Editor" in the left sidebar

2. **Run the First Query**
   ```sql
   -- See all current students
   SELECT id, name, class, status
   FROM students
   ORDER BY id
   LIMIT 50;
   ```

3. **Choose Your Update Method**

   **Option A - Update by Name Pattern:**
   ```sql
   UPDATE students
   SET class = '8A'
   WHERE LOWER(name) LIKE '%test%'
      OR LOWER(name) LIKE '%demo%';
   ```

   **Option B - Update by Specific IDs:**
   ```sql
   UPDATE students
   SET class = '8A'
   WHERE id IN (1, 2, 3);  -- Replace with your student IDs
   ```

   **Option C - Move Entire Grade 7 to Grade 8:**
   ```sql
   UPDATE students
   SET class = REPLACE(class, '7', '8')
   WHERE class LIKE '7%';
   ```

4. **Verify the Changes**
   ```sql
   SELECT id, name, class, status
   FROM students
   WHERE class LIKE '8%'
   ORDER BY class, name;
   ```

---

### Step 2: Test the Student UP Feature

1. **Login to CampusCore**
   - Username: `VP001`
   - Password: `VP123`

2. **Access Student UP**
   - Click "Student UP" ⬆️ in the sidebar
   - Enter PIN: `AP123`
   - Click "Unlock & Continue"

3. **Test Each Tab**

   **Bulk Upload Tab:**
   - Click "Download Excel Template"
   - Fill in student details
   - Upload the file
   - Preview and confirm

   **Promote Students Tab:**
   - Select a grade (e.g., Grade 6)
   - Review promotion preview
   - Check the confirmation box
   - Click "Promote All Students"

   **Shuffle Sections Tab:**
   - Select a grade (e.g., Grade 8)
   - Review shuffle preview
   - Check the confirmation box
   - Click "Shuffle Students"

---

### Step 3: Test PDF Report Cards

1. **Login as Student or Parent**
   - Student: Username from database / `STUDENT123`
   - Parent: Username from database / `Parent@123`

2. **Navigate to Report Cards**
   - Click "Report Cards" in the sidebar

3. **Download PDF**
   - Click "📥 Download PDF" button
   - PDF will download automatically
   - Open and verify contents

---

### Step 4: View Homepage Updates

1. **Login with Any Account**

2. **Check Homepage Features**
   - School photo/logo at the top
   - Welcome message
   - Statistics cards
   - "About the Founders" section
   - Ashwath and Sai Charan profiles

---

## 🔑 Important Credentials

### Admin Accounts
| Role | Username | Password |
|------|----------|----------|
| Vice Principal | VP001 | VP123 |
| Super VP | (from database) | (from database) |

### Student Accounts (After Update)
| Username | Password | Class |
|----------|----------|-------|
| (from database) | STUDENT123 | 8A |

### Parent Accounts
| Username | Password |
|----------|----------|
| (from database) | Parent@123 |

### Special PINs
| Feature | PIN |
|---------|-----|
| Student UP | AP123 |

---

## 📋 Feature Checklist

Use this checklist to verify all features are working:

### Homepage
- [ ] School photo displays correctly
- [ ] School name and tagline visible
- [ ] Statistics cards show data
- [ ] "About the Founders" section appears
- [ ] Ashwath's profile displays
- [ ] Sai Charan's profile displays
- [ ] Layout is responsive on mobile

### Student UP Feature
- [ ] Menu item "Student UP" appears for VP
- [ ] PIN screen shows on click
- [ ] PIN "AP123" unlocks the feature
- [ ] Three tabs appear (Upload, Promote, Shuffle)
- [ ] Bulk Upload tab loads template
- [ ] Promote tab shows grade selection
- [ ] Shuffle tab shows grade selection
- [ ] All operations complete successfully

### Report Cards
- [ ] Report cards display for students/parents
- [ ] "Download PDF" button appears on each card
- [ ] PDF downloads on button click
- [ ] PDF contains school name
- [ ] PDF shows student info correctly
- [ ] PDF displays marks and grade
- [ ] PDF includes remarks (if any)
- [ ] PDF has signature lines
- [ ] Filename is correct format

### Database Updates
- [ ] Test students are in Grade 8A
- [ ] All student data preserved
- [ ] Parent linkages still work
- [ ] No data loss occurred

---

## 🐛 Troubleshooting

### Issue: PIN doesn't work
**Solution:** Make sure you're entering exactly `AP123` (case-sensitive)

### Issue: PDF doesn't download
**Solution:**
- Check browser popup blocker
- Try different browser
- Check console for errors

### Issue: Students not in Grade 8
**Solution:**
- Re-run the SQL update script
- Check student IDs are correct (must be numeric)
- Verify using the SELECT statement

### Issue: Menu item doesn't appear
**Solution:**
- Confirm you're logged in as VP or SVP
- Clear browser cache
- Hard refresh page (Ctrl+F5)

### Issue: Upload fails
**Solution:**
- Verify Excel/CSV format matches template
- Check file size is under 5MB
- Ensure all required columns are present

---

## 📞 Common Questions

**Q: Will promoting students delete their data?**
A: No! All attendance, exam results, and homework are preserved. Only the class field changes.

**Q: Can I undo a promotion or shuffle?**
A: Not automatically. You would need to manually change student classes back or restore from a database backup.

**Q: What happens to Grade 10 students during promotion?**
A: Grade 10 is the maximum. The system won't allow promoting Grade 10 students.

**Q: Can parents download report cards?**
A: Yes! Parents see their child's report cards and can download PDFs.

**Q: Is the PIN secure?**
A: The PIN (AP123) is client-side protection. For production, consider storing it in the database and adding server-side validation.

---

## 🎯 Best Practices

### Before Bulk Operations:
1. ✅ Backup your database
2. ✅ Test on 2-3 students first
3. ✅ Verify results before full rollout
4. ✅ Notify staff about upcoming changes

### For Report Cards:
1. ✅ Ensure all marks are entered before generating
2. ✅ Add meaningful teacher remarks
3. ✅ Test PDF on different devices
4. ✅ Keep PDFs for records

### For Student Management:
1. ✅ Keep PIN confidential
2. ✅ Only authorized personnel should access
3. ✅ Double-check grade selections
4. ✅ Preview before confirming changes

---

## 📚 File Locations

| File | Purpose | Location |
|------|---------|----------|
| dashboard.html | Main application | `/dashboard.html` |
| update-test-students-grade8.sql | SQL update script | `/update-test-students-grade8.sql` |
| IMPLEMENTATION_SUMMARY.md | Full documentation | `/IMPLEMENTATION_SUMMARY.md` |
| QUICK_START_GUIDE.md | This guide | `/QUICK_START_GUIDE.md` |

---

## ✅ Success Criteria

You'll know everything is working when:

1. ✅ School logo appears on homepage
2. ✅ Founders section displays both profiles
3. ✅ Test students show class as "8A"
4. ✅ "Student UP" menu item visible for VP
5. ✅ PIN AP123 grants access
6. ✅ All three tabs (Upload, Promote, Shuffle) work
7. ✅ PDF download button appears on report cards
8. ✅ PDFs download with correct formatting

---

## 🎉 You're All Set!

All features are now implemented and ready to use. Enjoy your enhanced CampusCore system!

**Need Help?**
- Review `/IMPLEMENTATION_SUMMARY.md` for detailed documentation
- Check code comments in `dashboard.html`
- Test in development environment first

---

**Built by Ashwath and Sai Charan**
**DPS Nadergul**
**CampusCore v2.0**
