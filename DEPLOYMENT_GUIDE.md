# CampusCore Deployment Guide

## Overview
CampusCore is a static web application (HTML/CSS/JS) with Supabase as the backend database. You need to:
1. Deploy the database schema to Supabase ✓ (Already done)
2. Deploy the frontend files to a hosting service

---

## Option 1: GitHub Pages (Recommended - FREE)

### Prerequisites
- GitHub account
- Git repository (you already have one)

### Steps:

#### 1. Prepare Your Repository
```bash
# Make sure all files are committed
git add .
git commit -m "Prepare for deployment"
```

#### 2. Push to GitHub
```bash
# If you haven't set up remote yet
git remote add origin https://github.com/YOUR_USERNAME/campuscore.git

# Push your code
git push -u origin main
```

#### 3. Enable GitHub Pages
1. Go to your GitHub repository
2. Click **Settings** → **Pages** (left sidebar)
3. Under **Source**, select:
   - Branch: `main`
   - Folder: `/ (root)`
4. Click **Save**

#### 4. Wait for Deployment
- GitHub will build your site (takes 1-2 minutes)
- Your site will be available at: `https://YOUR_USERNAME.github.io/campuscore/`

#### 5. Access Your App
- Visit: `https://YOUR_USERNAME.github.io/campuscore/`
- Login with your credentials!

### Important Notes:
- The `.nojekyll` file is already in your project (prevents Jekyll processing)
- Your Supabase keys are already configured in `assets/js/supabase-client.js`
- GitHub Pages is free for public repositories

---

## Option 2: Netlify (Easy Drag & Drop - FREE)

### Steps:

#### 1. Create Netlify Account
- Go to https://www.netlify.com/
- Sign up (free account)

#### 2. Deploy via Drag & Drop
1. Click **"Add new site"** → **"Deploy manually"**
2. Drag your entire `campuscore` folder into the upload area
3. Wait for deployment (30 seconds)
4. Your site will be live at: `https://random-name.netlify.app`

#### 3. Custom Domain (Optional)
- Go to **Site settings** → **Domain management**
- Add your custom domain or use Netlify's free subdomain

---

## Option 3: Vercel (Fast & Easy - FREE)

### Steps:

#### 1. Create Vercel Account
- Go to https://vercel.com/
- Sign up with GitHub (recommended)

#### 2. Deploy from GitHub
1. Click **"Add New Project"**
2. Import your `campuscore` repository
3. Configure:
   - Framework Preset: **Other**
   - Root Directory: `./`
   - Build Command: (leave empty)
   - Output Directory: (leave empty)
4. Click **"Deploy"**

#### 3. Access Your Site
- Your site will be live at: `https://campuscore.vercel.app`

---

## Option 4: Firebase Hosting (Google - FREE)

### Prerequisites
```bash
npm install -g firebase-tools
```

### Steps:

#### 1. Initialize Firebase
```bash
# Login to Firebase
firebase login

# Initialize in your project folder
firebase init hosting
```

#### 2. Configure
- Choose: **Use an existing project** or **Create new project**
- Public directory: enter `.` (current directory)
- Single-page app: **No**
- Overwrite files: **No**

#### 3. Deploy
```bash
firebase deploy
```

#### 4. Access Your Site
- Your site will be at: `https://your-project.web.app`

---

## Post-Deployment Checklist

### 1. Verify Supabase Configuration
✓ Database tables created
✓ RLS disabled (or policies configured)
✓ Permissions granted to anon role
✓ API keys configured in `supabase-client.js`

### 2. Test Your Deployment
- [ ] Open deployed URL
- [ ] Test login functionality
- [ ] Check browser console for errors
- [ ] Test all user roles (parent, teacher, etc.)
- [ ] Verify data loads correctly

### 3. Security Best Practices

⚠️ **IMPORTANT SECURITY NOTES:**

1. **Never commit sensitive keys** to public repositories
   - Move Supabase keys to environment variables for production

2. **Enable RLS in Production**
   - Current setup has RLS disabled (for development)
   - For production, enable RLS with proper policies

3. **Use HTTPS**
   - All hosting options above provide free HTTPS
   - Never deploy without SSL certificate

4. **Implement Proper Password Hashing**
   - Current setup stores plain text passwords (educational only)
   - Production should use bcrypt/Supabase Auth

---

## Updating Your Deployed Site

### GitHub Pages
```bash
git add .
git commit -m "Update site"
git push origin main
# GitHub Pages auto-deploys in 1-2 minutes
```

### Netlify
- **Automatic:** Connect GitHub repo for auto-deployment
- **Manual:** Drag & drop new folder in Netlify dashboard

### Vercel
- **Automatic:** Pushes to GitHub auto-deploy
- **Manual:** Click "Redeploy" in Vercel dashboard

---

## Troubleshooting

### Issue: Login Not Working
```
Error: "permission denied for table users"
```
**Solution:** Run this in Supabase SQL Editor:
```sql
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
```

### Issue: 404 on Page Refresh
**Solution:** Add this to your hosting config:
- **Netlify:** Create `_redirects` file with: `/* /index.html 200`
- **Vercel:** Create `vercel.json` (see below)

### Issue: Assets Not Loading
- Check file paths are relative (no leading `/` for GitHub Pages)
- Verify all files are committed and pushed

---

## Custom Domain Setup

### For GitHub Pages:
1. Go to **Settings** → **Pages**
2. Enter your custom domain
3. Add DNS records at your domain provider:
   ```
   Type: CNAME
   Name: www
   Value: YOUR_USERNAME.github.io
   ```

### For Netlify/Vercel:
1. Go to domain settings in dashboard
2. Follow DNS configuration instructions
3. Wait for DNS propagation (up to 24 hours)

---

## Production Configuration

### Create `vercel.json` (for Vercel):
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### Create `_redirects` (for Netlify):
```
/* /index.html 200
```

---

## Need Help?

- **GitHub Pages Issues:** https://docs.github.com/pages
- **Netlify Support:** https://docs.netlify.com/
- **Vercel Support:** https://vercel.com/docs
- **Supabase Docs:** https://supabase.com/docs

---

## Summary

**Easiest Option:** Netlify (drag & drop)
**Best for Git Users:** GitHub Pages or Vercel
**Recommended:** GitHub Pages (free, simple, already using Git)

Your app is ready to deploy! Just follow the steps above for your preferred platform.
