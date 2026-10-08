*inform9 settings questionnaire. Version 2026-10-08 13:41 ET. Covers every open placeholder in [use-cases.md](use-cases.md), [pr-faq.md](pr-faq.md), and [ArchitectureGuidelines.md](ArchitectureGuidelines.md).*

> The recommendations in this questionnaire were adopted as decisions. See [decisions-log-2026-10-08-1545.md](decisions-log-2026-10-08-1545.md), which is where to change one.

# inform9 Settings Questionnaire

## How to use this

Each row has a recommendation. Write your answer in the last column, or write "OK" to accept the recommendation. Rows marked **Admin** become settings in the administrator screens, with a minimum and maximum so a typing error cannot break the service. The first release reads them from environment variables, and the administrator screen is the target.

Rules for every Admin setting:
- A change is recorded in the audit log with who, old value, new value, and time.
- A change applies to items created afterward when the value is stored on the item (link expiry, reminder schedule). Other values apply at once.
- A value outside its minimum and maximum is rejected.

## Part A. Decisions

| # | Question | Recommendation | Your answer |
| --- | --- | --- | --- |
| A1 | Should all values in Part B, and the email provider, be editable in the administrator screens? | Yes. Replace the single Configure Platform Settings use case with "Configure Platform Settings", grouped as Email, Sign-in options, Sign-in and security, Links and codes, Reminders, Payee-sent controls, Abuse review, Plans, and Retention. Keep the audit log. | |
| A2 | Email for the prototype | SMTP2GO, sent through its HTTPS API from the Worker. Workers are better suited to an HTTP call than a raw SMTP connection. SMTP2GO webhooks report bounces and spam complaints to the platform. | |
| A3 | Email provider as a setting | Put sending behind one provider interface with two functions: send a message, and read a bounce or complaint webhook. SMTP2GO is the first adapter. The administrator chooses the active provider, sender address, and reply-to. A Send test email button checks the setup. | |
| A4 | Where API keys live | Worker secrets, not the database. The administrator screen shows which key is set and never shows the key. If you want to paste keys in the screen, store them encrypted in D1 with the same key service used for taxpayer IDs. | |
| A5 | Sender identity | Send from a subdomain such as mail.inform9.com with SPF, DKIM, and DMARC set. Display name "inform9 on behalf of {Business}". Reply-to is the business notification email, so a Payee's reply reaches the owner. | |
| A6 | Multi-factor sign-in | Require it for administrators now. Offer it to Business Owners and Payees in the beta and make it required for any account that downloads full taxpayer IDs. Use an authenticator app code. | |
| A7 | Password rules | At least 12 characters, no composition rules, block known breached passwords, no forced expiry. | |
| A8 | Does a Payee save partial progress on the W-9 form? | No in the first release. The form takes a few minutes, and saving partial taxpayer IDs adds risk. | |
| A9 | Signature details to record | Confirmed email, IP address from CF-Connecting-IP, browser user agent, millisecond UTC timestamp, and the e-sign consent text version. Print the first four in the PDF footer. | |
| A10 | Does the Payee type the recipient email twice when sending a W-9? | Yes. A mistyped address sends a taxpayer ID document to a stranger. | |
| A11 | Saved Payee information: one profile or several? | One profile in the first release. A Payee who needs a different tax identity for another business completes that request manually. Revisit after the beta. | |
| A12 | Does a new notification email on a business need verification? | Yes. Send a link to the new address. The old address stays active until the new one is verified. | |
| A13 | After a Business Owner cancels, what happens to the same account's saved W-9 and Payee sign-in? | The person can still sign in as a Payee and keep the saved information. Only the plan, businesses, and business data follow the retention policy. | |
| A14 | Can a canceled request followed by a new request restart the resend count? | Yes, and log it. The cost is low and the owner's intent is clear. Revisit if abused. | |
| A15 | Google sign-in | Not in the first release. Google is the only single sign-on option we will support. Add a "Sign-in options" group to the administrator settings with an on or off switch, the Google client ID, and the client secret (a Worker secret, never shown). Until it is on, the sign-in and sign-up pages show no Google button. When it is built, an account is matched by verified email address, so one email address still has one account. | |
| A16 | Cookies | One functional cookie for the sign-in session, set only after sign-in. No analytics or marketing cookies. No local storage for sign-in. A notice on the sign-in and sign-up pages says so, with no opt-in or opt-out, because sign-in cannot work without it. Public pages set no cookie, so they need no banner. Counsel should confirm this reading for the states and countries you serve. | |
| A17 | Analytics | Umami, which uses no cookies, on the public pages only. Never on the signed-in app, request links, share links, or opt-out pages. Settings: on or off, script URL, site id. Respect Do Not Track. | |

## Part B. Values

### Sign-in and security

| # | Placeholder | Used in | Recommendation | Admin range | Your answer |
| --- | --- | --- | --- | --- | --- |
| B1 | [MAX_SIGNIN_ATTEMPTS] | Create Account and Sign In | 5 failed attempts per email address | 3 to 10 | |
| B2 | [LOCK_MINUTES] for sign-in | Create Account and Sign In | 15 minutes. Split from the one-time code lock so each can change on its own: SIGNIN_LOCK_MINUTES and CODE_LOCK_MINUTES. | 5 to 60 | |
| B3 | [IDLE_MINUTES] | Sign Out | 30 minutes idle. Also end any session after 12 hours. | 10 to 240 | |
| B4 | [RESET_LINK_HOURS] | Reset Password | 1 hour | 1 to 24 | |
| B5 | Verification link lifetime | Create Account and Sign In, Create Payee Account | 24 hours | 1 to 72 | |

### Links and one-time codes

| # | Placeholder | Used in | Recommendation | Admin range | Your answer |
| --- | --- | --- | --- | --- | --- |
| B6 | [REQUEST_LINK_DAYS] | Request W-9, Send W-9 Reminders | Derive it from the schedule: interval times cap, plus 14 days, never under 30. The default schedule gives 35 days. A paid schedule of 30 days times 6 reminders gives 194 days. Store the expiry on each request. | 30 to 200 | |
| B7 | Payee-sent link expiry | Configure Platform Settings | 7 days (the maximum) | 1 to 7 | |
| B8 | Daily download cap per payee-sent link | Business Recipient Retrieves Payee-Sent W-9 | 5 (the maximum) for the prototype. Lower it to 3 once the download log shows how people use the page. | 3 to 5 | |
| B9 | [CODE_MINUTES] | Business Recipient Retrieves Payee-Sent W-9, Opt Out of Payee-Sent W-9s | 6-digit code that lasts 10 minutes | 5 to 30 | |
| B10 | [MAX_CODE_ATTEMPTS] | same | 5 wrong entries per code | 3 to 10 | |
| B11 | [LOCK_MINUTES] for codes | same | 15 minutes | 5 to 60 | |

### Reminders and follow-up

| # | Placeholder | Used in | Recommendation | Admin range | Your answer |
| --- | --- | --- | --- | --- | --- |
| B12 | Default reminder interval and cap | Set Reminder Schedule | Every 7 days, 3 reminders (already decided). Paid plans choose 3 to 30 days and 1 to 6 reminders (already decided). | Bounds as decided | |
| B13 | [FOLLOW_UP_DAYS] | Follow Up on Incomplete Request | 7 days, the same as the reminder interval | 3 to 30 | |
| B14 | [MAX_RESENDS] | Follow Up on Incomplete Request | 3 resends per request | 1 to 10 | |
| B15 | Hour of day for reminders | Send W-9 Reminders | 10:00 in the Payee's time zone if known, otherwise 10:00 Eastern, on weekdays | 6:00 to 18:00 | |

### Payee-sent W-9 controls and abuse review

| # | Placeholder | Used in | Recommendation | Admin range | Your answer |
| --- | --- | --- | --- | --- | --- |
| B16 | [DAILY_SEND_CAP] | Limit Unsolicited Sends | 5 sends per Payee per 24 hours. 2 per 24 hours during the first 7 days of the account. | 1 to 25 | |
| B17 | [PER_RECIPIENT_LIMIT] and [REPEAT_WINDOW] | Limit Unsolicited Sends | 1 active send per recipient, and no repeat to the same recipient within 7 days (the link lifetime) | 1 to 30 days | |
| B18 | Pause pattern | Limit Unsolicited Sends | Pause a Payee when 3 or more of their last 10 sends bounce, or when 2 recipients report them in 7 days | Editable numbers | |
| B19 | [REPORT_THRESHOLD] | Review Abuse Flags | 3 reports from different recipients in 30 days raises a flag | 1 to 10 | |
| B20 | [REVIEW_DAYS] | Review Abuse Flags | Show the last 30 days of activity | 7 to 90 | |

### Plans and pricing

| # | Placeholder | Used in | Recommendation | Admin range | Your answer |
| --- | --- | --- | --- | --- | --- |
| B21 | Plan structure | Upgrade After Free Limit | Two paid tiers to test in the beta. Free: 1 business, 3 payees. Plus: $20 per year, 3 businesses, 25 payees. Pro: $36 per year, 10 businesses, 100 payees. The PR/FAQ assumes an average of 10 payees per subscriber, so 25 should cover most. | Plans are table rows | |
| B22 | [PLAN_PRICE], [PAID_LIMIT], [PAID_BUSINESS_LIMIT] | Upgrade After Free Limit, Add Business | Read from the plans table. Fill after the beta. | Any positive number | |
| B23 | Beta pricing | PR/FAQ | Free Plus plan for beta users, no payment details collected, ends at public launch with 30 days notice | | |

### Retention and data

| # | Placeholder | Used in | Recommendation | Admin range | Your answer |
| --- | --- | --- | --- | --- | --- |
| B24 | [RETENTION_POLICY] and [DATE] | Cancel Account and Data Handling | After cancellation: 90 days to download, then delete the business's W-9s and records within 30 days. The business owner is responsible for their own tax record keeping, and the cancel screen says so. Counsel must confirm this against IRS record-keeping periods before launch. | 30 to 3650 days | |
| B25 | [INACTIVE_MONTHS] | PR/FAQ internal FAQ | Archive a Payee account after 24 months with no sign-in and no requests. Warn 30 days and 7 days before. | 12 to 60 | |
| B26 | [REVALIDATION_PERIOD] | Confirm and Reuse Saved Payee Information | Ask the Payee to re-confirm saved information after 12 months. The prompt does not block approval. | 6 to 36 | |
| B27 | Audit log retention | Configure Platform Settings | 7 years | | |

### Schedule

| # | Placeholder | Used in | Recommendation | Your answer |
| --- | --- | --- | --- | --- |
| B28 | MVP [DATE] | PR/FAQ | The W-9 fill, sign, and flatten spike by October 22, 2026. MVP for inform9's own use by November 20, 2026. | |
| B29 | Beta [TIMEFRAME] | PR/FAQ | November 23 to December 18, 2026, with 10 to 20 users | |
| B30 | Public launch | PR/FAQ | December 29, 2026 only if legal review of e-signature, retention, and email rules is finished. Otherwise move the date. | |

## What changes in the documents after you answer

- [use-cases.md](use-cases.md): replace each placeholder with the value, and replace Configure Platform Settings with Configure Platform Settings if A1 is yes.
- [functional-requirements.md](functional-requirements.md) and the `.csv`: matching updates, plus new requirements for the settings screens and the email provider interface.
- [ArchitectureGuidelines.md](ArchitectureGuidelines.md): the settings table and provider interface.
- [screen-inventory-2026-10-08-1254.md](screen-inventory-2026-10-08-1254.md): the administrator settings screens, grouped as in A1.
