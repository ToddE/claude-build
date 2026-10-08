*inform9 credentials and setup checklist. Draft 1. Version 2026-10-08 15:42 ET. Variables are defined in [.env.example](../.env.example). Real values go in `.env.local` (local) and Worker secrets (production).*

# inform9 Credentials and Setup Checklist

## 1. What you do and what I do

| Step | Who | When needed |
| --- | --- | --- |
| Create the accounts in section 2 and paste values into `.env.local` | You | Before each phase listed |
| Add the DNS records in section 4 | You | Phase 1 for the site, before the beta for email |
| Run the resource commands in section 3 | I run them once you have the Cloudflare token | Phase 1 |
| Everything else in the build plan | I do it | After credentials exist |

Local development needs none of these except `MASTER_KEY`, which is already generated in `.env.local`. Email is written to the console and Stripe is mocked until real keys exist. So the build can start now.

## 2. Accounts and values

| # | Account | Create at | Values to copy into `.env.local` | Needed by |
| --- | --- | --- | --- | --- |
| 1 | Cloudflare (you have one, $5 per month) | dash.cloudflare.com | `CLOUDFLARE_ACCOUNT_ID`. A custom API token named "inform9 deploy" with Workers, D1, R2, Pages, and DNS edit for the inform9.com zone: `CLOUDFLARE_API_TOKEN` | Phase 1 deploy |
| 2 | SMTP2GO | smtp2go.com | An API key limited to sending: `SMTP2GO_API_KEY`. A random webhook secret you choose: `SMTP2GO_WEBHOOK_SECRET` | Phase 1 for real email |
| 3 | Cloudflare Turnstile | Cloudflare dashboard, Turnstile | `TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET_KEY` | Phase 1 sign-up |
| 4 | Stripe (test mode first) | dashboard.stripe.com | `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`. After the webhook exists: `STRIPE_WEBHOOK_SECRET`. After you create two annual prices: `STRIPE_PRICE_PLUS`, `STRIPE_PRICE_PRO` | Phase 3 |
| 5 | Umami (Cloud, or self-hosted) | umami.is | `UMAMI_SCRIPT_URL`, `UMAMI_SITE_ID` for the inform9.com website | Phase 4, or sooner |
| 6 | Google Cloud OAuth | console.cloud.google.com | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`. Skip until Google sign-in is built | Deferred |
| 7 | An inbox for support@inform9.com | Cloudflare Email Routing (free) forwarding to your own address | `SUPPORT_EMAIL` | Before the beta |

### Choices to make in each account

- **SMTP2GO:** add the sender domain `mail.inform9.com` (not the main domain, to keep account mail apart from anything you send later). Turn off click and open tracking for these messages, since the links are secure tokens.
- **Stripe:** two one-time annual prices, Plus at $20 and Pro at $36 (starting values from the data model). Create the webhook endpoint `https://inform9.com/api/v1/webhooks/stripe` and select the events for a completed checkout, failed or delayed payment, and refund.
- **Turnstile:** a widget for inform9.com and for localhost during development.
- **Umami:** one website for inform9.com. Turn on "respect Do Not Track" if offered.

## 3. Resources I create once the Cloudflare token exists

```
wrangler d1 create inform9
wrangler r2 bucket create inform9-w9
wrangler r2 bucket create inform9-backups
wrangler d1 execute inform9 --file=migrations/0001_schema.sql
wrangler d1 execute inform9 --file=email/dist/templates.seed.sql
wrangler d1 execute inform9 --file=migrations/0002_seed_settings_and_plans.sql
```

Then secrets, one per command (`wrangler secret put NAME`): `MASTER_KEY`, `SMTP2GO_API_KEY`, `SMTP2GO_WEBHOOK_SECRET`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `TURNSTILE_SECRET_KEY`, `ADMIN_BOOTSTRAP_PASSWORD`.

Use a **different `MASTER_KEY` in production** from the one in `.env.local`. Generate it with `openssl rand -base64 32` and keep a copy in your password manager. Without it, stored taxpayer IDs and PDFs cannot be read, so it must also be backed up somewhere separate from the Cloudflare account.

## 4. DNS records for inform9.com

Add inform9.com to Cloudflare first (change the nameservers at your registrar to the two Cloudflare gives you). After that, Cloudflare manages the records.

| Purpose | Record | Where the value comes from |
| --- | --- | --- |
| Site (apex and www) | Added automatically when you attach inform9.com as a custom domain to the Worker or Pages project | Cloudflare |
| Email sending (SMTP2GO) | About three CNAME records on `mail.inform9.com` and its subdomains: DKIM, return path, and tracking (if used). SMTP2GO shows the exact names and values after you add the sender domain | SMTP2GO, Sending, Verified senders |
| SPF | Covered by the return-path record SMTP2GO gives you. Do not add a second SPF record | SMTP2GO |
| DMARC | A TXT record at `_dmarc.inform9.com`: `v=DMARC1; p=none; rua=mailto:dmarc@inform9.com`. Move to `p=quarantine` after two clean weeks | You |
| Inbound support mail | MX records, created when you turn on Cloudflare Email Routing | Cloudflare |
| Email logo and assets | Served from `inform9.com/email/`, so no extra record | The site |

Set each SMTP2GO record to "DNS only" (grey cloud) in Cloudflare so email authentication still works.

## 5. Checks before each phase

| Before | Confirm |
| --- | --- |
| Phase 1 deploy | Cloudflare token works, D1 and R2 exist, domain attached, Turnstile keys set |
| Beta | SMTP2GO domain verified, DMARC published, a test email passes in Gmail, Outlook, and Apple Mail, support@inform9.com receives mail, Terms and Privacy text approved |
| Payments | Stripe test checkout works end to end, webhook delivers, then switch to live keys |
| Public launch | Backups restore in a test, production `MASTER_KEY` backed up separately, legal review items closed |

## 6. Rotation and loss

- Rotate `MASTER_KEY` by adding a new `MASTER_KEY_ID`, keeping the old key in `PREVIOUS_MASTER_KEYS`, and re-encrypting in the background. Old data stays readable meanwhile.
- If an API key leaks, revoke it in the provider's dashboard first, then set the new value as a Worker secret.
