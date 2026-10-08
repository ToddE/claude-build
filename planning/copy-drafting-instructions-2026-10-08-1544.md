*inform9 copy drafting instructions. Draft 1. Version 2026-10-08 15:44 ET. These are instructions for Claude to follow when drafting all site and screen text. Output goes in `src/content/` as described in [site-content-and-style-rules-2026-10-08-1543.md](site-content-and-style-rules-2026-10-08-1543.md).*

# Instructions for Drafting inform9 Copy

## 1. Job

Draft every word a person sees on inform9.com and in the app, as Markdown content files. Write once, in the right file, in the brand voice. Do not put any copy in `.astro` files. Do not ask for decisions that this document or the planning files already answer.

## 2. Read first, every time

1. [Brand guide](brand/brand-guide-2026-10-08-1355.md), section 7 for voice.
2. [Screen inventory](screen-inventory-2026-10-08-1254.md) for the screens, their purpose, and key elements.
3. The use case for the screen, in [use-cases.md](use-cases.md), for the steps, the alternate and exception paths, and the open issues. Every path the person can reach needs words.
4. [API spec](api-spec-2026-10-08-1522.md) for the error codes each screen can receive.
5. [Data model](data-model-2026-10-08-1352.md), section 2, for exact status names.
6. [PR/FAQ](pr-faq.md) for the product promise, prices, and limits. It is the only source for claims about the product.
7. [Site content and style rules](site-content-and-style-rules-2026-10-08-1543.md) for the file format and schema.

## 3. Voice rules

These come from the brand guide and Todd's writing style rules.

- Plain and direct. Short sentences. Humble where the screen asks for trust.
- Active voice. Address the person as "you". The Business Owner is "you". A payee sees "you" too.
- Say what happens next on every screen that asks for something.
- No em dashes. Use a period, a comma, or a colon.
- No hyperbole, no exclamation marks, no filler openers such as "Welcome back!" or "Oops".
- No metaphors or figures of speech. Do not use words like "trap", "tax", "journey", "seamless", or "powerful".
- No contrastive framing. Do not write "not X, but Y", "it is not just X", or "instead of X". State what is true.
- No sentence that explains the same point twice.
- Define a term the first time it appears on a screen, or avoid it. Use "taxpayer ID" and write "(SSN or EIN)" once where the field asks for it. Do not use industry jargon such as "backup withholding" or "TIN matching" in the interface.
- Reading level around grade 8.
- Sound like a careful person who does this job every day, not a marketing department.

### Never claim

- That inform9 is "IRS approved", "IRS compliant", "secure", "encrypted", or "bank-level" until the security answer is confirmed. Where a screen needs such a claim, write `[CONFIRM: <claim>]` so it can be found and settled. Describe only what the product does, for example "inform9 shares your W-9 only with the business that asked."
- Legal outcomes, tax advice, or that a form is "valid". The legal and tax pages carry `[LEGAL REVIEW]` markers.
- Prices, limits, or timings that differ from the plans table in the data model and the settings defaults. Use placeholders such as `{payee_limit}` for values that settings can change.
- That inform9 prepares or files 1099s, or collects W-8 forms. It does neither.

## 4. Words to use

| Say | Do not say |
| --- | --- |
| sign in, sign out | log in, log out, login |
| account | profile (for the sign-in account) |
| business | organization, company, tenant |
| payee | contractor or vendor, except on marketing pages where "contractors and vendors" explains who a payee is |
| W-9 | w9, W9 |
| taxpayer ID | TIN or tax ID (write "SSN or EIN" in the field help) |
| request, send request | ask, invite |
| complete and sign | fill out and submit |
| download | export (for a single PDF) |
| export | download all |
| archive | delete, remove (for a payee) |
| cancel request | revoke, withdraw |
| decline | reject |
| reminder | nudge, follow-up email |
| plan, upgrade | subscription, tier |
| saved information | profile |

Statuses use these exact words, from [data model](data-model-2026-10-08-1352.md): Not requested, Sent, Delivery failed, Declined, Completed, with the note "Reminders ended", and the reasons "Not the right person" and "Foreign payee". Share statuses: Sent, Retrieved, Delivery failed, Misdirected, Not accepted, Saved.

## 5. Length limits

| Element | Limit |
| --- | --- |
| Page title or screen heading | 8 words |
| Intro line | 2 sentences, 30 words |
| Button | 1 to 3 words, starting with a verb. Name the object: "Send request", "Archive payee". Never "Yes", "No", "OK", or "Submit" |
| Field label | 1 to 4 words |
| Field help | 1 sentence, 20 words |
| Error message | 1 or 2 sentences, 25 words. Say what happened and what to do |
| Empty state | A heading, one sentence, one action |
| Confirmation dialog | A heading, 2 sentences on the consequences, a confirm button, a cancel button |
| Meta description | 150 characters |
| Alt text | 100 characters |

## 6. Templates by screen type

**Form screen** (sign-up, business form, W-9 form): heading, one intro line, fields with label and help, errors per rule, one primary action, a secondary link, and what happens next.

**List screen** (payees, shares): heading, intro line, filter labels, column headings, row action labels, empty state, and a loading state.

**Detail screen** (payee detail): heading pattern with a placeholder, section headings, row labels, action labels.

**Confirmation dialog** (cancel request, archive payee, cancel account, block sender): state the action, the effect on the person's data, what stays, and whether the other side is told. Buttons name the action and a plain "Keep" or "Go back".

**Result screen** (done, sent, saved): heading that states the result, one line on what happens next, and the next action.

**Link problem screen**: one message for all causes, as the API returns one code. Say what the person can do: ask the business or sender for a new link.

**Marketing page**: one idea per section. Use facts from the PR/FAQ. Keep prices as placeholders tied to settings.

## 7. Catalogs to write first

These are shared by many screens. Draft them before any screen.

1. `ui/buttons.md`: shared labels such as Save, Cancel, Continue, Download, Resend, Archive, Restore.
2. `ui/statuses.md`: chip words for every request and share status, plus the notes and reasons.
3. `ui/errors.md`: one entry for each API error code in the [API spec](api-spec-2026-10-08-1522.md), section 1, including `plan_limit`, `password_required`, `link_unusable`, `account_locked` (with `{locked_until}`), `rate_limited`, `cap_reached`, `open_request_exists`, `resend_limit_reached`, `email_registered`, `duplicate_business_name`, `duplicate_payee_email`, `storage_failed`, `nothing_to_export`, `too_many_files`. Include a general "something went wrong" message that tells the person to try again and gives the support address.
4. `ui/validation.md`: one message per rule: required, email format, password length and strength, name, address line, city, state, ZIP code, SSN format, EIN format, matching fields (recipient email twice), signature required, certification required, consent required.
5. `ui/notices.md`: the cookie notice, session ended, signed out, saved, copied, link sent, and the "sign-in cookie" explanation. The cookie notice must say: one cookie keeps you signed in, signing in does not work without it, and there are no advertising or tracking cookies.
6. `ui/confirmations.md`: cancel request, archive payee, restore payee, cancel account, block sender, lift pause.

## 8. Order of work

1. Catalogs in section 7.
2. `site/global.md`, `site/nav.md`, `site/footer.md`.
3. The seven screens for the first build phase: signup, signup-sent, verify, signin, reset-request, reset-set, app-home. Then the Phase 1 owner and payee screens: businesses, business-form, payees, payee-form, payee-detail, request-form, password-check, w9-form, w9-review, w9-done, link-problem, decline.
4. Public pages: home, how-it-works, pricing, faq, support, then security, privacy, terms with `[CONFIRM]` and `[LEGAL REVIEW]` markers.
5. Beta screens: saved-signin, saved-confirm, payee-account, stop-reminders, payee-home, payee-update, reminder-settings, export, upgrade, upgrade-complete, settings, cancel-account.
6. Launch screens: payee-send, payee-shares, share-landing, share-verify, share-download, share-problem, optout, optout-fallback, unsubscribe, save-shared-w9, payee-settings.
7. Admin screens, in plain wording: admin-signin, admin-flags, admin-flag-detail, admin-settings, admin-audit.

## 9. Per-screen process

1. Read the use case. List every path the person can take. Each path needs: a state or message on this screen, or a pointer to another screen.
2. List the API error codes the screen can get. Each needs a message in `states.errors` or the shared catalog.
3. Write the content file to the schema. Use `{placeholder}` names for dynamic values. Use only these: `{name}`, `{business_name}`, `{business_names}`, `{payee_name}`, `{payee_email}`, `{recipient_email}`, `{sender_name}`, `{date}`, `{count}`, `{limit}`, `{plan_name}`, `{price}`, `{locked_until}`, `{support_email}`.
4. Run the self-check in section 10 before saving.
5. Record anything that needs a human in `planning/copy-open-items-<timestamp>.md`: each `[CONFIRM]` and `[LEGAL REVIEW]` marker, with the file and line.

## 10. Self-check before saving a file

- Every use case path has words.
- Every API error code the screen can get has a message.
- Voice rules in section 3 hold: no em dash, no "not X, but Y", no exclamation mark, no hype word.
- Button labels name an object and start with a verb.
- Terms follow section 4, and statuses use the exact words.
- No claim from the "Never claim" list.
- Limits in section 5 hold.
- No `.astro` file was changed to hold copy.
- Front matter matches the schema in the site rules, so the build's content check passes.

## 11. What needs a human

| Item | Why |
| --- | --- |
| Privacy policy, terms of use, e-signature disclosure, W-9 certification wording | Legal review. Draft with `[LEGAL REVIEW]` markers and the facts from the use cases |
| Security page and security FAQ answer | Wait for confirmed protections. Draft the structure only |
| Retention wording on the cancel screen | Retention policy is open. Use the settings defaults and mark `[LEGAL REVIEW]` |
| Pricing wording | Prices are placeholders until after the beta |
| Support response time | The support channel and response time are open. Use `{support_email}` and no promise of timing |
