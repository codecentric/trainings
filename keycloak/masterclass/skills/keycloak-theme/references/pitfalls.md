# Pitfalls

Ordered by how often they bite.

1. **Hardcoded profile fields.** `register.ftl` / `login-update-profile.ftl` with fixed
   firstName/lastName/email inputs silently disable declarative user-profile config. Use
   `user-profile-commons.ftl`.
2. **Missing `credentialId` hidden input.** Login works, MFA credential selection does not.
3. **Missing viewport meta.** Comes from `meta=viewport==...` in `theme.properties` or from your own
   `template.ftl`. Forget it and the design is perfect everywhere except phones.
4. **`?no_esc` without `kcSanitize`.** Injection risk. Conversely, escaping the terms text turns it
   into visible HTML source.
5. **Stale cache during development.** Symptoms: edits have no effect. Check
   `KC_SPI_THEME_CACHE_THEMES/CACHE_TEMPLATES=false` and `STATIC_MAX_AGE=-1`; delete
   `data/tmp/kc-gzip-cache`. Browser hard-reload too — `static-max-age` only helps for new responses.
6. **Theme not selected.** The directory exists, the realm still uses `keycloak`. No error is logged.
   Check `login_theme` in Terraform *and* `"loginTheme"` in the realm-import JSON.
7. **Baked into the image but not rebuilt.** With `--optimized`, `COPY themes/` must precede
   `RUN kc.sh build`, and the image must actually be rebuilt. A mounted dev theme masks this.
8. **Version drift.** `compose.yaml` and `Dockerfile` pinning different Keycloak tags means you test
   against a different template contract than you ship. Check this in recon.
9. **Duplicated page shells.** Two templates with copy-pasted `<head>` blocks become twenty. Introduce
   `template.ftl` at the second page, not the tenth.
10. **Missing pages after a scope decision.** Unoverridden pages fall back to the parent and look
    foreign. Either override them or pick a parent whose look is close enough.
11. **CDN fonts/scripts.** GDPR exposure and an availability dependency on the login path — the one
    page that must work when everything else is down. Self-host.
12. **Message keys leaking.** `??key??` or raw keys in the UI mean a missing bundle entry. Assert
    against it in the UI tests.
13. **Locale switcher without realm i18n.** `locales=` alone shows nothing; the realm flag must be on.
14. **JS-gated submit.** `onsubmit="return false"` copied from the static demo into the FTL disables
    login entirely. The demo's fake handlers must not survive the port.
15. **Bundle encoding.** Write message bundles as UTF-8 consistently; one Latin-1 byte flips the whole
    file to the fallback charset and mangles every umlaut in it.
16. **Upgrade blindness.** On a Keycloak upgrade, diff `theme/base/<type>` between the old and new tag
    and re-check every overridden template for new fields and renamed keys.
17. **Account/admin promises.** They are React. Only CSS, logo and favicon are themeable — say so
    before, not after, the design is drawn.
18. **Big backgrounds.** A 4 MB hero image on the login page is a slow first impression on mobile.
    Budget ≤200 KB, use modern formats, and provide a solid-color fallback.
