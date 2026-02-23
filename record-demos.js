const { chromium } = require('playwright');
const path = require('path');

// User credentials for different roles
const users = [
    {
        role: 'Parent',
        username: 'P3240504A',
        password: 'parent123',
        tabs: ['home', 'attendance', 'viewhomework', 'viewexamresults', 'timetable']
    },
    {
        role: 'Student',
        username: 'S3240504A',
        password: 'student123',
        tabs: ['home', 'attendance', 'viewhomework', 'viewexamresults', 'examschedule', 'timetable']
    },
    {
        role: 'Teacher',
        username: 'T001',
        password: 'teacher123',
        tabs: ['home', 'attendance', 'homework', 'marksworkflow', 'schedule', 'issues']
    },
    {
        role: 'Coordinator',
        username: 'C001',
        password: 'coordinator123',
        tabs: ['home', 'ccacalendar', 'timetablemanagement', 'exams', 'issues']
    },
    {
        role: 'VP',
        username: 'VP001',
        password: 'vp123',
        tabs: ['home', 'registration', 'classstructure', 'holidays', 'examschedule', 'issues']
    }
];

async function recordDashboard(user) {
    const browser = await chromium.launch({
        headless: false, // Show browser for debugging
        slowMo: 500 // Slow down actions for better visibility
    });

    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 },
        recordVideo: {
            dir: './videos',
            size: { width: 1920, height: 1080 }
        }
    });

    const page = await context.newPage();

    try {
        console.log(`\n🎬 Recording demo for: ${user.role}`);
        console.log(`   Username: ${user.username}`);

        // Navigate to the dashboard
        await page.goto('http://localhost:8000/dashboard.html', {
            waitUntil: 'networkidle',
            timeout: 30000
        });

        // Wait for login page to load
        await page.waitForSelector('#loginUsername', { timeout: 10000 });

        // Fill in login credentials
        await page.fill('#loginUsername', user.username);
        await page.waitForTimeout(500);
        await page.fill('#loginPassword', user.password);
        await page.waitForTimeout(500);

        // Click login button
        await page.click('#loginBtn');
        console.log(`   ✅ Logged in as ${user.role}`);

        // Wait for dashboard to load
        await page.waitForSelector('.main-content', { timeout: 10000 });
        await page.waitForTimeout(2000);

        // Navigate through different tabs
        for (const tab of user.tabs) {
            console.log(`   📱 Opening tab: ${tab}`);

            // Click the tab
            const tabSelector = `button[data-tab="${tab}"]`;
            await page.click(tabSelector);

            // Wait for content to load
            await page.waitForTimeout(3000);

            // Scroll down to show content
            await page.evaluate(() => {
                window.scrollTo({ top: 300, behavior: 'smooth' });
            });
            await page.waitForTimeout(1500);

            // Scroll back up
            await page.evaluate(() => {
                window.scrollTo({ top: 0, behavior: 'smooth' });
            });
            await page.waitForTimeout(1500);
        }

        // Test search functionality
        console.log(`   🔍 Testing search functionality`);
        await page.fill('#searchInput', 'student');
        await page.waitForTimeout(2000);

        // Clear search
        await page.fill('#searchInput', '');
        await page.waitForTimeout(1000);

        // Navigate back to home
        await page.click('button[data-tab="home"]');
        await page.waitForTimeout(2000);

        console.log(`   ✅ Recording complete for ${user.role}`);

    } catch (error) {
        console.error(`   ❌ Error recording ${user.role}:`, error.message);
    } finally {
        // Close context to save video
        await context.close();

        // Get video path
        const video = page.video();
        if (video) {
            const videoPath = await video.path();
            console.log(`   💾 Video saved to: ${videoPath}`);

            // Rename video to user role
            const fs = require('fs');
            const newPath = path.join('./videos', `${user.role.toLowerCase()}-demo.webm`);

            // Wait a bit for video to be finalized
            await new Promise(resolve => setTimeout(resolve, 2000));

            if (fs.existsSync(videoPath)) {
                fs.renameSync(videoPath, newPath);
                console.log(`   📹 Renamed to: ${newPath}`);
            }
        }

        await browser.close();
    }
}

async function main() {
    console.log('🎥 CampusCore Dashboard Demo Recording');
    console.log('=======================================\n');
    console.log('⚠️  IMPORTANT: Make sure the local server is running on http://localhost:8000\n');
    console.log('Starting in 3 seconds...\n');

    await new Promise(resolve => setTimeout(resolve, 3000));

    // Create videos directory if it doesn't exist
    const fs = require('fs');
    if (!fs.existsSync('./videos')) {
        fs.mkdirSync('./videos');
    }

    // Record each user role sequentially
    for (const user of users) {
        await recordDashboard(user);
        console.log('\n   ⏸️  Pausing 2 seconds before next recording...\n');
        await new Promise(resolve => setTimeout(resolve, 2000));
    }

    console.log('\n✅ All recordings complete!');
    console.log('📁 Videos saved in ./videos/ directory');
    console.log('\nVideos created:');
    console.log('  - parent-demo.webm');
    console.log('  - student-demo.webm');
    console.log('  - teacher-demo.webm');
    console.log('  - coordinator-demo.webm');
    console.log('  - vp-demo.webm');
}

main().catch(console.error);
