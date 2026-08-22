const path = require('path');
const { test, expect } = require('@playwright/test');

function getAppUrl() {
  return 'file://' + path.resolve(__dirname, '..', '..', 'MDS_html.html');
}

const cases = require('../../cypressTest/cypress/fixtures/pairwise_cases.json');

function isArdValid(dateStr) {
  if (!dateStr) return true;
  const d = new Date(dateStr);
  d.setHours(0,0,0,0);
  const today = new Date();
  today.setHours(0,0,0,0);
  const min = new Date(today);
  min.setFullYear(min.getFullYear() - 1);
  return d >= min && d <= today;
}

test.describe('Pairwise cases (generated)', () => {
  for (const tc of cases) {
    test(tc.name || 'case', async ({ page }) => {
      await page.goto(getAppUrl());

      if (tc.residentName) await page.fill('#residentName', tc.residentName);
      if (tc.dpoa) await page.fill('#dpoa', tc.dpoa);
      if (tc.age) await page.fill('#age', String(tc.age));
      if (tc.ard) await page.fill('#ard', tc.ard);
      if (tc.noteType) await page.selectOption('#noteType', { label: tc.noteType }).catch(() => {});
      if (tc.orientation) await page.selectOption('#orientation', { label: tc.orientation }).catch(() => {});
      if (tc.bims) await page.selectOption('#bims', { label: tc.bims }).catch(() => {});
      if (tc.phq) await page.selectOption('#phq', { label: tc.phq }).catch(() => {});
      if (tc.behavior) await page.selectOption('#behavior', { label: tc.behavior }).catch(() => {});
      if (tc.careConference) await page.selectOption('#careConference', { label: tc.careConference }).catch(() => {});
      if (tc.polst) await page.selectOption('#polst', { label: tc.polst }).catch(() => {});

      // ensure page validation has run after filling inputs, then determine button state
      await page.evaluate(() => {
        if (typeof validateFormValues === 'function') validateFormValues();
        if (typeof updateGenerateButtonState === 'function') updateGenerateButtonState();
      });
      const genDisabled = await page.locator('#generateBtn').isDisabled();

      const outputLocator = page.locator('#output');
      // invoke generation
      await page.evaluate(() => { if (typeof generateNote === 'function') generateNote(); });

      if (genDisabled) {
        // generation should be blocked
        await expect(outputLocator).toHaveValue('');
      } else {
        // wait for the client-side generation to populate the textarea
        await expect(outputLocator).not.toHaveValue('', { timeout: 10000 });
      }
    });
  }
});
