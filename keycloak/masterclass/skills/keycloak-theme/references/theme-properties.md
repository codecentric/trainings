# Parent strategy, theme.properties, i18n, deployment

## Directory layout

```
themes/<name>/
  login/
    theme.properties
    template.ftl                 # only when you own the layout
    login.ftl ...
    messages/messages_de.properties
    resources/css/styles.css
    resources/js/script.js
    resources/img/logo.svg
  email/
    theme.properties
    html/*.ftl  text/*.ftl  messages/*.properties
```

Everything not present in your theme is resolved up the parent chain, per file. Themes inherit at
**file granularity**, not directory granularity.

## Choosing a parent

| Strategy | Inherits | Costs | Use when |
|---|---|---|---|
| `parent=base` + own `template.ftl` | All page logic, message bundles, base JS; **no CSS** | You own the layout, the locale switcher markup and re-including base JS | A distinct corporate design over more than ~3 pages. **Default recommendation.** |
| `parent=keycloak.v2` | PatternFly v5 CSS, dark mode, all 46 templates, complete look | Overrides fight PatternFly specificity and break on its upgrades; the result still reads as Keycloak | Light branding: logo, colors, background — days not weeks |
| `parent=keycloak` | Legacy PatternFly v3/v4 look | Older stack, being phased out | Only to match an existing legacy theme |
| Standalone full-HTML per page | Nothing | Duplication grows linearly with pages | 1–2 pages, or a deliberately unusual single screen |
| Keycloakify (React) | Component-level control, Storybook | A whole JS build chain and a per-Keycloak-version compatibility burden | The team already ships React and wants to reuse components |

`parent=base` does **not** mean "from scratch": every `.ftl` you do not override still comes from
base and renders correctly, just unstyled. So with `parent=base` you must either override every page
you expose, or accept unstyled fallbacks — which is exactly the trade-off to explain in the interview.

## theme.properties keys that matter

```properties
parent=base
import=common/keycloak            # pull in shared resources (fonts, vendor css)
styles=css/styles.css             # space-separated, resolved under resources/
stylesCommon=                     # resolved under the imported common theme
scripts=js/script.js              # space-separated
locales=de,en                     # comma-separated; needs realm i18n enabled to show up
meta=viewport==width=device-width,initial-scale=1   # key==value, space-separated pairs
darkMode=true                     # v2 mechanism; with your own CSS use prefers-color-scheme
kcHtmlClass=...                   # any kcXxx key is readable as ${properties.kcXxx!}
```

- `abstract=true` hides a theme from the realm dropdown (useful for a shared base theme).
- The viewport meta tag comes from `meta=`, **not** from base's `template.ftl` — omit it and every
  page is desktop-scaled on phones. With your own `template.ftl`, write the tag directly instead.
- Favicon: the base layout renders `themeResources.favicons` when configured, otherwise falls back to
  `${url.resourcesPath}/img/favicon.ico`. The reliable route is to place `img/favicon.ico` (plus an
  SVG icon link in your own `template.ftl`) rather than relying on the fallback.
- Custom `kcXxx` keys are free-form: define them once and reference them as `${properties.kcXxx!}`
  so class names stay configurable. With a fully custom theme it is usually simpler to write plain
  class names into your templates — just be consistent, and do not half-migrate.

## Internationalization

1. `locales=de,en` in `theme.properties`.
2. `messages/messages_de.properties` per locale, UTF-8, containing **only overridden keys**.
3. Realm → Localization → Internationalization must be **on**, otherwise `locale.supported` is empty
   and the switcher never renders. Set the realm default locale too.
4. Emails need their own bundle under `email/messages/`, including the `*Subject` keys.
5. The base layout's locale dropdown depends on `menu-button-links.js` for keyboard accessibility —
   if you write your own switcher, keep it a real `<ul role="menu">` with arrow-key support, or use
   a plain `<select>` with a submit-on-change fallback.

## Dev loop

Run Keycloak with the theme directory mounted and caching off:

```yaml
environment:
  KC_SPI_THEME_STATIC_MAX_AGE: "-1"
  KC_SPI_THEME_CACHE_THEMES: "false"
  KC_SPI_THEME_CACHE_TEMPLATES: "false"
volumes:
  - ./themes:/opt/keycloak/themes
```

CLI equivalent: `--spi-theme--static-max-age=-1 --spi-theme--cache-themes=false
--spi-theme--cache-templates=false` (note the double dash inside the SPI option name).
If stale CSS persists, delete `data/tmp/kc-gzip-cache` in the container.
**Never ship these settings to production** — they disable caching for every request.

## Deployment

- **Directory** (this repo): `COPY themes/ /opt/keycloak/themes/` *before* `RUN kc.sh build`.
- **JAR**: `META-INF/keycloak-themes.json` + resources, dropped into `providers/`. Use it when the
  theme is a separately versioned artifact shared across deployments.
- **Activation** is per realm and per type: `login_theme`, `account_theme`, `email_theme`,
  `admin_theme`. Update every place the repo defines realms — Terraform *and* realm-import JSON —
  or environments will drift apart. A theme that exists but is not selected produces no error at all,
  which makes this failure mode easy to miss.
