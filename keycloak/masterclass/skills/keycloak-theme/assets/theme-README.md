# <Theme name>

<One line: what this theme is and which realms use it.>

## Brief

| | |
|---|---|
| Keycloak version | `26.x.y` (matches the Dockerfile pin) |
| Theme types | login, email |
| Parent | `base` |
| Languages | de, en |
| Devices | mobile-first, 320px – desktop |
| Accessibility target | WCAG 2.2 AA |

## Design tokens

Single source of truth: the `:root` block in `login/resources/css/styles.css`.

| Token | Value | Used for |
|---|---|---|
| `--color-brand` | `#......` | primary actions, focus ring |
| `--color-surface` | `#......` | card background |
| `--color-text` | `#......` | body text (contrast x.x:1) |
| `--font-sans` | `...` | all text |
| `--radius-card` | `..px` | card, inputs, buttons |

## Covered templates

| Template | Status |
|---|---|
| `login.ftl` | ✅ |
| `login-reset-password.ftl` | ✅ |
| ... | |
| everything else | falls back to `<parent>` — verified as acceptable |

## Local development

```bash
docker compose up -d      # theme mounted, theme caching disabled
open http://localhost:8080/realms/<realm>/account
```

Edit files under `themes/<name>/` — a browser reload is enough, no restart.
Mirror every CSS/JS change into `demo/<name>/` (static design reference) in the same commit.

## Tests

```bash
npx playwright test              # flows, i18n, responsive, no-JS
npx playwright test a11y.spec.ts # axe-core, WCAG 2.2 AA
bash scripts/check-sync.sh       # demo/ <-> themes/ drift
```

## Activation

The theme must be selected per realm, in every place the repo configures realms:

- Terraform: `login_theme = "<name>"` in `config/realm_<realm>.tf`
- Realm import: `"loginTheme": "<name>"` in `local/realm-<realm>.json`
- Admin console: Realm settings → Themes → Login theme

## Upgrade checklist (on a Keycloak version bump)

1. `bash scripts/fetch-base-templates.sh <new-version> login /tmp/new`
2. Diff against the previous version's base templates.
3. Re-check every overridden template for new fields, renamed message keys, changed conditionals.
4. Run the full test suite against the new version before merging.
