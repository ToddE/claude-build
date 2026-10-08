*inform9 screen and email inventory. Version 2026-10-08 12:54 ET. Built from use cases Draft 15 in [use-cases.md](use-cases.md). No visual design exists yet. This document lists structure only.*

# inform9.com Screen and Email Inventory

## Purpose

This is the input for page design. It lists every page and email the use cases need, who sees it, and which use case it serves. Section 4 lists questions that design should settle.

## 1. Sitemap

```
inform9.com
├── Public site: / , /how-it-works , /pricing , /faq , /security , /support , /privacy , /terms
├── Account access: /signup , /signin , /verify , /reset-password
├── Business Owner app (/app): home, businesses, payees, payee details, export, upgrade, settings
├── Payee app (/payee): saved W-9, update, send, shares, communication preferences
├── Request links (/r/<token>): complete W-9, confirm saved info, decline, stop reminders
├── Share links (/s/<token>): verify code, download, save to account
├── Opt-out and unsubscribe: /optout/<token> , /optout , /unsubscribe/<token>
└── Administrator (/admin): sign in, flags, link settings, audit log
```

## 2. Screens

Audience key: **Public** anyone. **Owner** signed-in Business Owner. **Payee** signed-in account holder using saved W-9 features. **Link** person holding an emailed link, no account needed. **Admin** inform9 staff.

### Public site

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 1 | / | Public | Explain the service and start sign-up | PR/FAQ | One-line promise, three-step explanation, price summary, Sign up button |
| 2 | /how-it-works | Public | Show owner and payee steps | PR/FAQ | Steps for owner and payee, example screens |
| 3 | /pricing | Public | State free and paid plans | Upgrade After Free Limit | Free plan (1 business, 3 payees), paid range $20 to $36 per year, what counts as a payee |
| 4 | /faq | Public | Answer buyer questions | PR/FAQ | External FAQ content |
| 5 | /security | Public | State protections | PR/FAQ | Written after protections are confirmed |
| 6 | /support | Public | Contact for help | PR/FAQ | Support channel is undecided |
| 7 | /privacy, /terms | Public | Legal text | Create Account and Sign In, Create Payee Account | Terms acceptance link used at sign-up. The privacy page lists the one functional sign-in cookie and the cookieless analytics |

### Account access

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 8 | /signup | Public | Create an account | Create Account and Sign In | Name, email, password, unchecked updates box, terms, functional cookie notice |
| 9 | /signup/sent | Public | Tell the person to check email | Create Account and Sign In | Message, resend link |
| 10 | /verify | Public | Activate the account | Create Account and Sign In | Success state, expired-link state with new link offer |
| 11 | /signin | Public | Sign in | Create Account and Sign In, Sign Out | Email, password, wrong-credentials message, locked state, forgot password link, functional cookie notice |
| 12 | /reset-password | Public | Request a reset link | Reset Password | Email field, same confirmation message for every address |
| 13 | /reset-password/<token> | Public | Set a new password | Reset Password | New password and confirm, expired-link state, confirmation |

### Business Owner app

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 14 | /app | Owner | Home after sign-in | Create Account and Sign In | Prompt to add a first business, counts of payees and open requests |
| 15 | /app/businesses | Owner | List businesses | Add Business, Edit Business | Business list, Add business button, plan limit message |
| 16 | /app/businesses/new, /app/businesses/<id>/edit | Owner | Add or change a business | Add Business, Edit Business | Name, address, notification email, duplicate-name and missing-field errors, limit and upgrade message |
| 17 | /app/businesses/<id>/reminders | Owner | Set reminder schedule | Set Reminder Schedule | Interval 3 to 30, cap 1 to 6, turn off, apply to open requests, upgrade message on free plan |
| 18 | /app/payees | Owner | Payee list for a business | View and Download W-9s, Follow Up on Incomplete Request | Business switcher, status filter (including Open and Archived), status with Reminders ended note and decline reason, days open, Updated marker |
| 19 | /app/payees/new, /app/payees/<id>/edit | Owner | Add or change a payee | Add Payee Contact, Edit or Archive Payee | Name, email, linked businesses, duplicate-email message, limit and upgrade message |
| 20 | /app/payees/<id> | Owner | Payee details | View and Download W-9s, Cancel Request, Follow Up on Incomplete Request, Edit or Archive Payee | W-9 versions with dates and Download, request history, Resend, Cancel Request, Archive and Restore |
| 21 | /app/payees/<id>/request | Owner | Send a request | Request W-9 | Business selection, reminder override (paid), open-request warning |
| 22 | Password check (dialog) | Owner | Confirm password before sensitive actions | View and Download W-9s, Export Payee Data, Cancel Account and Data Handling | Password field, error state, explanation that the file shows the full taxpayer ID |
| 23 | /app/export | Owner | Export data | Export Payee Data | Business choice, format (QuickBooks Online, Xero, general CSV, ZIP of PDFs), masked or full taxpayer ID, nothing-to-export message |
| 24 | /app/upgrade | Owner | Choose a paid plan | Upgrade After Free Limit | Plan options and prices, payment handoff, declined and unavailable states |
| 25 | /app/upgrade/complete | Owner | Confirm payment | Upgrade After Free Limit | Confirmation, receipt note, return to the interrupted action |
| 26 | /app/settings | Owner | Account settings | Cancel Account and Data Handling, Manage Communication Preferences | Profile, password, communication preferences, plan, cancel account |
| 27 | /app/settings/cancel | Owner | Cancel the account | Cancel Account and Data Handling | What happens to stored W-9s, retention policy, download first link, password confirmation |
| 28 | /app/save-w9 | Owner | Save a payee-sent W-9 | Save Payee-Sent W-9 to Account | Choose or add business, limit and upgrade message |

### Request links (Payee, no account needed)

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 29 | /r/<token> | Link | Complete the W-9 | Complete and Sign W-9 | Each requesting business listed, name, business name, tax classification, address, taxpayer ID, field errors, Decline, "I am not the right person", "I am not a U.S. person" |
| 30 | /r/<token>/review | Link | Review, certify, and sign | Complete and Sign W-9 | Summary of entries, certification, signature pad, storage-error message |
| 31 | /r/<token>/done | Link | Confirm and offer an account | Complete and Sign W-9 | Confirmation, Create account offer |
| 32 | /r/<token>/problem | Link | Link not usable | Complete and Sign W-9, Payee Declines Request | Invalid, used, expired, or canceled message with "ask the business for a new request" |
| 33 | /r/<token>/decline | Link | Decline | Payee Declines Request | Optional reason with a note that it is shared with the business, confirm |
| 34 | /r/<token>/signin | Link | Sign in before using saved info | Confirm and Reuse Saved Payee Information | Sign-in form, reset link |
| 35 | /r/<token>/confirm | Link | Approve saved information | Confirm and Reuse Saved Payee Information | Businesses on the request, saved information, edit, missing-field prompts, one-click approval, decline |
| 36 | /r/<token>/account | Link | Create a payee account | Create Payee Account | Email prefilled, password, terms, unchecked updates box, existing-account message |
| 37 | /r/<token>/stop-reminders | Link | Stop reminders | Send W-9 Reminders | Confirmation that reminders to this address stop |

### Payee app

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 38 | /payee | Payee | Saved W-9 home | Create Payee Account, Update a W-9 | Saved information summary, businesses that hold a W-9, Update, Send W-9 |
| 39 | /payee/update | Payee | Update a W-9 | Update a W-9 | Edit fields, choose businesses (all or some), certify, sign, result list |
| 40 | /payee/send | Payee | Send a W-9 on your own | Payee Sends W-9 to Business, Limit Unsolicited Sends | Business name, recipient email, review, approve, cap and opt-out messages |
| 41 | /payee/shares | Payee | See sends and their status | View Sent W-9s | Send list and details with status (Sent, Retrieved, Delivery failed, Misdirected, Not accepted, Saved), status filter, Send again, empty state |
| 42 | /payee/settings | Payee | Communication preferences | Manage Communication Preferences | Updates box, list of emails that always apply |

### Share links (Business Recipient, no account needed)

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 43 | /s/<token> | Link | Landing page | Business Recipient Retrieves Payee-Sent W-9 | Sender name only, send code button |
| 44 | /s/<token>/verify | Link | Enter one-time code | Business Recipient Retrieves Payee-Sent W-9 | Code field, wrong or expired code, new code, locked state |
| 45 | /s/<token>/w9 | Link | Download or save | Business Recipient Retrieves Payee-Sent W-9, Save Payee-Sent W-9 to Account | Download, Save to account, "I am not the right recipient", daily cap message, account offer |
| 46 | /s/<token>/problem | Link | Link not usable | Business Recipient Retrieves Payee-Sent W-9 | Invalid, expired, or deactivated message with "the sender must send again" |
| 47 | /optout/<token> | Link | Opt out or report | Opt Out of Payee-Sent W-9s | Three options, confirm, already-opted-out state, confirmation |
| 48 | /optout | Public | Opt out without a link | Opt Out of Payee-Sent W-9s | Email, one-time code, confirmation |
| 49 | /unsubscribe/<token> | Link | Stop update emails | Manage Communication Preferences | One-click unsubscribe confirmation |

### Administrator (internal)

| # | Route | Audience | Purpose | Use cases | Key elements |
| --- | --- | --- | --- | --- | --- |
| 50 | /admin/signin | Admin | Separate sign-in | Configure Platform Settings | Email, password, second factor |
| 51 | /admin/flags | Admin | List abuse flags | Review Abuse Flags | Open flags with Payee, reason, date, empty state |
| 52 | /admin/flags/<id> | Admin | Review one flag | Review Abuse Flags | Sends, bounces, reports, opt-outs, Lift pause, Keep pause, Block sending, note |
| 53 | /admin/settings | Admin | Platform settings (link settings now; later email provider, sign-in options including Google, limits, plans) | Configure Platform Settings | Expiry days (up to 7), daily cap (3 to 5), audit of changes |
| 54 | /admin/audit | Admin | Audit log | Configure Platform Settings, Review Abuse Flags | Searchable list of decisions and changes |

## 3. Emails

| # | Email | Sent to | Trigger | Use case | Must include |
| --- | --- | --- | --- | --- | --- |
| 1 | Verify your email | Business Owner or Payee | Sign-up | Create Account and Sign In, Create Payee Account | Verification link, new-link path when expired |
| 2 | Reset your password | Account holder | Forgot password | Reset Password | Time-limited link |
| 3 | W-9 request | Payee | Owner sends a request or resends | Request W-9, Follow Up on Incomplete Request | Each business named, secure link, Decline, "I am not the right person" |
| 4 | W-9 reminder | Payee | Reminder due | Send W-9 Reminders | Business names, link, Decline, "I am not the right person", Stop reminders. One per day |
| 5 | W-9 received | Payee | Form completed | Complete and Sign W-9, Confirm and Reuse Saved Payee Information | Confirmation of submission |
| 6 | W-9 completed | Business Owner | Form completed | Complete and Sign W-9, Confirm and Reuse Saved Payee Information | Payee name, link to the payee page |
| 7 | W-9 updated | Business Owner | Payee updates | Update a W-9 | Payee name, new version note |
| 8 | Request declined | Business Owner | Decline, "not the right person", or foreign payee | Payee Declines Request, Complete and Sign W-9 | Reason if given |
| 9 | Email could not be delivered | Business Owner | Bounce | Request W-9, Send W-9 Reminders, Follow Up on Incomplete Request | Payee name, how to fix |
| 10 | Reminders ended | Business Owner | Cap reached | Send W-9 Reminders | Request still open, resend link |
| 11 | Reminders stopped | Business Owner | Bounce or Payee stop | Send W-9 Reminders | Reason |
| 12 | Receipt | Business Owner | Upgrade | Upgrade After Free Limit | Plan, amount, renewal date |
| 13 | Account canceled | Business Owner | Cancel | Cancel Account and Data Handling | Retention terms |
| 14 | A W-9 is waiting | Business Recipient | Payee sends | Payee Sends W-9 to Business | Sender name, link, opt-out link that never expires |
| 15 | Your code | Business Recipient | Link opened or opt-out fallback | Business Recipient Retrieves Payee-Sent W-9, Opt Out of Payee-Sent W-9s | One-time code and lifetime |
| 16 | W-9 retrieved | Payee | First download | Business Recipient Retrieves Payee-Sent W-9 | Recipient and time |
| 17 | Wrong recipient or not accepted | Payee | Recipient reports or opts out | Business Recipient Retrieves Payee-Sent W-9, Opt Out of Payee-Sent W-9s | Status of the send |
| 18 | Send could not be delivered | Payee | Share bounces | Payee Sends W-9 to Business | Correct the address and send again |
| 19 | Sending paused, available, or blocked | Payee | Admin decision or pause | Limit Unsolicited Sends, Review Abuse Flags | Reason and next step |
| 20 | Product updates | Accounts that opted in | Marketing sends | Manage Communication Preferences | Unsubscribe link that never expires |

## Cookie notice (component on screens 8 and 11)

A short line above the form: "inform9 uses one cookie to keep you signed in. Signing in does not work without it. We use no advertising or tracking cookies." with a link to the privacy page. It has no Accept or Decline buttons because the cookie is required for the sign-in to work.

## 4. Design questions

- Payees will often open links on a phone. Design the request page and signature step for small screens and touch first.
- Whether the W-9 form is one page or a short sequence of steps (screens 29 and 30).
- How a saved-information payee moves between the request link, sign-in, and approval without confusion (screens 34 and 35).
- How the owner payee list shows Sent with a Reminders ended note and Declined with a reason (screen 18).
- Wording for the taxpayer ID warning in the password check (screen 22).
- Brand: name treatment, color, type, and tone. None exist yet.
- Accessibility target for all screens, including the signature step.
