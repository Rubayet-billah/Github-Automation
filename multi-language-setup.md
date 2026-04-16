
# Multilingual Feature Replication Checklist

**Target:** Archive Market Research  
**Status:** In Progress

## 1. Core Setup

- [ ] Copy `i18n/`, `messages/`, and `middleware.js` from source
- [ ] Update `next.config.mjs`:
  - Wrap with `createNextIntlPlugin()`
  - Add `experimental.esmExternals: "loose"`
  - Suppress next-intl `import(t)` warning
- [ ] Verify `next-intl` compatibility with Next.js 14

## 2. App Router Structure

- [ ] Set up `[locale]` folder structure:
  ```bash
  app/[locale]/reports/[slug]/page.js
  app/[locale]/layout.js
  app/layout.js
  ```
- [ ] Root `layout.js` → Global layout
- [ ] `[locale]/layout.js` → Locale-aware layout

## 3. Configuration

- [ ] Create `SUPPORTED_LOCALES = ["en", "ja", "de"]` in central config
- [ ] Update `languages` mapping file with German entry

## 4. Key File Updates

- [ ] `generateAlternates.js` → Use `availableLocales` instead of `hasJapanese`
- [ ] `generateReportFAQs.js` → Use translation keys (`t()`)
- [ ] `ReportDatasetJsonLd.jsx` → Accept `t` prop and use `ReportJsonLd` keys
- [ ] `LanguagePrompt.jsx` → Make dynamic using `languages` array
- [ ] `app/[locale]/reports/[slug]/page.js` → Filter `availableLocales` and update metadata

## 5. API & SEO Changes

- [ ] Update API calls (`fetchReportData`, `fetchSeoData`, `checkLocale`) for multi-language support
- [ ] Ensure backend returns correct `translated_locales` for German
- [ ] Update sitemap generation to support all locales
- [ ] Verify `hreflang` tags and canonical URLs

## 6. Translation Files (`messages/de.json`)

- [ ] Add `ReportFAQ` and `ReportJsonLd` sections
- [ ] Add missing TOC keys:
  - `ansoffMatrixAnalysis`, `supplyChainAnalysis`, `regulatoryLandscape`, `tamSamSomFramework`, `analystNote`, `listOfPotentialCustomers`
- [ ] Fix `ourMisson` → `ourMission`

## 7. Testing

- [ ] German language works on report pages
- [ ] Language Prompt triggers for `DE` country code
- [ ] FAQ Schema + JSON-LD render correctly in German
- [ ] `hreflang` / alternates are valid
- [ ] No `next-intl` build warnings
- [ ] Japanese and English remain functional

## 8. Future-Proofing

- [ ] Remove all hard-coded language checks (`isJp`, `locale === "ja"`)
- [ ] Use translation keys (`t()`) everywhere
- [ ] Document process for adding new languages

---

**Quick Add New Language:**
1. Add to `SUPPORTED_LOCALES`
2. Add to `languages` array
3. Create `messages/[new].json`
4. Add `ReportFAQ` & `ReportJsonLd`
5. Test

---

**Last Updated:** April 16, 2026