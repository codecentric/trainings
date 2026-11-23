import { test, expect, Page } from '@playwright/test';

const REALM  = process.env.KC_REALM  ?? 'demo';
const CLIENT = process.env.KC_CLIENT ?? 'account-console';
const USER   = process.env.KC_USER   ?? 'tester';
const PASS   = process.env.KC_PASS   ?? 'test';

// The account console is the simplest client that always exists and forces a login.
const loginUrl = `/realms/${REALM}/account`;

async function gotoLogin(page: Page) {
  await page.goto(loginUrl);
  await expect(page.locator('body')).toHaveAttribute('data-page-id', /^login-/);
}

test('renders the login page without leaking message keys', async ({ page }) => {
  const errors: string[] = [];
  page.on('console', m => m.type() === 'error' && errors.push(m.text()));
  page.on('response', r => r.status() >= 400 && errors.push(`${r.status()} ${r.url()}`));

  await gotoLogin(page);
  await expect(page.locator('#username')).toBeVisible();
  await expect(page.locator('#password')).toBeVisible();
  await expect(page.locator('#kc-login')).toBeVisible();

  const body = await page.locator('body').innerText();
  expect(body).not.toMatch(/\?\?[\w.]+\?\?/);          // missing message key
  expect(errors, errors.join('\n')).toHaveLength(0);   // no JS errors, no 404 on theme resources
});

test('wrong password shows an accessible error and does not disclose the account', async ({ page }) => {
  await gotoLogin(page);
  await page.fill('#username', USER);
  await page.fill('#password', 'definitely-wrong');
  await page.click('#kc-login');

  const err = page.locator('#input-error, [role="alert"]').first();
  await expect(err).toBeVisible();
  await expect(err).toHaveAttribute('aria-live', /polite|assertive/);
  await expect(err).not.toContainText(/user (does not exist|not found)/i);
});

test('happy path signs the user in', async ({ page }) => {
  await gotoLogin(page);
  await page.fill('#username', USER);
  await page.fill('#password', PASS);
  await page.click('#kc-login');
  await expect(page).not.toHaveURL(/openid-connect\/auth/);
});

test('forgot-password link leads to the reset form', async ({ page }) => {
  await gotoLogin(page);
  const link = page.locator('a[href*="login-actions/reset-credentials"]');
  test.skip(await link.count() === 0, 'reset password not enabled in this realm');
  await link.first().click();
  await expect(page.locator('body')).toHaveAttribute('data-page-id', 'login-login-reset-password');
});

test('no horizontal scrolling at 320px', async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 720 });
  await gotoLogin(page);
  const overflow = await page.evaluate(() =>
    document.documentElement.scrollWidth - document.documentElement.clientWidth);
  expect(overflow).toBeLessThanOrEqual(0);
});
