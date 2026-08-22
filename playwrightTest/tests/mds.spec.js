const path = require('path');
const { test, expect } = require('@playwright/test');

function toISO(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function getAppUrl() {
  return 'file://' + path.resolve(__dirname, '..', '..', 'MDS_html.html');
}

test.describe('MDS HTML automation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(getAppUrl());
  });

  test('checks field limits and blocks invalid generation', async ({ page }) => {
    await expect(page.locator('#age')).toHaveAttribute('min', '18');
    await expect(page.locator('#age')).toHaveAttribute('max', '110');
    await expect(page.locator('#residentName')).toHaveAttribute('maxlength', '30');
    await expect(page.locator('#dpoa')).toHaveAttribute('maxlength', '30');

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const minDate = new Date(today);
    minDate.setFullYear(minDate.getFullYear() - 1);

    await expect(page.locator('#ard')).toHaveAttribute('min', toISO(minDate));
    await expect(page.locator('#ard')).toHaveAttribute('max', toISO(today));

    await page.fill('#residentName', 'A'.repeat(35));
    await expect(page.locator('#residentName')).toHaveValue('A'.repeat(30));

    await page.fill('#dpoa', 'B'.repeat(35));
    await expect(page.locator('#dpoa')).toHaveValue('B'.repeat(30));

    await page.fill('#age', '16');
    await page.selectOption('#noteType', { label: 'Admission' });
    await page.click('#generateBtn');
    await expect(page.locator('#output')).toHaveValue('');

    await page.fill('#age', '120');
    await page.click('#generateBtn');
    await expect(page.locator('#output')).toHaveValue('');

    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    await page.fill('#ard', toISO(tomorrow));
    // The app no longer auto-clears an out-of-range ARD; the invalid value
    // should remain and generation should be blocked by validation.
    await expect(page.locator('#ard')).toHaveValue(toISO(tomorrow));
    await page.fill('#age', '82');
    // Generate button should be disabled when ARD is invalid
    await expect(page.locator('#generateBtn')).toBeDisabled();
    await expect(page.locator('#output')).toHaveValue('');
  });

  test('generates a valid MDS note', async ({ page }) => {
    const validArd = new Date();
    validArd.setDate(validArd.getDate() - 30);

    await page.fill('#residentName', 'Jane Doe');
    await page.fill('#age', '82');
    await page.fill('#ard', toISO(validArd));
    await page.fill('#dpoa', 'John Doe');
    await page.selectOption('#noteType', { label: 'Admission' });
    await page.selectOption('#orientation', { label: 'Resident is alert and oriented x4.' });
    await page.selectOption('#bims', { label: 'with a score of 9/15. SW proceeded to PHQ-2 to 9 assessment.' });
    await page.selectOption('#phq', { label: '9/27, indicating mild depression.' });
    await page.selectOption('#behavior', { label: "Resident's behavior is stable. No physical, verbal or other behaviors noted or reported." });
    await page.selectOption('#careConference', { label: 'offered and accepted.' });
    await page.selectOption('#polst', { label: 'FULL CODE / FULL TREATMENT' });

    const formState = await page.evaluate(() => ({
      residentName: document.getElementById('residentName').value,
      age: document.getElementById('age').value,
      ard: document.getElementById('ard').value,
      dpoa: document.getElementById('dpoa').value,
      noteType: document.getElementById('noteType').value,
      orientation: document.getElementById('orientation').value,
      bims: document.getElementById('bims').value,
    }));
    console.log('formState before generate:', formState);

    // invoke the page's generate handler directly for determinism
    await page.evaluate(() => { if (typeof generateNote === 'function') generateNote(); });

    // debug: capture the raw output value immediately after generation
    const rawOut = await page.evaluate(() => document.getElementById('output').value);
    console.log('generated output length:', rawOut.length);
    console.log(rawOut.slice(0,200));

    const output = page.locator('#output');
    // allow more time for the client-side generation to complete in CI/headless
    await expect(output).not.toHaveValue('', { timeout: 15000 });
    const outVal = await output.inputValue();
    expect(outVal).toContain('MDS Admission NOTE');
    expect(outVal).toContain('Resident prefers to be called Jane Doe');
    expect(outVal).toContain('The resident is 82 years old');
  });
});
