import { defineConfig, devices } from '@playwright/test';

// Adapt BASE_URL / realm / client to the dev instance from compose.yaml.
export default defineConfig({
  testDir: '.',
  timeout: 30_000,
  expect: { timeout: 5_000 },
  reporter: [['list'], ['html', { outputFolder: 'playwright-report', open: 'never' }]],
  use: {
    baseURL: process.env.KC_URL ?? 'http://localhost:8080',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
  },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile',  use: { ...devices['Pixel 7'] } },
    // Login must work without JavaScript.
    { name: 'no-js',   use: { ...devices['Desktop Chrome'], javaScriptEnabled: false } },
  ],
});
