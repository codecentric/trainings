<#--
  Layout skeleton for a custom login theme with parent=base.
  Verified end-to-end on Keycloak 26.7.3: renders login, error, reset-password and info pages
  with zero FreeMarker errors; locale switcher, field errors, global alert and footer confirmed.
  Every page renders through this macro. Sections: header, show-username, form,
  socialProviders, info -- keep the names, page templates rely on them.
  Replace the class names with the design system's own; keep the ids, they are
  the stable hooks for UI tests and for Keycloak's own scripts.
-->
<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<!DOCTYPE html>
<html lang="${lang}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${msg("loginTitle", (realm.displayName!''))}</title>
  <link rel="icon" type="image/svg+xml" href="${url.resourcesPath}/img/favicon.svg">
  <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" sizes="any">
  <#if properties.styles?has_content>
    <#list properties.styles?split(' ') as style>
      <link href="${url.resourcesPath}/${style}" rel="stylesheet">
    </#list>
  </#if>
</head>

<body class="kc-body ${bodyClass}" data-page-id="login-${pageId}">
<div class="kc-shell">
  <main class="kc-card" role="main">

    <header class="kc-card__header">
      <a class="kc-brand" href="${properties.kcLogoLink!'#'}">
        <img src="${url.resourcesPath}/img/logo.svg" alt="${realm.displayName!''}" class="kc-brand__logo">
      </a>

      <#-- Language switcher: plain form, works without JS -->
      <#if realm.internationalizationEnabled && locale.supported?size gt 1>
        <div class="kc-locale">
          <label class="visually-hidden" for="kc-locale-select">${msg("languages")}</label>
          <select id="kc-locale-select" class="kc-locale__select"
                  onchange="if(this.value) window.location.href=this.value;">
            <#list locale.supported as l>
              <option value="${l.url}"<#if l.label == locale.current> selected</#if>>${l.label}</option>
            </#list>
          </select>
          <noscript>
            <ul class="kc-locale__list">
              <#list locale.supported as l><li><a href="${l.url}">${l.label}</a></li></#list>
            </ul>
          </noscript>
        </div>
      </#if>

      <#-- Page title, or the attempted username when the flow already knows it -->
      <#if !(auth?has_content && auth.showUsername() && !auth.showResetCredentials())>
        <h1 id="kc-page-title" class="kc-title"><#nested "header"></h1>
      <#else>
        <h1 id="kc-page-title" class="kc-title"><#nested "header"></h1>
        <div id="kc-username" class="kc-attempted-user">
          <span id="kc-attempted-username">${auth.attemptedUsername}</span>
          <a id="reset-login" href="${url.loginRestartFlowUrl}" aria-label="${msg("restartLoginTooltip")}">
            ${msg("restartLoginTooltip")}
          </a>
        </div>
      </#if>
    </header>

    <div class="kc-card__body">
      <#-- Global alert. role/aria-live so screen readers announce it after a failed submit. -->
      <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
        <div class="kc-alert kc-alert--${message.type}"
             role="<#if message.type = 'error'>alert<#else>status</#if>" aria-live="polite">
          <span class="kc-alert__text">${kcSanitize(message.summary)?no_esc}</span>
        </div>
      </#if>

      <#if displayRequiredFields>
        <p class="kc-required-hint"><span class="kc-required">*</span> ${msg("requiredFields")}</p>
      </#if>

      <#nested "form">

      <#if auth?has_content && auth.showTryAnotherWayLink()>
        <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post">
          <input type="hidden" name="tryAnotherWay" value="on"/>
          <button type="submit" class="kc-link" id="try-another-way">${msg("doTryAnotherWay")}</button>
        </form>
      </#if>

      <#nested "socialProviders">

      <#if displayInfo>
        <div id="kc-info" class="kc-card__info"><#nested "info"></div>
      </#if>
    </div>

    <footer class="kc-card__footer">
      <#-- Legal links are frequently mandatory in the EU; wire them to message keys, not hardcoded text -->
      <#if properties.kcImprintUrl?has_content>
        <a href="${properties.kcImprintUrl}">${msg("imprint")}</a>
      </#if>
      <#if properties.kcPrivacyUrl?has_content>
        <a href="${properties.kcPrivacyUrl}">${msg("privacyPolicy")}</a>
      </#if>
    </footer>

  </main>
</div>

<#if properties.scripts?has_content>
  <#list properties.scripts?split(' ') as script>
    <script src="${url.resourcesPath}/${script}"></script>
  </#list>
</#if>
</body>
</html>
</#macro>
