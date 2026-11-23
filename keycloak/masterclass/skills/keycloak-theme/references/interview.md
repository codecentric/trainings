# Interview catalog

Four rounds, each sized for one `AskUserQuestion` call (max 4 questions, 2–4 options each,
"Other" is added automatically and is the free-text lane). Skip anything recon already answered.
Always put the recommended option first and suffix its label with `(Recommended)`.

---

## Round 1 — Scope

**Q1 · New or existing theme?**
Build the options from the actual `themes/` listing.
- `Update <existing-theme>` — extend/redesign in place, keep the theme name and realm binding
- `New theme "<suggested-name>"` — fresh directory, needs realm binding afterwards
- `Port an existing design` — an HTML/Figma/site design exists and should become a theme

If exactly one theme exists and the prompt clearly refers to it, skip this question.

**Q2 · Keycloak target version**
Options come from `scripts/kc-version.sh`:
- the version pinned in `Dockerfile`/`VERSION` (recommend this when the repo pins one)
- the latest released version (always offer it; say so when it is newer than the pin)
- an older version, if the deployment lags

State why it matters: the base templates and available features (passkeys, organizations,
declarative user profile) differ per version, and the skill pulls the contract from that tag.

**Q3 · Which theme types?** *(multiSelect)*
- `Login` — the login forms. This is what people mean 95% of the time.
- `Email` — verification/reset/invite mails. FTL, but HTML-email rules apply (tables, inline CSS).
- `Account` — account console. **React (v3): CSS + logo overrides only**, no FTL pages. Say this out loud.
- `Welcome` — the server start page. Dev/on-prem only, irrelevant behind a reverse proxy.
- `Admin` — admin console. Also React; effectively CSS-only.

**Q4 · One design or three proposals?**
- `3 variants of the login screen, then pick one (Recommended for a new theme)` — cheap divergence early
- `1 design, iterate on it` — when a corporate design already fixes the look
- `3 variants including the follow-up screens` — only if the user insists; costs ~3× in Phase 3

---

## Round 2 — Content and templates *(only if Login was selected)*

**Q1 · Template scope** *(multiSelect — see `references/templates.md` for what each tier contains)*
- `Core` — login, username/password split, error, info, page-expired *(always needed)*
- `Password lifecycle` — forgot password, reset, forced update, update email
- `Registration & profile` — register, update profile, terms
- `MFA` — OTP setup/entry, WebAuthn/passkeys, recovery codes, authenticator selection
- `Federation & organizations` — social/IdP buttons, IdP linking, organization selection
- `Session & consent` — logout confirm, front-channel logout, OAuth grant, device flow

**Q2 · Elements on the login screen** *(multiSelect)*
- Logo / wordmark
- Background (image, gradient, or animation)
- "Remember me"
- "Forgot password?"
- Registration link
- Password visibility toggle
- Social / IdP buttons
- Language switcher
- Footer with legal links (Imprint / Privacy — often mandatory in DE/EU)
- Support or contact hint
- Back-to-application link
- Organization / tenant name display

Ask which of these are **required by the realm config** vs. wanted: `realm.rememberMe`,
`realm.resetPasswordAllowed`, `realm.registrationAllowed` and the IdP list decide whether the
markup is even reachable. Check the realm config in the repo instead of guessing.

**Q3 · Languages** *(multiSelect)*
- `de` / `en` / others; and whether a visible language switcher is wanted.
- Warn: enabling `locales` without `realm.internationalizationEnabled` shows nothing.
- Ask about RTL only if a RTL locale is picked.

**Q4 · Dark mode**
- `Follow prefers-color-scheme (Recommended)` — one token set, one media query override
- `Light only`
- `Dark only`
- `Manual toggle` — needs JS + persistence; usually not worth it on a login page

---

## Round 3 — Design direction

**Q1 · Direction** — offer 3 concrete directions plus the invitation to describe their own.
Use `preview` on the options with small ASCII layout sketches; that is what previews are for.
Examples: `Corporate / clean centered card`, `Split screen with brand imagery`,
`Full-bleed background with glass card`, `Minimal / typographic`.
Explicitly say: "or describe your own direction under Other".

**Q2 · Colors / corporate design**
- `Derive from a logo` — ask for the file, sample the palette from it
- `Given hex values` — primary, plus optional accent/surface
- `Reuse an existing theme's tokens`
- `Propose a palette` — then present it with contrast ratios

**Q3 · Typography**
- `System font stack (Recommended)` — zero load, zero licensing, zero GDPR exposure
- `Self-hosted webfont` — ask for the family and confirm the license allows self-hosting
- `Corporate font provided as files`

**Q4 · Target devices / breakpoints**
- `Mobile-first, phone + desktop (Recommended)`
- `Desktop-primary` — internal tools
- `Kiosk / tablet` — large touch targets, no hover reliance
- Ask for specific breakpoints or a minimum supported width if they have a standard.

---

## Round 4 — Technical strategy and process

**Q1 · Parent theme strategy** — explain, do not just list (details in `references/theme-properties.md`):
- `parent=base + own template.ftl (Recommended for a distinct design)` — inherits all page logic and
  message bundles, zero PatternFly CSS. Full visual control, upgrade-safe, one layout to maintain.
- `parent=keycloak.v2, override CSS only` — fastest, inherits dark mode and all 45 templates, but the
  result stays recognizably Keycloak and CSS overrides break on PatternFly upgrades.
- `Standalone full-HTML per page` — maximum per-page freedom, massive duplication. Only for 1–2 pages.
- `Keycloakify (React)` — only if the team already builds React and wants component-level control;
  it adds a build toolchain to a repo that currently has none.

Recommend from Round 1/3: distinct corporate design + more than ~3 templates → `base + template.ftl`.

**Q2 · Quality process depth**
- `Full: render check + Playwright flows + axe + responsive screenshots (Recommended)`
- `Medium: render check of every template + acceptance checklist` — no new dependencies
- `Light: acceptance checklist only`

**Q3 · CI integration** — offer only pipelines that plausibly exist (check `.github/workflows/`,
`.gitlab-ci.yml`, `Jenkinsfile`; otherwise ask which one they use):
- `Add a theme test job to the existing GitHub Actions workflow (Recommended if .github/workflows exists)`
- `Separate workflow file, runs on changes to themes/**`
- `No CI for now, local tests only`

**Q4 · Deployment wiring**
- `Dockerfile COPY + kc.sh build` — confirm it is already there; add it if not
- `Realm binding` — ask which places must be updated: Terraform (`login_theme`), realm-import JSON
  (`"loginTheme"`), or manual in the admin console. Update **all** that exist.
- `Docs` — README with token table + screenshots, and/or an admin activation guide.

---

## Closing the interview

Restate the brief as a table: theme name, version, types, template list, languages, direction,
tokens, parent strategy, device targets, QA depth, CI, deployment. Get an explicit yes,
then start Phase 2. If the user changes their mind later, update this brief in the theme README
rather than carrying it only in conversation.
