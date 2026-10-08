*inform9 Architecture Guidelines. Draft 2. Version 2026-10-08 15:00 ET. Replaces the first single-form W-9 intake design, which is in the archive. Matches use cases Draft 15 in [use-cases.md](use-cases.md).*

# inform9 System Architecture Guidelines

## 1. Scope and model

inform9.com is one platform run by inform9. Anyone can create an account. An account can hold one or more businesses (one on the free plan). A business sends W-9 requests to payees, and each payee can also have saved W-9 information in the same account. One email address has one account.

People who use the platform:
- Business Owner: signs in to request, view, download, and export W-9s.
- Payee: completes a W-9 from an emailed link, with or without an account. A Payee with an account can reuse saved information and send a W-9 on their own.
- Business Recipient: receives a payee-sent W-9 link and verifies by one-time code. No account is needed to download.
- Administrator: inform9 staff. Separate login. Reviews abuse flags and sets platform limits.

## 2. Platform and constraints

- Hosting: Cloudflare, on the Workers Paid plan ($5 per month) as the baseline. The Free plan's CPU limit is too low for PDF generation and password hashing.
- Front end: Astro with TypeScript. Pages are mostly static. Signed-in screens call the API from the browser.
- Back end: TypeScript on Cloudflare Workers, using Web Standards APIs only (`fetch`, `crypto.subtle`, streams). No Node.js core modules.
- Deploy shape: Workers with static assets or Pages Functions, whichever Cloudflare recommends when the project is created. The code layout is the same for both.
- Cost target: stay inside the Workers Paid allowances for D1, R2, and Workers while usage is small. Record storage and email counts per account from the start so cost per customer can be measured (PR/FAQ, per-customer economics).
- Later options if limits start to hurt: move the API to a small always-on server on Fly.io (Rust or Go), keep Astro and R2 as they are, and use SQLite or Postgres. This is not part of the MVP.

## 3. Route map

| Area | Routes | Who | Notes |
| --- | --- | --- | --- |
| Public site | `/`, `/pricing`, `/how-it-works`, `/faq`, `/privacy`, `/terms`, `/security` | Anyone | Static pages |
| Account access | `/signup`, `/signin`, `/reset-password`, `/verify` | Anyone | Same pages for Business Owners and Payees |
| Business Owner app | `/app/*` | Signed-in account | Businesses, payees, requests, W-9s, export, settings, upgrade |
| Payee app | `/payee/*` | Signed-in account | Saved W-9, update, send, communication preferences |
| Request and share links | `/r/<token>`, `/s/<token>` | Holder of the link | Complete a W-9, approve saved info, decline; retrieve a payee-sent W-9 |
| Opt-out | `/optout/<token>`, `/optout` | Anyone | Never expires |
| API | `/api/*` | Mixed | JSON over TLS; every handler checks the session or link token |
| Administrator | `/admin/*` | Administrator | Separate login, flags, link settings, audit log |

Astro middleware guards `/app/*`, `/payee/*`, and `/admin/*` by looking up the session. API handlers repeat the check. Middleware alone is never the only protection.

## 4. Data model (D1)

Every query for Business Owner data filters by account id. Account-level separation is enforced in one data access module, not in each route.

- `accounts`: id, email, password hash and parameters, status, update preference with consent time and wording version, plan id, created at.
- `plans`: id, name, payee limit, business limit, reminder schedule editable, price. Plan values are rows, not code, because pricing and paid limits stay open until after the beta.
- `businesses`: id, account id, legal name, address, notification email, reminder interval, reminder cap, reminders on or off.
- `payees`: id, account id, name, email, status (active or archived).
- `payee_businesses`: payee id, business id.
- `requests`: id, payee id, status, secure link token hash, link expiry, reminder override, resend count, reminder count, next reminder at, decline reason, note.
- `request_businesses`: request id, business id.
- `w9_versions`: id, business id, payee id, request id or share id, source (requested, sent by payee), version number, R2 object key (UUIDv4), PDF SHA-256, W-9 form revision, encrypted TIN, TIN key id, TIN IV, signed at, signature audit data.
- `payee_profiles`: account id, saved W-9 fields, encrypted TIN with key id and IV.
- `shares`: id, payee account id, recipient email, status, link token hash, expiry, download cap, W-9 version reference.
- `download_log`: share id or W-9 version id, who, time, download number, blocked flag.
- `otp_codes`: purpose, email, code hash, expiry, attempts.
- `opt_outs`: email or domain, scope, payee id if scoped, created at.
- `reminder_stops`: email, created at.
- `sessions`: id hash, account or admin id, created, last seen, password confirmed at.
- `send_log` and `abuse_flags`: per-Payee send counts, bounces, reports, flag state, reviewer, decision.
- `export_log` and `audit_log`: actor, action, target, time, details.
- `settings`: one typed row per value with a minimum, a maximum, and a default. Covers email, sign-in and security, links and codes, reminders, payee-sent controls, abuse review, and retention. Every change is written to `audit_log`. The first release may read these from environment variables; the table and the administrator screens are the target. See [decisions-log-2026-10-08-1545.md](decisions-log-2026-10-08-1545.md).

Binary files stay out of D1. Rows hold a UUIDv4 object key that points to R2.

## 5. Security

### Passwords and sessions
- Password hashing: PBKDF2-SHA256 with `crypto.subtle`, the Workers maximum of 100,000 iterations, a random salt per account, and the parameters stored with the hash so they can be raised later.
- Sessions are random 256-bit tokens. D1 stores only the SHA-256 hash. The token travels in one cookie (see Cookies and analytics below). A session table lets the platform end other sessions after a password reset and on sign out.
- Idle timeout [IDLE_MINUTES]. Sign-in locks for [LOCK_MINUTES] after [MAX_SIGNIN_ATTEMPTS] failures per email address.
- Google is the only single sign-on option planned, and it is not part of the first release. Its on or off switch and client settings belong in the administrator screens. Accounts match by verified email address.
- Multi-factor sign-in is undecided. Taxpayer IDs make it worth deciding before the beta.
- A download of a W-9 PDF asks for the password once per session. A ZIP export asks every time. The session row records when the password was confirmed.

### Links and codes
- Request, share, verification, reset, and opt-out links hold a random 256-bit token. D1 stores only its hash and an expiry (opt-out never expires).
- One-time codes are stored as hashes with an attempt counter and a lock.
- Compare secrets in constant time.

### Cookies and analytics
- The platform sets exactly one cookie: the sign-in session, named `__Host-i9s`, with `HttpOnly`, `Secure`, `SameSite=Lax`, `Path=/`, and no `Domain`. Its value is a random token and holds no personal data. It has no expiry date, so the browser drops it when closed, and the server ends the session after the idle and maximum times in settings. `SameSite=Lax` keeps the session when someone arrives from an email link.
- The cookie is set only when someone signs in or activates an account. Visitors to the public site, request links, share links, and opt-out pages get no cookie. Those link flows carry their token in the URL.
- Local storage and session storage are not used for sign-in. Scripts on the page can read them, so a script injection could steal the token. They also fall under the same privacy rules as cookies.
- State-changing requests are protected against cross-site requests with `SameSite=Lax`, an `Origin` header check, and a custom request header.
- Because the cookie is needed for the signed-in features to work, it is a functional cookie. The sign-in and sign-up pages show a short notice that says so. The notice is not an opt-in or an opt-out, since signed-in features cannot work without the cookie. The privacy page lists it.
- Analytics: Umami, which uses no cookies and no local storage. The script loads on the public pages only. The signed-in app, request links, share links, and opt-out pages do not load it, so no tax-related page is tracked. Respect Do Not Track. The script URL and site id are settings. The Content Security Policy allows only that one analytics origin.
- Any new cookie, local storage item, or third-party script needs a decision first and an update to the notice and privacy page.

### Taxpayer IDs and W-9 files
- Taxpayer IDs (SSN or EIN) are encrypted with AES-256-GCM through `crypto.subtle` before they reach D1. Each record has its own random IV and a key id. Keys come from Worker secrets. A key id on each record allows rotation.
- The signed W-9 PDF also shows the full taxpayer ID, so the PDF bytes are encrypted with AES-256-GCM before they are written to R2, with the key id and IV stored in the W-9 row. Cloudflare's encryption at rest is a second layer, not the only one.
- The PDF SHA-256 is stored in D1 so any later change can be detected.
- Taxpayer IDs never appear in logs, URLs, or error messages. CSV exports mask to the last four digits unless the Business Owner confirms the password and chooses the full number.

### Electronic signature record
- On signing, store the confirmed email, `CF-Connecting-IP`, user agent, and a millisecond UTC timestamp. Burn a receipt block with those values into the PDF footer. Store the e-sign consent text version the Payee saw.
- IRS conditions for electronic W-9s, and whether one-click approval by a signed-in Payee satisfies them, need legal review before launch.

### Abuse controls
- Cloudflare rate limiting and Turnstile on sign-up, sign-in, one-time code requests, and payee-sent forms.
- Payee-sent W-9 limits: daily cap per Payee, per-recipient limit, repeat window, opt-out check, pause on bounce patterns. See Limit Unsolicited Sends and Review Abuse Flags.

## 6. Documents and PDF work

- Template: the official IRS Form W-9, stored with its revision date. Record the revision on each W-9 row.
- Fill with `pdf-lib` (edge build). Use the template's named form fields if they work. Otherwise place text by coordinates. Stamp the requester name and address of the specific business, stamp the signature PNG from `signature_pad`, add the receipt block, then flatten so the form cannot be edited.
- One submission from a Payee creates one PDF per business on the request. Each PDF names only its own business as the requester.
- First build task: a test that fills, signs, and flattens the real IRS template and checks the result in several PDF viewers. This confirms the approach before the rest of the app is built.
- CPU and memory: generate one PDF per request step and store it before generating the next. Bulk work runs in smaller steps.

## 7. Email

- Prototype provider: SMTP2GO, called through its HTTPS API from the Worker. Its webhooks report bounces and spam complaints.
- Sending goes through one provider interface with two functions: send a message, and read a bounce or complaint webhook. SMTP2GO is the first adapter. The administrator picks the active provider, sender address, and reply-to in the administrator screens and can send a test email. API keys are Worker secrets.
- Send from a dedicated subdomain with SPF, DKIM, and DMARC set up on inform9.com before the beta.
- Transactional emails (requests, reminders, notices, codes, receipts) are separate from update emails. Update emails go only to accounts that checked the box, and carry an unsubscribe link that never expires.
- Each request and reminder email includes Decline and "I am not the right person". Each reminder also includes Stop reminders. Payee-sent emails include an opt-out link.
- The bounce webhook sets Delivery failed and cancels reminders.
- Email bodies must name the sender and the business and follow CAN-SPAM. Counsel review is open.

## 8. Scheduled work

- A Cron Trigger runs on a short interval, for example every 15 minutes. It reads due reminders from D1, applies the one-reminder-per-day rule per Payee, combines same-day reminders from several businesses into one email, sends, updates counts, and schedules the next one.
- The same job ends expired links and sessions, and clears old one-time codes.
- If reminder volume grows, move sending to Cloudflare Queues.

## 9. Payments

- Stripe Checkout for annual plans, with a webhook that sets the plan and the renewal date. Plan changes happen only after the webhook confirms the charge.
- Plan limits are read from the `plans` table at each check.
- Refunds, sales tax, renewal and lapse rules are open.

## 10. Export and bulk packaging

- CSV for QuickBooks Online, Xero, and general use are built from D1 rows, with the taxpayer ID masked by default.
- ZIP of W-9 PDFs: read the file list from D1, stream each object from R2, decrypt it, and write it into the archive with `fflate`'s streaming interface. Send the response as `application/zip` without holding the whole archive in memory. Cap the files per request and split larger exports into parts.
- Column mappings come from the current QuickBooks Online and Xero import templates and need checking.

## 11. Observability and operations

- Alerts to the administrator when a W-9 cannot be stored or a file is missing from R2.
- Per-account counters for stored W-9s, storage bytes, and emails sent.
- Backups: scheduled D1 exports to R2, with an R2 bucket that keeps versions. Test a restore before the beta.
- Retention and deletion follow a policy that is not defined yet. IRS record-keeping periods need counsel review.

## 12. Local development and testing

- `wrangler dev` with local D1 and R2. Seed data and a sample W-9 fixture. A mock email sender that writes to the console, and a mock Stripe webhook.
- Test cases in [test-cases.md](test-cases.md) are the acceptance tests. Requirements in [functional-requirements.md](functional-requirements.md) trace to them.

## 13. Open decisions

- MFA, password rules, retention policy, legal review items, plan prices and limits, [MAX_RESENDS], [REPORT_THRESHOLD], [REVIEW_DAYS], and the Workers or Pages choice at project creation.
