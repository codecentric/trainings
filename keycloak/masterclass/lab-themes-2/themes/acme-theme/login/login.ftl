<#-- ============================================================
  ACME Corp - Custom Login Theme
  Keycloak FreeMarker Template - Fully from Scratch

  This template demonstrates full control over Keycloak's login UI:
    - Custom HTML structure (no base template macros)
    - Direct access to all Keycloak FTL context variables
    - External CSS & JS referenced via ${url.resourcesPath}
    - All Keycloak form variables & i18n messages handled manually

  Available FTL context variables (selection):
    realm         - realm config (name, displayName, rememberMe, ...)
    url           - URL bundle (loginAction, registrationUrl, ...)
    login         - form state (username, rememberMe)
    message       - current alert message (type, summary)
    auth          - authentication info (selectedCredential)
    registrationDisabled - truthy if registration is locked
    locale        - current locale string
============================================================ -->
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'en'}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${msg("loginTitle", (realm.displayName!'ACME Corp'))}</title>
    <link rel="stylesheet" href="${url.resourcesPath}/css/custom-login.css">
</head>
<body>

    <!-- ── Animated Background ─────────────────────────────────── -->
    <div class="bg-animation" aria-hidden="true">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
        <div class="orb orb-3"></div>
    </div>
    <canvas id="particle-canvas" aria-hidden="true"></canvas>

    <!-- ── Login Wrapper ───────────────────────────────────────── -->
    <div class="login-wrapper">
        <div class="login-card">

            <!-- Logo (inline SVG → enables CSS/JS animations) -->
            <div class="logo-container" aria-label="ACME Corporation">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 280 80" class="acme-logo" role="img" aria-label="ACME Corporation Logo">
                    <defs>
                        <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#6C63FF">
                                <animate attributeName="stop-color"
                                    values="#6C63FF;#00D4FF;#a855f7;#6C63FF"
                                    dur="6s" repeatCount="indefinite"/>
                            </stop>
                            <stop offset="100%" stop-color="#00D4FF">
                                <animate attributeName="stop-color"
                                    values="#00D4FF;#6C63FF;#00D4FF"
                                    dur="6s" repeatCount="indefinite"/>
                            </stop>
                        </linearGradient>
                        <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
                            <feGaussianBlur stdDeviation="1.5" result="blur"/>
                            <feComposite in="SourceGraphic" in2="blur" operator="over"/>
                        </filter>
                    </defs>
                    <!-- Animated hexagon shape -->
                    <polygon class="hex-anim"
                             points="35,6 62,6 75,28 62,50 35,50 22,28"
                             fill="none" stroke="url(#logoGrad)" stroke-width="2.5"
                             filter="url(#glow)"/>
                    <!-- "A" inside hexagon -->
                    <text x="48" y="35" text-anchor="middle"
                          fill="url(#logoGrad)" filter="url(#glow)"
                          font-size="22" font-weight="700"
                          font-family="system-ui, -apple-system, sans-serif">A</text>
                    <!-- Company name -->
                    <text x="92" y="38"
                          fill="url(#logoGrad)" filter="url(#glow)"
                          font-size="34" font-weight="800" letter-spacing="-1"
                          font-family="system-ui, -apple-system, sans-serif">ACME</text>
                    <!-- Tagline under the name -->
                    <text x="93" y="57"
                          fill="rgba(180,180,220,0.55)"
                          font-size="10" letter-spacing="5"
                          font-family="system-ui, -apple-system, sans-serif">CORPORATION</text>
                </svg>
            </div>

            <!-- Animated tagline (translated via messages/messages_*.properties) -->
            <p class="tagline" id="tagline">${msg("acme.tagline")}</p>

            <#if realm.name == "labrealm">
                <div class="alert alert-warning">
                    <span class="alert-icon">⚠</span>
                    <span>${msg("acme.demoWarning")}</span>
                </div>
            </#if>

            <!-- ── Alert / Error Messages ─────────────────────── -->
            <#if message??>
            <div class="alert alert-${message.type}" role="alert">
                <span class="alert-icon" aria-hidden="true"><#if message.type == 'error'>✕<#elseif message.type == 'warning'>⚠<#elseif message.type == 'success'>✓<#else>ℹ</#if></span>
                <span>${message.summary?no_esc}</span>
            </div>
            </#if>

            <!-- ── Login Form ──────────────────────────────────── -->
            <form id="kc-form-login" action="${url.loginAction}" method="post" novalidate>

                <!-- Keycloak requires this hidden field for credential selection -->
                <input type="hidden" id="id-hidden-input" name="credentialId"
                       <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

                <!-- Username ─────────────────────────────────── -->
                <div class="form-group">
                    <div class="input-wrapper">
                        <svg class="input-icon" xmlns="http://www.w3.org/2000/svg"
                             viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" aria-hidden="true">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                        <input type="text"
                               id="username"
                               name="username"
                               value="${(login.username!'')}"
                               autocomplete="username"
                               autofocus
                               placeholder=" "
                               aria-label="${msg('username')}"
                               required/>
                        <label for="username" class="floating-label">${msg("username")}</label>
                    </div>
                </div>

                <!-- Password ─────────────────────────────────── -->
                <div class="form-group">
                    <div class="input-wrapper">
                        <svg class="input-icon" xmlns="http://www.w3.org/2000/svg"
                             viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" aria-hidden="true">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                        <input type="password"
                               id="password"
                               name="password"
                               autocomplete="current-password"
                               placeholder=" "
                               aria-label="${msg('password')}"
                               required/>
                        <label for="password" class="floating-label">${msg("password")}</label>
                        <!-- Password visibility toggle (pure JS, no framework needed) -->
                        <button type="button" class="toggle-password"
                                onclick="togglePassword()"
                                aria-label="Toggle password visibility">
                            <svg id="eye-open" xmlns="http://www.w3.org/2000/svg"
                                 viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                            <svg id="eye-closed" xmlns="http://www.w3.org/2000/svg"
                                 viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="2" style="display:none">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                                <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                                <path d="m2.93 13.07A10.24 10.24 0 0 1 1 12S5 4 12 4"/>
                                <path d="M15.1 15.1a3 3 0 0 1-4.24-4.24"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Remember Me + Forgot Password ────────────── -->
                <div class="form-row">
                    <#if realm.rememberMe>
                    <label class="checkbox-label">
                        <input type="checkbox" id="rememberMe" name="rememberMe"
                               <#if (login.rememberMe!false)>checked</#if>>
                        <span class="checkbox-custom" aria-hidden="true"></span>
                        ${msg("rememberMe")}
                    </label>
                    <#else>
                    <span></span>
                    </#if>
                    <#if realm.resetPasswordAllowed>
                    <a href="${url.loginResetCredentialsUrl}" class="forgot-link">
                        ${msg("doForgotPassword")}
                    </a>
                    </#if>
                </div>

                <!-- Submit ───────────────────────────────────── -->
                <button type="submit" id="kc-login" class="submit-btn">
                    <span class="btn-text">${msg("doLogIn")}</span>
                    <span class="btn-arrow" aria-hidden="true">→</span>
                    <div class="btn-shimmer" aria-hidden="true"></div>
                </button>

                <!-- Register Link ────────────────────────────── -->
                <#if realm.registrationAllowed && !registrationDisabled??>
                <div class="register-link">
                    ${msg("noAccount")} <a href="${url.registrationUrl}">${msg("doRegister")}</a>
                </div>
                </#if>

            </form>
        </div>

        <!-- ── Language Switcher ───────────────────────────────── -->
        <#if realm.internationalizationEnabled && locale.supported?has_content>
        <nav class="locale-switcher" aria-label="Language switcher">
            <#list locale.supported as l>
            <a href="${l.url}"
               class="locale-link<#if l.languageTag == (locale.currentLanguageTag)!'_'> active</#if>"
               lang="${l.languageTag}">${l.label}</a>
            </#list>
        </nav>
        </#if>

        <!-- Footer -->
        <footer class="login-footer">
            <p>${msg("acme.copyright")}</p>
        </footer>
    </div>

    <script src="${url.resourcesPath}/js/custom-login.js"></script>
</body>
</html>
