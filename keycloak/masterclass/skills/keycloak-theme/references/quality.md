# Quality process

Four gates. A theme is not delivered until gates 1–3 pass and gate 4 is reported.

## Gate 1 — Render check (mandatory, no dependencies)

FreeMarker fails at runtime, so every delivered template must be rendered once by a real Keycloak.

```bash
docker compose up -d          # theme mounted, caching disabled
docker compose logs -f keycloak | grep -iE "freemarker|template|error"
```

Reach each page and confirm HTTP 200 plus no template error in the log:

| Page | How to reach it |
|---|---|
| `login` | open the account console / any client |
| `login-reset-password` | "Forgot password?" |
| `login-update-password` | assign the required action `Update Password` to a test user |
| `login-update-profile` | required action `Update Profile` |
| `register` | enable registration in the realm |
| `terms` | required action `Terms and Conditions` |
| `login-otp` / `login-config-totp` | required action `Configure OTP` |
| `login-recovery-authn-code-*` | required action `Recovery Authentication Codes` |
| `webauthn-*` | required action `Webauthn Register` |
| `select-authenticator` | user with two second factors → "Try another way" |
| `error` / `info` | invalid link, or `?error=` on the auth endpoint |
| `login-page-expired` | open login, wait past the auth session timeout, submit |
| `logout-confirm` | `/protocol/openid-connect/logout` without id_token_hint |
| `login-oauth-grant` | client with consent required |
| `select-organization` | user in two organizations |
| emails | trigger reset/verify, read them from the dev mail catcher |

Keep a test realm that has every required action, an IdP, an org and a second factor pre-configured —
otherwise half these pages are unreachable and quietly ship untested.

## Gate 2 — Automated UI tests (Playwright)

Scaffold in `assets/playwright/`. Minimum suite:

1. **Happy path** — valid credentials land on the client's redirect target.
2. **Wrong password** — error alert visible, focus reaches it, `aria-live` present, the message does
   not disclose whether the username exists.
3. **Forgot password** — link works, form submits, confirmation shown.
4. **Remember me / registration link** — present exactly when the realm enables them.
5. **i18n** — switching to each configured locale changes the visible strings; no raw message keys
   (assert no text matching `^[a-zA-Z]+\.[a-zA-Z]+$` and no `??key??`) leak into the page.
6. **Responsive** — the agreed viewports; no horizontal scrollbar, no clipped controls, targets ≥44px.
7. **No-JS** — `javaScriptEnabled: false`: the form still submits and login works.
8. **Console clean** — no JS errors, no 404 on theme resources (a mistyped `resourcesPath` shows up
   here and nowhere else).

Selectors: use `data-page-id` from the layout plus the stable Keycloak ids (`#kc-form-login`,
`#username`, `#password`, `#kc-login`, `#input-error`). Do not select on your own CSS classes —
they change with every design iteration.

## Gate 3 — Accessibility

`@axe-core/playwright` on every rendered page, WCAG 2.2 AA, **zero critical or serious violations**.
Plus manual checks axe cannot make:

- Full keyboard traversal in a sensible order; a visible `:focus-visible` style on every control.
- Contrast ≥ 4.5:1 for text, ≥ 3:1 for UI borders and focus rings — including against a background
  image or gradient at its lightest and darkest point.
- Error announcement: alert region reachable and announced after a failed submit.
- `prefers-reduced-motion: reduce` disables background animation and transitions.
- Zoom to 200% and a 320px viewport remain usable.
- Labels are real `<label for>`; placeholders are never the only label.

## Gate 4 — Acceptance criteria

Per template, written into the theme README as a checklist. Generic set:

- [ ] Renders without a FreeMarker error on the target Keycloak version
- [ ] All realm-conditional elements appear/disappear correctly (`rememberMe`, registration, reset, IdPs)
- [ ] Error and success states styled and verified with real content
- [ ] All strings from message bundles; every configured locale complete
- [ ] Design tokens only — no hardcoded hex values outside `:root`
- [ ] `demo/` and `themes/` in sync (`scripts/check-sync.sh`)
- [ ] No external network requests (verify in devtools; fonts and images self-hosted)
- [ ] Works with a password manager: correct `autocomplete`, real form submit
- [ ] Screenshot per breakpoint attached to the README

## CI

`assets/ci-github-actions.yml` is a starting point: on changes to `themes/**` and `demo/**` it boots
Keycloak with the theme mounted, waits for health, runs Playwright + axe, and uploads screenshots and
the axe report as artifacts. Adapt paths and the realm import to the repo. For GitLab/Jenkins the
shape is identical — service container, health wait, test run, artifact upload.

Keep the CI job on the **dev compose setup** (caching disabled), never on the production image, and
pin the same Keycloak version the Dockerfile pins.
