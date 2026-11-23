---
name: keycloak-theme
description: Design and build Keycloak themes end-to-end — a structured requirements interview, then HTML/CSS/JS design drafts, then production FreeMarker templates, tests and docs. Use when the user wants to create, redesign, extend, port or review a Keycloak theme, a custom login/sign-in page, an email theme, FTL templates, theme.properties, or asks to brand Keycloak. Triggers on "Keycloak theme", "custom login page", "login theme", "FTL", "theme.properties", "Keycloakify", and German equivalents such as "Keycloak-Theme", "Anmeldeseite gestalten", "Login-Design", "Theme bauen".
---

# Keycloak Theme Builder

Build Keycloak themes in two stages: **design first as plain HTML/CSS/JS, port to FreeMarker only after the design is approved.** Designing directly in `.ftl` wastes review cycles — the user cannot judge a design that only renders inside a running Keycloak.

## Baseline standards (apply unless the user explicitly waives them)

1. **WCAG 2.2 AA** — labels, focus-visible, `aria-invalid` + `aria-live` on errors, contrast ≥ 4.5:1, touch targets ≥ 44px, `prefers-reduced-motion` honored for any animation.
2. **No third-party CDNs.** Self-host fonts (woff2) and every asset. Google Fonts from the CDN is a GDPR problem for EU deployments.
3. **Never hardcode user-profile fields** in `register.ftl` / `login-update-profile.ftl` / `idp-review-user-profile.ftl` — use the dynamic user-profile macros, or declarative realm attributes silently stop working.
4. **Escaping**: Keycloak's FreeMarker templates are not auto-escaped. `?no_esc` only ever together with `kcSanitize()`, never on raw user input.
5. **Progressive enhancement**: forms must submit without JS. JS may enhance (password toggle, background animation), never gate the login.
6. **Static draft and theme stay in sync** — where a repo keeps a static design tree next to the theme (e.g. `demo/<theme>/` beside `themes/<theme>/`), every CSS/JS change lands in both in the same commit. Detect the convention in recon and follow it.
7. **Not done until rendered**: a template counts as delivered only after it has been rendered by a real Keycloak. FreeMarker errors surface at runtime, not at build time.

## Phase 0 — Recon (do this before asking anything)

The skill's base directory is given to you when the skill is invoked. Set `SKILL` to it once, so the
commands below work verbatim:

```bash
SKILL=~/.claude/skills/keycloak-theme        # or the base directory reported at invocation
bash "$SKILL/scripts/kc-version.sh"          # detected + latest released Keycloak version
```

Never open the interview cold. Inspect the repo, then report the findings in 5–10 lines:

- `themes/*/` — existing themes, their types and parent (`theme.properties`)
- `demo/*/` — existing static design drafts (this repo's stage-1 convention)
- `compose.yaml` / `docker-compose.yml` — is there a dev instance with the theme dir mounted and theme caching disabled?
- `Dockerfile` — is `COPY themes/` present, and which base image tag is pinned?
- realm binding — `login_theme` / `account_theme` / `email_theme` in `*.tf`, or `"loginTheme"` in a realm-import JSON
- CI — `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`
- Flag drift, e.g. a compose image tag that differs from the Dockerfile tag.

**Only ask what recon did not answer.** If exactly one theme exists and the user said "update the login page", do not ask "new or existing".

## Phase 1 — Interview

Run the question catalog in `references/interview.md`. It is grouped into four rounds of at most four questions, sized for `AskUserQuestion`. Rules:

- Pre-fill every option from recon; mark the recommended option first and label it `(Recommended)`.
- The "Other" escape hatch is automatic — that is the free-text lane for users who want something unconventional. For the design-direction question, explicitly invite it.
- Skip whole rounds that recon or the user's prompt already settled.
- For the **parent-theme strategy**, do not just list options — explain the trade-off in the option descriptions and recommend based on the answers so far (`references/theme-properties.md` has the decision guide).
- Restate the full brief in a short table and get a yes before Phase 2.

## Phase 2 — Design drafts (HTML/CSS/JS, no FreeMarker)

Produce **the login screen only**, as 1 or 3 variants (per interview answer), into `demo/<theme>/login/`:

- `login.html`, `style.css`, `script.js`, plus assets. For 3 variants use `demo/<theme>-a|b|c/login/`.
- All design decisions as CSS custom properties in `:root` — colors, spacing, radii, font stacks, shadows. This token block later becomes the theme's single source of truth and the documented design system.
- Realistic content, all interactive states (hover, focus-visible, disabled, error), and a rendered error message — a login design that has never shown "Invalid username or password" is not finished.
- Mobile-first, verified at the agreed breakpoints.

Then publish a **comparison Artifact**: one page showing the variants side by side (iframes or embedded screenshots), each with its token palette and a short rationale. Load the `artifact-design` skill before writing that page. Hand the user the link and ask for a decision or change requests. Iterate here — this stage is cheap, Phase 4 is not.

## Phase 3 — Extend the approved design to all selected templates

Still plain HTML. Build one static page per selected template (`references/templates.md` lists them, grouped, with the elements each one needs). Reuse the token block; do not fork the CSS per page. This is where missing states surface — OTP, page-expired, terms, IdP linking.

## Phase 4 — Port to the theme structure

```bash
bash "$SKILL/scripts/fetch-base-templates.sh <version> login <outdir>"
```

Always diff against the **official base templates of the pinned version** before writing an FTL file — that is the contract for required fields, hidden inputs, message keys and conditionals. Do not write FreeMarker from memory.

Then, per `references/freemarker.md` and `references/theme-properties.md`:

1. `themes/<theme>/<type>/theme.properties` — parent, styles, scripts, locales, and the `properties.kc*` class names your templates reference.
2. A single `template.ftl` with the layout macro; every page renders through it. Do **not** produce standalone full-HTML pages per template — that is how a theme ends up with 20 duplicated `<head>` blocks.
3. Page templates, each mapping the static markup onto the base contract.
4. `messages/messages_<locale>.properties` for every configured locale; no user-visible string stays hardcoded in a template.
5. Copy CSS/JS/images to `resources/`, keeping `demo/` in sync (`scripts/check-sync.sh`).

## Phase 5 — Quality gate

Follow `references/quality.md`: render check of every template against the dev instance, Playwright flow tests, axe-core accessibility scan, responsive screenshots, and the per-template acceptance criteria. Report results honestly — list what failed and what was not covered.

## Phase 6 — Wiring, CI and docs

- Dockerfile: ensure `COPY themes/ /opt/keycloak/themes/` sits before `kc.sh build`.
- Realm binding: set the theme in *every* place the repo configures realms (Terraform *and* realm-import JSON — missing one causes confusing drift).
- CI: add the theme test job if the user opted in (`assets/ci-github-actions.yml` as a starting point).
- Docs: `themes/<theme>/README.md` with the token table, a screenshot per template, the local dev command, activation instructions, and the list of covered/uncovered templates.

## Reference index

| File | Load when |
|---|---|
| `references/interview.md` | Phase 1 — the full question catalog |
| `references/templates.md` | Choosing template scope, and per-template element checklists |
| `references/freemarker.md` | Phase 4 — FTL variable/macro contract, verified against 26.7.x |
| `references/theme-properties.md` | Parent strategy, theme.properties keys, i18n, deployment |
| `references/quality.md` | Phase 5 — tests, acceptance criteria, CI |
| `references/pitfalls.md` | Read before Phase 4, and when something renders wrong |
| `assets/` | `template.ftl` skeleton, theme.properties, message bundles, Playwright + CI scaffolds |
