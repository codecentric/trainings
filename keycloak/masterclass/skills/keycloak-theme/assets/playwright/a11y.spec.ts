import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const REALM = process.env.KC_REALM ?? 'demo';

// Extend with every page the theme overrides -- see references/quality.md for how to reach each one.
const pages = [
  { name: 'login', url: `/realms/${REALM}/account` },
];

for (const p of pages) {
  test(`${p.name} has no critical or serious accessibility violations`, async ({ page }) => {
    await page.goto(p.url);
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze();

    const blocking = results.violations.filter(v => ['critical', 'serious'].includes(v.impact ?? ''));
    expect(blocking.map(v => `${v.impact}: ${v.id} -- ${v.help}`).join('\n')).toBe('');
  });
}
