# CampusCore - Smart School Management System

A comprehensive school management system built for DPS Nadergul, featuring role-based access, attendance tracking, homework management, exam scheduling, and more.

## Features

- **Multi-user Role Support**: Parents, Teachers, Coordinators, Vice Principals, Super Vice Principals, and Class Teachers
- **Attendance Management**: Track student attendance with behavior notes
- **Homework System**: Assign and view homework assignments
- **Exam Management**: Schedule exams and record results
- **Timetable Viewer**: View class-wise timetables
- **Issue Reporting**: Report and track issues
- **Profile Management**: View profiles and change passwords
- **Real-time Data**: Powered by Supabase for real-time synchronization

## Tech Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Supabase (PostgreSQL database)
- **Hosting**: GitHub Pages
- **Authentication**: Custom authentication with Supabase

## Project Structure

```
campuscore/
├── index.html                  # Login page
├── dashboard.html              # Main dashboard (role-based)
├── assets/
│   ├── css/
│   │   └── style.css          # All styles
│   └── js/
│       ├── config.js          # Supabase configuration
│       ├── supabase-client.js # Supabase client initialization
│       ├── auth.js            # Authentication module
│       ├── database.js        # Database operations
│       └── utils.js           # Utility functions
├── supabase-schema.sql        # Database schema
├── supabase-init-data.sql     # Sample data
└── README.md                  # This file
```

## Setup Instructions

### 1. Supabase Setup

1. Go to [Supabase](https://supabase.com) and create a new project
2. Once the project is created, go to the SQL Editor
3. Run the schema creation script:
   - Copy all content from `supabase-schema.sql`
   - Paste it in the SQL Editor
   - Click "Run"
4. Initialize sample data:
   - Copy all content from `supabase-init-data.sql`
   - Paste it in the SQL Editor
   - Click "Run"
5. Get your Supabase credentials:
   - Go to Project Settings → API
   - Copy the Project URL
   - Copy the `anon` public key

### 2. Configure the Application

Update the Supabase configuration in `assets/js/supabase-client.js`:

```javascript
const SUPABASE_URL = 'YOUR_PROJECT_URL';
const SUPABASE_KEY = 'YOUR_ANON_KEY';
```

### 3. Local Development

Simply open `index.html` in a web browser, or use a local server:

```bash
# Using Python 3
python -m http.server 8000

# Using Node.js (http-server)
npx http-server

# Using VS Code Live Server extension
# Right-click on index.html → Open with Live Server
```

Then navigate to `http://localhost:8000` in your browser.

### 4. GitHub Pages Deployment

1. **Create a GitHub Repository**:
   ```bash
   cd campuscore
   git init
   git add .
   git commit -m "Initial commit: CampusCore multi-page with Supabase"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git push -u origin main
   ```

2. **Enable GitHub Pages**:
   - Go to your repository on GitHub
   - Click on "Settings"
   - Scroll down to "Pages" in the left sidebar
   - Under "Source", select "main" branch
   - Click "Save"
   - Your site will be published at `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`

3. **Access Your Application**:
   - Wait a few minutes for GitHub to build your site
   - Visit `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`
   - You should see the login page

## Login Credentials

Use these credentials to test different roles:

### Parents
- **Username**: `P3180076A` | **Password**: `parent123` (Kasula Ashwath's parent)
- **Username**: `P3180077A` | **Password**: `parent123` (Srikar's parent)
- **Username**: `P3180078A` | **Password**: `parent123` (Fatima's parent)
- **Username**: `P3240504A` | **Password**: `parent123` (Sai Charan's parent)

### Teachers
- **Username**: `T001` | **Password**: `teacher123` (English Teacher)
- **Username**: `T002` | **Password**: `teacher123` (Math Teacher)
- **Username**: `T003` | **Password**: `teacher123` (Science Teacher)

### Coordinator
- **Username**: `C001` | **Password**: `coord123` (Coordinator Anitha)

### Vice Principal
- **Username**: `VP001` | **Password**: `VP123` (Sirisha Vice Principal)

### Super Vice Principal
- **Username**: `AP000123` | **Password**: `DPSSITE123` (Super Principal)

### Class Teachers
- **Username**: `CT10A` | **Password**: `CLASS123` (Class Teacher 10A)
- **Username**: `CT8B` | **Password**: `CLASS123` (Class Teacher 8B)

## Database Schema

The application uses the following main tables:

- **users**: Login credentials and roles
- **students**: Student information
- **parents**: Parent information linked to students
- **teachers**: Teacher information
- **class_teachers**: Class teacher assignments
- **coordinators**: Coordinator information
- **vice_principals**: Vice principal information
- **super_vice_principals**: Super vice principal information
- **attendance**: Daily attendance records
- **homework**: Homework assignments
- **exam_schedules**: Exam schedule information
- **exam_results**: Exam results and grades
- **report_cards**: Consolidated report cards
- **timetables**: Class-wise timetables
- **teacher_timetables**: Teacher-specific schedules
- **issues**: Issue tracking system
- **holidays**: Holiday calendar
- **classes**: Class information
- **teacher_duties**: Teacher duty assignments
- **teacher_appointments**: Teacher appointment records
- **cca_calendars**: CCA (Co-Curricular Activities) calendar

## Role-Based Features

### Parent
- View student dashboard
- Check attendance records
- View homework assignments
- View exam results and report cards
- View exam schedule
- View class timetable
- View profile
- Change password

### Teacher
- View dashboard
- View assigned duties
- Mark student attendance
- Assign homework
- Upload exam marks
- View assigned classes
- Report issues
- View timetable
- Change password

### Coordinator
- View dashboard
- Manage reported issues
- Upload exam schedules
- Manage classes
- Manage timetables
- Upload CCA calendar
- Change password

### Vice Principal / Super Vice Principal
- View dashboard
- Appoint teachers
- Assign teacher duties
- Manage escalated issues
- Remove students
- Delete student data (Super VP only)
- Manage holidays
- Register new users
- View analytics
- Change password

### Class Teacher
- View dashboard
- View class-specific dashboard
- Mark attendance for their class
- Assign homework
- Manage report cards
- View assigned duties
- Change password

## Browser Compatibility

- Chrome (recommended)
- Firefox
- Safari
- Edge

## Security Notes

- **Important**: This application uses plain-text passwords for educational purposes
- **For Production**: Implement proper password hashing (bcrypt, argon2, etc.)
- **Row Level Security**: Currently disabled in Supabase; enable RLS policies for production
- **API Keys**: The `anon` key is safe to expose in client-side code
- **Never expose**: The `service_role` key should never be used in client-side code

## Troubleshooting

### Issue: "Failed to initialize application"
- Check your Supabase credentials in `assets/js/supabase-client.js`
- Ensure your Supabase project is active
- Check browser console for detailed error messages

### Issue: "Invalid username or password" or Login not working
- **MOST COMMON FIX**: Disable Row Level Security (RLS) on all tables
- Go to Supabase Dashboard → SQL Editor → New Query
- Copy all contents from `disable-rls.sql` file
- Paste and click "Run"
- Clear browser cache and try login again
- Verify you've run the `supabase-init-data.sql` script
- Check the username and password match one from the credentials list

### Issue: VP Analytics not showing students or "No students found"
- **MOST COMMON FIX**: Disable Row Level Security (RLS) - see fix above
- Run the `disable-rls.sql` script in Supabase SQL Editor
- Clear browser cache and refresh the page
- Check browser console (F12) for detailed error messages

### Issue: Database errors or 406 errors
- Verify all tables were created by running `supabase-schema.sql`
- **IMPORTANT**: Disable Row Level Security by running `disable-rls.sql`
- Inspect the Supabase logs in the dashboard
- Check browser console for detailed error messages

### Issue: Page not loading on GitHub Pages
- Ensure `.nojekyll` file exists in the root directory
- Check that GitHub Pages is enabled in repository settings
- Wait a few minutes for GitHub to build and deploy

## Future Enhancements

- Email notifications for homework and exam schedules
- File upload for assignments
- Video conferencing integration
- Mobile app (React Native/Flutter)
- Advanced analytics and reporting
- SMS notifications for parents
- Online fee payment
- Bus tracking system

## Contributing

This is an educational project. Feel free to fork and enhance!

## License

This project is for educational purposes.

## Support

For issues or questions, please contact your system administrator or create an issue in the GitHub repository.

---

**CampusCore** - The Bridge to a Smarter Tomorrow
