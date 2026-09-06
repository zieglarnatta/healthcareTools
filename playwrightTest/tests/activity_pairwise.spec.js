const path = require('path');
const { test, expect } = require('@playwright/test');

function getAppUrl() {
  return 'file://' + path.resolve(__dirname, '..', '..', 'MDS_activity_note.html');
}

const cases = require('../../cypressTest/cypress/fixtures/pairwise_activity_cases.json');

// Helper to decide if age should block generation per app validation
function isAgeInvalid(ageStr) {
  if (!ageStr) return false;
  const a = Number(ageStr);
  return Number.isNaN(a) ? false : (a < 18 || a > 110);
}

test.describe('Pairwise activity cases (generated)', () => {
  for (const tc of cases) {
    test(tc.name || 'case', async ({ page }) => {
      await page.goto(getAppUrl());

      if (tc.residentName !== undefined) await page.fill('#residentName', tc.residentName);
      if (tc.age !== undefined) await page.fill('#age', String(tc.age));
      if (tc.ard !== undefined) await page.fill('#ard', tc.ard);
      if (tc.noteType) await page.selectOption('#noteType', { label: tc.noteType }).catch(() => {});
      if (tc.cognition) await page.selectOption('#cognition', { label: tc.cognition }).catch(() => {});
      if (tc.communication) await page.selectOption('#communication', { label: tc.communication }).catch(() => {});
      if (tc.limited) await page.selectOption('#limited', { label: tc.limited }).catch(() => {});
      if (tc.misc) await page.selectOption('#misc', { label: tc.misc }).catch(() => {});

      const outputLocator = page.locator('#output');

      // Click generate and let page-side validation run
      await page.click('#generateBtn');

      if (isAgeInvalid(tc.age)) {
        // generation should be blocked by age validation
        await expect(outputLocator).toHaveText('', { timeout: 2000 });
      } else {
        // output (a div) should be populated
        await expect(outputLocator).not.toHaveText('', { timeout: 10000 });
      }
    });
  }
});
