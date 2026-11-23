# FreeMarker contract (verified against Keycloak 26.7.3 base templates)

Always diff your page against the official base template of the pinned version before shipping it.
This file covers the stable parts; the base template is the authority.

## Layout macro

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password')
                            displayInfo=realm.password && realm.registrationAllowed; section>
    <#if section = "header">        ... page title ...
    <#elseif section = "form">      ... the form ...
    <#elseif section = "socialProviders"> ... IdP buttons ...
    <#elseif section = "info">      ... secondary links ...
    </#if>
</@layout.registrationLayout>
```

Macro parameters: `bodyClass`, `displayInfo`, `displayMessage`, `displayRequiredFields`.
Sections: `header`, `show-username`, `form`, `socialProviders`, `info`.
The layout renders `<body data-page-id="login-${pageId}">` — a stable hook for CSS and UI tests.

## Objects available in login templates

| Expression | Meaning |
|---|---|
| `url.loginAction` | **The form target. Every form posts here.** |
| `url.resourcesPath` / `url.resourcesCommonPath` | This theme's / the common theme's `resources` dir |
| `url.loginResetCredentialsUrl` | Forgot-password link |
| `url.registrationUrl` | Registration link |
| `url.loginUrl` | Back to the login form |
| `url.ssoLoginInOtherTabsUrl` | Used by the session poller in the base layout |
| `realm.name`, `realm.displayName`, `realm.displayNameHtml` | Realm identity |
| `realm.password`, `realm.rememberMe`, `realm.resetPasswordAllowed`, `realm.registrationAllowed`, `realm.loginWithEmailAllowed`, `realm.registrationEmailAsUsername`, `realm.internationalizationEnabled` | Feature switches — gate markup on these, never assume |
| `login.username`, `login.rememberMe` | Sticky values after a failed attempt |
| `message.type` (`error`/`warning`/`success`/`info`), `message.summary` | The global alert |
| `messagesPerField.existsError('a','b')`, `.getFirstError('a','b')`, `.get('field')` | Field-level errors |
| `auth.attemptedUsername`, `auth.showUsername()`, `auth.showResetCredentials()`, `auth.showTryAnotherWayLink()`, `auth.selectedCredential` | Multi-step auth state |
| `social.providers` → `p.alias`, `p.displayName`, `p.loginUrl`, `p.iconClasses` | IdP buttons |
| `client.baseUrl`, `client.name`, `client.attributes` | Back-to-application link |
| `locale.current`, `locale.supported` (`l.url`, `l.label`), `locale.rtl`, `lang` | Language switcher |
| `org` | Organization context (26.x), guard with `org??` |
| `properties.kcXyz` | Class names from `theme.properties` |
| `pageId` | Page identifier, also emitted as `data-page-id` |
| `msg("key")`, `msg("key", arg)`, `advancedMsg(...)` | Message bundle lookup |
| `kcSanitize(html)` | Whitelist sanitizer — the only safe partner for `?no_esc` |

Guard anything optional with `??` / `!` — a missing variable is a 500, not a blank.

## Required plumbing you must not drop

```ftl
<form action="${url.loginAction}" method="post">
  <input type="hidden" id="id-hidden-input" name="credentialId"
         <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
  ...
</form>
```

- `credentialId` — MFA credential selection breaks without it.
- Field names are fixed: `username`, `password`, `rememberMe`, `login`, `totp`, `password-new`,
  `password-confirm`. Renaming them breaks the server-side flow.
- `autocomplete`: `username`, `current-password`, `new-password`, `one-time-code`; for passkey
  autofill use `${(enableWebAuthnConditionalUI?has_content)?then('username webauthn','username')}`.
- Errors: `aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"` plus a
  `<span id="input-error" aria-live="polite">` containing
  `${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}`.
- `login.ftl` deliberately reports username and password errors **together** — do not "improve" this
  into separate messages; it is a user-enumeration defence.

## Escaping rules

- Default output is **not** escaped. `${message.summary}` is fine only because Keycloak's own
  messages are trusted; anything reaching a template from user input must not be `?no_esc`'d.
- Use `${kcSanitize(x)?no_esc}` where HTML is intended (terms text, `displayNameHtml`, backend messages).
- In `<script>` blocks use `?c` / `<#outputformat "JavaScript">`, as the base layout does. Never
  interpolate a raw value into JS.

## Dynamic user profile (KC 24+)

`register.ftl`, `login-update-profile.ftl` and `idp-review-user-profile.ftl` must render fields
through `user-profile-commons.ftl`:

```ftl
<#import "user-profile-commons.ftl" as userProfileCommons>
<@userProfileCommons.userProfileFormFields; callback, attribute, group>
    ...custom markup per field, using attribute.name / .displayName / .required / .annotations...
</@userProfileCommons.userProfileFormFields>
```

Hardcoding `firstName`/`lastName`/`email` inputs makes realm-level user-profile configuration
(extra attributes, validators, conditional fields) silently ineffective. This is the single most
common defect in custom Keycloak themes.

## Base JS you inherit (and lose if you write your own template.ftl)

`authChecker.js` (session polling, auth-session check), `passwordVisibility.js`,
`menu-button-links.js` (accessible locale dropdown), plus the `data-once-link` click guard inlined
in the layout. If you author your own `template.ftl` with `parent=base`, re-include the ones you
need — they live under `${url.resourcesPath}/js/` in the base theme and are inherited via the
resource lookup chain.

## Messages

`msg("key")` resolves against `messages/messages_<locale>.properties` in the theme, then the parent
chain, then Keycloak's own bundle. Override only the keys you change; copying the whole English
bundle guarantees drift on the next upgrade. Bundles are read charset-aware (`PropertiesUtil.
readCharsetAware` → Java 9+ `PropertyResourceBundle`): **write them as UTF-8**; ISO-8859-1 is only the
fallback when the UTF-8 decode fails. A file with a stray Latin-1 umlaut silently flips the whole
bundle to Latin-1, so keep every bundle consistently UTF-8.
