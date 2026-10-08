*inform9 site content and style rules. Draft 1. Version 2026-10-08 15:43 ET. These rules govern the Astro site in `src/`. Tokens come from [brand/tokens.css](brand/tokens.css). Screens come from the [screen inventory](screen-inventory-2026-10-08-1254.md).*

# inform9 Site Content and Style Rules

## 1. The two rules

1. **No words in code.** Every visible word, link, image path, image description, and label comes from a Markdown content file. A `.astro` file or TypeScript file holds structure and logic only. Changing copy, a link, or a logo never needs a code change.
2. **One stylesheet.** The whole site and app use `src/styles/global.css`. No `.astro` file has a `<style>` block, a `style=` attribute, a CSS module, or a utility framework. New looks are added to `global.css` once and reused.

These two rules are checked by a script that fails the build (section 7), so they cannot drift.

## 2. Content files

All content is Markdown with front matter, loaded through Astro content collections. A schema for each collection (in `src/content/config.ts`) makes the build fail when a required field is missing.

```
src/content/
  site/
    global.md          brand name, logo and image paths with alt text, favicon, social image, support email, legal links
    nav.md             header navigation items and sign-in links
    footer.md          footer columns, links, and legal line
  pages/               public site pages, one file per page
    home.md  how-it-works.md  pricing.md  faq.md  security.md  support.md  privacy.md  terms.md
  screens/             one file per app screen or link screen
    signup.md  signin.md  w9-form.md  payees.md  ...  (list in section 5)
  ui/
    buttons.md         shared button labels
    statuses.md        status chip words for requests and shares
    errors.md          one message per API error code
    validation.md      one message per field rule
    notices.md         cookie notice, session ended, saved, copied, and other short notices
    confirmations.md   confirmation dialogs for destructive actions
```

Emails are not in this tree. Their text lives in `email/messages.json` and is read by the Worker, not by Astro.

### Page file (public site)

```yaml
---
id: pricing
title: <page title>
description: <meta description>
template: pricing          # home, prose, faq, pricing
hero:
  heading: ...
  intro: ...
  cta: { label: ..., href: ... }
  image: { src: ..., alt: ... }
sections:
  - type: steps            # steps, cards, faq, plans, text, cta
    heading: ...
    items: [ { heading: ..., text: ... } ]
---
Optional prose body in Markdown for `prose` pages such as privacy and terms.
```

### Screen file (app and link screens)

```yaml
---
id: signin
route: /signin
audience: public           # public, owner, payee, link, admin
title: ...
intro: ...
fields:
  - name: email
    label: ...
    help: ...
    placeholder: ...
    errors: { required: ..., invalid: ... }
actions:
  - key: submit
    label: ...
    kind: primary          # primary, secondary, quiet, danger
links:
  - { key: forgot, label: ..., href: /reset-password }
notices: [ cookie ]        # keys from ui/notices.md
states:
  loading: ...
  empty: ...
  success: ...
  errors: { invalid_credentials: ..., account_locked: ... }
---
Optional Markdown body for longer text.
```

Field names, action keys, and state keys are identifiers the code uses. Everything beside them is text for people.

### Images and links

- Logo, mark, favicon, and social image paths live in `site/global.md` with their alt text. A component asks for `brand.logo`, never a file name.
- Every `href` shown to a person is in a content file. A route that the code needs to compute, such as a payee id, comes from a route helper in code and carries no wording.
- Alt text is content. Decorative images get an empty alt in the content file.

## 3. What a component may contain

| Allowed in `.astro` and `.ts` | Not allowed |
| --- | --- |
| Elements, props, loops, conditions | Visible words, including button labels, headings, `aria-label` text, `title` attributes, `placeholder` text, and error messages |
| Class names from `global.css` | `<style>`, `style=`, CSS modules, scoped styles, Tailwind or other utility frameworks |
| Identifiers, route keys, API paths | Literal URLs shown to people, image paths, or alt text |
| Dynamic values from content or the API | Pluralization or date wording written in code. Use a content template with placeholders such as `{count}` and a formatter in `src/lib/format.ts` for dates and money |

Client scripts (the signature pad, the file download, the form submit) read their messages from `data-` attributes that Astro renders from content. A script contains no sentences.

## 4. The global stylesheet

`src/styles/global.css` is the only stylesheet. It is imported once, in the base layout. Order inside the file:

1. `@font-face` for Source Serif 4, IBM Plex Sans, and IBM Plex Mono, self-hosted as `woff2` with `font-display: swap`.
2. Tokens: everything in [brand/tokens.css](brand/tokens.css), including the dark theme.
3. Reset and base elements (`body`, headings, links, forms, tables).
4. Layout primitives, prefix `l-`.
5. Components, prefix `c-`.
6. A few utilities, prefix `u-`.

Rules:
- Naming is `block`, `block__element`, `block--modifier`, for example `c-button--primary`. One class selects one thing. Selectors use one class, with no ids and no deep nesting, so nothing outranks anything else.
- Colors, spacing, radius, shadow, and font come from tokens only. A hex code or pixel value outside the token block is a defect.
- Mobile first. Two breakpoints, `40rem` and `64rem`. Tap targets are 44 px or larger.
- Dark mode and reduced motion are handled in the stylesheet, not in components.
- A varying value (a progress width, for example) is set through a `data-` attribute and a class, never an inline style.
- Budget: 30 KB unminified. The site loads this one file and caches it.

### Component inventory

New work reuses these. Add a component only when nothing here fits, and add it to the stylesheet and this table in the same change.

| Group | Classes | Use |
| --- | --- | --- |
| Layout | `l-page`, `l-container`, `l-stack`, `l-cluster`, `l-grid`, `l-split` | Page width, vertical rhythm, rows that wrap, grids, two-column layouts |
| Header and footer | `c-header`, `c-nav`, `c-footer`, `c-skip-link` | Site chrome |
| Hero and sections | `c-hero`, `c-section`, `c-steps`, `c-card`, `c-cta-band` | Marketing pages |
| Text | `c-prose`, `c-lede`, `c-link` | Long text, intro line, links |
| Buttons | `c-button`, `c-button--primary` (orange, once per screen), `--secondary`, `--quiet`, `--danger`, `--block` | All actions |
| Forms | `c-form`, `c-field`, `c-field__label`, `c-field__help`, `c-field__error`, `c-input`, `c-select`, `c-checkbox`, `c-fieldset` | All forms |
| Feedback | `c-notice` with `--info`, `--warning`, `--error`, `--success`, `c-toast`, `c-empty` | Messages and empty states |
| Data | `c-table`, `c-chip` with `--not-requested`, `--sent`, `--failed`, `--declined`, `--completed`, `c-details`, `c-filters` | Lists, statuses, detail rows |
| Special | `c-code` (one-time code entry), `c-signature` (signature pad), `c-dialog`, `c-plans`, `c-faq` | Specific screens |
| Utilities | `u-visually-hidden`, `u-text-muted`, `u-nowrap` | Only these three |

## 5. Screen content files

Each screen in the [screen inventory](screen-inventory-2026-10-08-1254.md) has one content file. The id is the file name.

| Id | Inventory # | Route |
| --- | --- | --- |
| home | 1 | / |
| how-it-works | 2 | /how-it-works |
| pricing | 3 | /pricing |
| faq | 4 | /faq |
| security | 5 | /security |
| support | 6 | /support |
| privacy, terms | 7 | /privacy, /terms |
| signup | 8 | /signup |
| signup-sent | 9 | /signup/sent |
| verify | 10 | /verify |
| signin | 11 | /signin |
| reset-request | 12 | /reset-password |
| reset-set | 13 | /reset-password/{token} |
| app-home | 14 | /app |
| businesses | 15 | /app/businesses |
| business-form | 16 | /app/businesses/new, /app/businesses/{id}/edit |
| reminder-settings | 17 | /app/businesses/{id}/reminders |
| payees | 18 | /app/payees |
| payee-form | 19 | /app/payees/new, /app/payees/{id}/edit |
| payee-detail | 20 | /app/payees/{id} |
| request-form | 21 | /app/payees/{id}/request |
| password-check | 22 | dialog |
| export | 23 | /app/export |
| upgrade | 24 | /app/upgrade |
| upgrade-complete | 25 | /app/upgrade/complete |
| settings | 26 | /app/settings |
| cancel-account | 27 | /app/settings/cancel |
| save-shared-w9 | 28 | /app/save-w9 |
| w9-form | 29 | /r/{token} |
| w9-review | 30 | /r/{token}/review |
| w9-done | 31 | /r/{token}/done |
| link-problem | 32 | /r/{token}/problem |
| decline | 33 | /r/{token}/decline |
| saved-signin | 34 | /r/{token}/signin |
| saved-confirm | 35 | /r/{token}/confirm |
| payee-account | 36 | /r/{token}/account |
| stop-reminders | 37 | /r/{token}/stop-reminders |
| payee-home | 38 | /payee |
| payee-update | 39 | /payee/update |
| payee-send | 40 | /payee/send |
| payee-shares | 41 | /payee/shares |
| payee-settings | 42 | /payee/settings |
| share-landing | 43 | /s/{token} |
| share-verify | 44 | /s/{token}/verify |
| share-download | 45 | /s/{token}/w9 |
| share-problem | 46 | /s/{token}/problem |
| optout | 47 | /optout/{token} |
| optout-fallback | 48 | /optout |
| unsubscribe | 49 | /unsubscribe/{token} |
| admin-signin, admin-flags, admin-flag-detail, admin-settings, admin-audit | 50 to 54 | /admin/... |

## 6. How pages render

- `src/pages/[...slug].astro` renders every public page from `pages/`. It chooses a layout from `template` and loops over `sections`.
- Each app or link route is a thin `.astro` file that loads its screen by id and renders `<Screen entry={...} />` or `<Form entry={...} />`. These components draw the title, intro, fields, actions, links, notices, and states from the file. A route file adds only its data calls and the route helper.
- Header, footer, and notices read `site/` and `ui/`.
- Status chips take a status key from the API and look up the word in `ui/statuses.md`.
- API error codes are looked up in `ui/errors.md`. A code with no entry fails the content check.

## 7. Checks that enforce the rules

A script, `scripts/check-site-rules.mjs`, runs in the build and in CI. It fails when it finds:

| Check | Fails when |
| --- | --- |
| No styles in components | A `.astro` file has `<style`, `style=`, `class:list` with an unknown class, or imports a `.css` file other than the layout's import of `global.css` |
| No inline literals | A `.astro` file has visible text outside `{}` expressions, or an attribute such as `aria-label`, `alt`, `title`, `placeholder` with a literal string |
| Known classes | A class used in any component or content file is not defined in `global.css` |
| No stray colors | `global.css` has a color or size literal outside the token block |
| Content complete | A content file misses a required field, an API error code has no message, or a status has no label |
| Links resolve | An `href` in content points to a route that no page defines |
| Size | `global.css` is over 30 KB |

Two more checks run alongside: an accessibility scan (axe) of every built page in light and dark, and a visual check at 360 px and 1280 px widths.

## 8. Changing things later

| To change | Edit |
| --- | --- |
| Any wording | The Markdown file for that screen, or `ui/` for shared words |
| A logo, image, or alt text | `site/global.md` |
| Navigation or footer links | `site/nav.md`, `site/footer.md` |
| A color, font, or spacing value | The token block in `global.css` |
| How a component looks | Its class in `global.css`, which changes every place it is used |
| An email | `email/messages.json` and `email/email.css` |
