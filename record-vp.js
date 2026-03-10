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
        console.log('\n🎬 Recording VP demo with password: VP123\n');

        await page.goto('http://localhost:8000/index.html', { waitUntil: 'domcontentloaded', timeout: 30000 });
        await page.waitForTimeout(800);
        console.log('✅ Landing page loaded');

        await page.click('button.btn-primary-hero');
        await page.waitForTimeout(600);
        await page.waitForSelector('#loginModal.active', { timeout: 5000 });
        console.log('✅ Login modal opened');
        await page.waitForTimeout(1000);

        await page.click('#username');
        await page.waitForTimeout(500);
        await page.type('#username', 'VP001', { delay: 100 });
        await page.waitForTimeout(1000);
        console.log('✅ Username: VP001');

        await page.click('#password');
        await page.waitForTimeout(500);
        await page.type('#password', 'VP123', { delay: 100 });
        await page.waitForTimeout(1000);
        console.log('✅ Password: VP123');

        await page.click('button.btn-login[type="submit"]');
        console.log('✅ Login clicked');

        await page.waitForURL('**/dashboard.html', { timeout: 20000 });
        console.log('✅ Dashboard loaded');

        await page.waitForSelector('.sidebar', { timeout: 10000 });
        await page.waitForTimeout(1000);

        const tabs = ['home', 'registration', 'classstructure'];
        for (let i = 0; i < tabs.length; i++) {
            const tab = tabs[i];
            console.log(`📋 [${i + 1}/3] Clicking: ${tab}`);

            const selector = `button.menu-link[data-tab="${tab}"]`;
            await page.waitForSelector(selector, { state: 'visible', timeout: 5000 });
            await page.evaluate((s) => {
                const el = document.querySelector(s);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, selector);
            await page.waitForTimeout(500);

            await page.click(selector);
            console.log(`   ✅ ${tab}`);
            await page.waitForTimeout(1000);

            await page.evaluate(() => {
                const c = document.querySelector('.content-area');
                if (c) c.scrollTo({ top: 300, behavior: 'smooth' });
            });
            await page.waitForTimeout(600);

            await page.evaluate(() => {
                const c = document.querySelector('.content-area');
                if (c) c.scrollTo({ top: 0, behavior: 'smooth' });
            });
            await page.waitForTimeout(1000);
        }

        console.log('🔍 Testing search...');
        const searchInput = await page.$('#searchInput');
        if (searchInput) {
            await page.click('#searchInput');
            await page.waitForTimeout(500);
            await page.type('#searchInput', 'student', { delay: 150 });
            await page.waitForTimeout(800);
            await page.fill('#searchInput', '');
            console.log('✅ Search tested');
        }

        await page.click('button.menu-link[data-tab="home"]');
        await page.waitForTimeout(800);
        console.log('✅ Home');

        console.log('\n✅ VP RECORDING COMPLETE!\n');

    } catch (error) {
        console.error('❌ ERROR:', error.message);
    } finally {
        await context.close();

        const video = page.video();
        if (video) {
            const videoPath = await video.path();
            const fs = require('fs');
            const newPath = path.join('./videos', 'vp-demo.webm');

            await new Promise(resolve => setTimeout(resolve, 2000));

            if (fs.existsSync(videoPath)) {
                fs.renameSync(videoPath, newPath);
                console.log(`💾 Video: ${newPath}\n`);
            }
        }

        await browser.close();
    }
})();
