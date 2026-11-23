# Template catalog (verified against Keycloak 26.7.3)

The base login theme ships **46 `.ftl` files**: 7 layout/partials and 39 renderable pages.
Verify the list for the target version — pages come and go between releases:

```bash
bash "$SKILL/scripts/fetch-base-templates.sh 26.7.3 login /tmp/kcbase --list-only"
```

Never promise "all templates" unless you actually deliver all of them. State the covered set
explicitly; uncovered pages silently fall through to the parent theme, which looks broken next to
a custom design. **Any page not overridden must still be visually acceptable** — that is the main
argument for `parent=keycloak.v2` when scope is narrow.

## Partials / layout (not pages)

| File | Role |
|---|---|
| `template.ftl` | The `registrationLayout` macro every page wraps. Sections: `header`, `show-username`, `form`, `socialProviders`, `info` |
| `footer.ftl` | Footer macro rendered by the layout |
| `theme-resources.ftl` | Renders favicons/styles/scripts declared in `theme.properties` |
| `user-profile-commons.ftl` | Dynamic user-profile field rendering — **required** by register/update-profile |
| `password-commons.ftl` | Password + confirm-password field pair with validation wiring |
| `register-commons.ftl` | reCAPTCHA / terms fragments for registration |
| `passkeys.ftl` | Conditional-UI data block for passkey autofill |

## Tier: Core *(always)*

| Page | Elements to design |
|---|---|
| `login.ftl` | Logo, username/email field, password + visibility toggle, remember-me, forgot-password link, submit, registration link, social providers, language switcher, error alert, footer |
| `login-username.ftl` | Identity-first step: username only, "next" button — no password field |
| `login-password.ftl` | Second step: attempted-username display, password, "try another way" link |
| `error.ftl` | Error text, back-to-application link |
| `info.ftl` | Neutral message + optional action link; used by many flows |
| `login-page-expired.ftl` | "Restart login" vs. "continue" — two distinct actions, do not style as one |

## Tier: Password lifecycle

| Page | Elements |
|---|---|
| `login-reset-password.ftl` | Username/email input, submit, back-to-login |
| `login-update-password.ftl` | New + confirm password, policy hints, logout-other-sessions checkbox |
| `update-email.ftl` | New email input, cancel when app-initiated |
| `login-verify-email.ftl` | Instruction text, resend link, change-email link |

## Tier: Registration & profile

| Page | Elements |
|---|---|
| `register.ftl` | **Dynamic** user-profile fields, password pair, terms checkbox, reCAPTCHA slot, back-to-login |
| `login-update-profile.ftl` | Dynamic profile fields for required actions |
| `terms.ftl` | Long-form text block (the one place HTML in messages is expected), accept/decline |
| `idp-review-user-profile.ftl` | Pre-filled profile after first federated login |

## Tier: MFA

| Page | Elements |
|---|---|
| `login-otp.ftl` | OTP input (numeric inputmode, `autocomplete="one-time-code"`), credential selector when several OTPs exist |
| `login-config-totp.ftl` | QR code, manual secret, device name, verification input — the most layout-hungry page |
| `webauthn-authenticate.ftl` | Authenticator list, "authenticate" button, JS-driven |
| `webauthn-register.ftl` | Registration prompt + label input |
| `webauthn-error.ftl` | Error + retry |
| `login-passkeys-conditional-authenticate.ftl` | Passkey autofill variant of the login form |
| `login-recovery-authn-code-config.ftl` | Code grid, print/download/copy actions, confirmation checkbox |
| `login-recovery-authn-code-input.ftl` | "Enter code number N" input |
| `login-reset-otp.ftl` | OTP credential selection during reset |
| `select-authenticator.ftl` | Card list of available methods with icon + help text |
| `delete-credential.ftl` | Confirm removal of a credential |
| `login-x509-info.ftl` | Certificate subject display, continue/cancel |

## Tier: Federation & organizations

| Page | Elements |
|---|---|
| `login-idp-link-confirm.ftl` | "Account exists" — link vs. review options |
| `login-idp-link-confirm-override.ftl` | Override an existing link |
| `login-idp-link-email.ftl` | "We sent you a link" + resend |
| `link-idp-action.ftl` | App-initiated IdP link confirmation |
| `select-organization.ftl` | Organization picker (26.x organizations feature) |

## Tier: Session & consent

| Page | Elements |
|---|---|
| `logout-confirm.ftl` | Confirm logout, back-to-application |
| `frontchannel-logout.ftl` | Progress state + iframes; keep it minimal |
| `login-oauth-grant.ftl` | Scope list with descriptions, accept/decline |
| `login-oauth2-device-verify-user-code.ftl` | Device code input, large targets (often used on TVs/kiosks) |
| `code.ftl` | Displays an authorization code for copy-out |
| `delete-account-confirm.ftl` | Destructive confirmation — needs clear visual weight |
| `saml-post-form.ftl` | Auto-submitting form; only a "please wait" state is visible |
| `cli_splash.ftl` | CLI login splash; rarely worth styling |

## Email theme (26.7.3: 19 HTML + 18 text templates)

Every email needs **both** an HTML and a text variant; the text one is not optional.
Rules that differ from the login theme: table-based layout, inline CSS only (no external
stylesheet, no CSS Grid/Flex in older clients), max ~600px width, images by absolute URL or
skipped entirely, and subjects live in `messages/messages_<locale>.properties`.

Most commonly branded: `password-reset`, `email-verification`, `email-verification-with-code`,
`executeActions`, `org-invite`, `identity-provider-link`, `email-update-confirmation`.
The `event-*` templates are security notifications — plain and unmissable beats pretty.

## Account / Admin console

Both are React (v3). A custom theme can supply CSS, a logo and favicon via `theme.properties`;
it cannot restructure pages with FreeMarker. If the user wants real changes there, the honest
options are Keycloakify or living with the stock console — say so instead of over-promising.
