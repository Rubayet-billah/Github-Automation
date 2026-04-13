# Multilingual Feature Replication Checklist 

**Target Publisher:** Archive Market Research  
**Source Publisher:** Previous Project  
**Status:** In Progress

## Objective
Replicate the full multilingual feature (English, Japanese, German + scalable for future languages) from the existing publisher to the new one with minimal issues and good developer experience.

---

## 1. Core Configuration Setup

- [ ] Copy the following folders/files from source to root:
  - `i18n/` folder (or `lib/i18n/`)
  - `messages/` folder (`en.json`, `ja.json`, `de.json`)
  - `middleware.js` (or `middleware.ts`)
- [ ] Update `next.config.mjs`:
  - Wrap config with `createNextIntlPlugin()`
  - Add `experimental: { esmExternals: "loose" }`
  - Add webpack `ignoreWarnings` for next-intl `import(t)` warning
- [ ] Verify `next-intl` is installed and compatible with Next.js 14

---

## 2. App Router Structure

- [ ] Ensure folder structure follows this pattern:
  ```bash
  app/
  ├── [locale]/
  │   ├── reports/
  │   │   └── [slug]/
  │   │       └── page.js
  │   ├── layout.js
  │   ├── not-found.js
  │   └── page.js
  ├── layout.js
  └── globals.css
  ```
- [ ] Root `layout.js` → Global layout
- [ ] `[locale]/layout.js` → Locale-specific layout with `NextIntlClientProvider`

---

## 3. Central Configuration

- [ ] Create/Update `lib/config/locales.js` (or `constants/locales.js`):
  ```js
  export const SUPPORTED_LOCALES = ["en", "ja", "de"];
  ```
- [ ] Ensure `languages` mapping file exists and includes:
  ```js
  { code: "de", countryCode: "DE", label: "Deutsch" }
  ```

---

## 4. Key File Updates

### Must Update:

- [ ] `utils/generateAlternates.js` → Replace `hasJapanese` with `availableLocales`
- [ ] `utils/generateReportFAQs.js` → Use translation keys (`t('ReportFAQ.q1')`)
- [ ] `components/report/ReportDatasetJsonLd.jsx` → Accept `t` prop and use `ReportJsonLd` keys
- [ ] `components/common/LanguagePrompt.jsx` → Make fully dynamic using `languages` array
- [ ] `app/[locale]/reports/[slug]/page.js` → Use `SUPPORTED_LOCALES` + `availableLocales` filtering

### Report Page Specific:

- [ ] Import `SUPPORTED_LOCALES`
- [ ] Filter `availableLocales` before passing to `<Header />` and `generateAlternates`
- [ ] Update both `generateMetadata` and page component

---

## 5. Translation Files (`messages/de.json`)

- [ ] Add missing sections:
  - `ReportFAQ` (full)
  - `ReportJsonLd` (full)
- [ ] Add missing keys in `TOC`:
  - `ansoffMatrixAnalysis`
  - `supplyChainAnalysis`
  - `regulatoryLandscape`
  - `tamSamSomFramework`
  - `analystNote`
  - `listOfPotentialCustomers`
- [ ] Fix spelling: `ourMisson` → `ourMission` (and related keys)
- [ ] Review long texts for natural German tone

---

## 6. Testing & Validation

- [ ] German language loads correctly on report pages
- [ ] Language Prompt appears correctly for country code `DE`
- [ ] FAQ Schema.org and JSON-LD render properly in German
- [ ] `hreflang` / alternate links are generated correctly
- [ ] Slug auto-correction / redirection works
- [ ] No build or runtime warnings related to `next-intl`
- [ ] Japanese functionality remains unchanged
- [ ] Test on both report pages and non-report pages

---

## 7. Future-Proofing & Documentation

- [ ] Document the process of adding a new language (e.g., Chinese)
- [ ] Keep all hard-coded language checks (`isJp`, `locale === "ja"`) removed
- [ ] All new components must use translation keys via `t()`
- [ ] Save this checklist as `MULTILINGUAL_REPLICATION_CHECKLIST.md`

---

**Quick Reference: Adding a New Language**

1. Add code to `SUPPORTED_LOCALES`
2. Add entry in `languages` array with `countryCode`
3. Create new file `messages/[new-locale].json`
4. Add translations for `ReportFAQ` and `ReportJsonLd`
5. Test Language Prompt and report pages

---
