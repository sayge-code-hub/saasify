import { createRequire } from 'module';
import fs from 'fs';
import path from 'path';

const require = createRequire(import.meta.url);
const { chromium } = require('/tmp/node_modules/playwright-core');

const outDir = '/opt/cursor/artifacts/screenshots';
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, 'saasify-ticket-detail-70-30.png');

const browser = await chromium.launch({
  executablePath: '/usr/bin/google-chrome-stable',
  headless: true,
  args: ['--no-sandbox', '--disable-dev-shm-usage'],
});
const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });

await page.goto('http://127.0.0.1:43123/', { waitUntil: 'domcontentloaded' });
await page.evaluate(() => {
  sessionStorage.setItem(
    'saasify_auth_session',
    JSON.stringify({
      id: 'admin-1',
      name: 'Admin',
      email: 'admin@saasify.io',
      role: 'Admin',
    }),
  );
});

await page.goto('http://127.0.0.1:43123/ticketing/tickets/TCK-1038', {
  waitUntil: 'networkidle',
  timeout: 60000,
});

await page.waitForFunction(
  () => !!(document.querySelector('flt-glass-pane') || document.querySelector('canvas')),
  { timeout: 60000 },
);
await page.waitForTimeout(5000);

await page.screenshot({ path: outPath, fullPage: true });
console.log('Wrote', outPath, fs.statSync(outPath).size);

const clipped = path.join(outDir, 'saasify-ticket-detail-ledger.png');
await page.screenshot({ path: clipped });
console.log('Wrote', clipped, fs.statSync(clipped).size);
console.log('url=', page.url());

await browser.close();
