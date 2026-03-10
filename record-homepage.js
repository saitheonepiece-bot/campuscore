const { chromium } = require('playwright');
const path = require('path');

(async () => {
    const browser = await chromium.launch({ headless: false, slowMo: 300 });
    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 },
        recordVideo: { dir: './videos', size: { width: 1920, height: 1080 } }
    });
    const page = await context.newPage();

    try {
        console.log('\n🎬 Recording Homepage/Landing Page Demo\n');

        // Navigate to landing page
        await page.goto('http://localhost:8000/index.html', { waitUntil: 'domcontentloaded', timeout: 30000 });
        await page.waitForTimeout(1500);
        console.log('✅ Landing page loaded');

        // Scroll down to show features
        console.log('📜 Scrolling to show features...');
        await page.evaluate(() => {
            window.scrollTo({ top: 400, behavior: 'smooth' });
        });
        await page.waitForTimeout(2000);

        await page.evaluate(() => {
            window.scrollTo({ top: 800, behavior: 'smooth' });
        });
        await page.waitForTimeout(2000);

        await page.evaluate(() => {
            window.scrollTo({ top: 1200, behavior: 'smooth' });
        });
        await page.waitForTimeout(2000);

        // Scroll to features section if exists
        await page.evaluate(() => {
            window.scrollTo({ top: 1600, behavior: 'smooth' });
        });
        await page.waitForTimeout(2000);

        // Scroll back to top
        console.log('📜 Scrolling back to top...');
        await page.evaluate(() => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
        await page.waitForTimeout(2000);

        // Hover over "Get Started" button to show interaction
        console.log('🖱️  Highlighting Get Started button...');
        const getStartedBtn = await page.$('button.btn-primary-hero');
        if (getStartedBtn) {
            await getStartedBtn.hover();
            await page.waitForTimeout(1500);
        }

        // Show the page for a bit more
        await page.waitForTimeout(2000);

        console.log('\n✅ HOMEPAGE RECORDING COMPLETE!\n');

    } catch (error) {
        console.error('❌ ERROR:', error.message);
    } finally {
        await context.close();

        const video = page.video();
        if (video) {
            const videoPath = await video.path();
            const fs = require('fs');
            const newPath = path.join('./videos', 'homepage-demo.webm');

            await new Promise(resolve => setTimeout(resolve, 2000));

            if (fs.existsSync(videoPath)) {
                fs.renameSync(videoPath, newPath);
                console.log(`💾 Video: ${newPath}\n`);
            }
        }

        await browser.close();
    }
})();
