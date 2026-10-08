-- inform9 D1 schema (SQLite). Draft 1. Built from use cases Draft 15.
-- Conventions: ids are UUIDv4 text. Times are integer milliseconds since the Unix epoch, UTC.
-- Emails are stored lowercase. Booleans are 0 or 1. Enum values are checked in the table.
-- Taxpayer IDs and PDFs are encrypted by the application before they reach D1 and R2.

PRAGMA foreign_keys = ON;

-- ---------- plans and accounts ----------

CREATE TABLE plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price_cents INTEGER NOT NULL DEFAULT 0 CHECK (price_cents >= 0),
  payee_limit INTEGER,                -- null means no limit
  business_limit INTEGER,             -- null means no limit
  reminder_schedule_editable INTEGER NOT NULL DEFAULT 0 CHECK (reminder_schedule_editable IN (0,1)),
  stripe_price_id TEXT,
  active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0,1)),
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  password_hash TEXT,                 -- null for an account that uses only Google sign-in
  password_salt TEXT,
  password_iterations INTEGER,
  status TEXT NOT NULL CHECK (status IN ('pending','active','canceled')),
  email_verified_at INTEGER,
  plan_id TEXT NOT NULL REFERENCES plans(id),
  plan_renews_at INTEGER,
  stripe_customer_id TEXT,
  marketing_opt_in INTEGER NOT NULL DEFAULT 0 CHECK (marketing_opt_in IN (0,1)),
  marketing_opt_in_changed_at INTEGER,
  send_status TEXT NOT NULL DEFAULT 'ok' CHECK (send_status IN ('ok','paused','blocked')),
  send_status_changed_at INTEGER,
  mfa_enabled INTEGER NOT NULL DEFAULT 0 CHECK (mfa_enabled IN (0,1)),
  mfa_secret_enc TEXT,
  mfa_secret_iv TEXT,
  mfa_key_id TEXT,
  google_sub TEXT UNIQUE,             -- reserved for Google sign-in, not used in the first release
  canceled_at INTEGER,
  data_handling_due_at INTEGER,
  last_sign_in_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX idx_accounts_status ON accounts(status);

CREATE TABLE admins (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  password_iterations INTEGER NOT NULL,
  mfa_secret_enc TEXT,
  mfa_secret_iv TEXT,
  mfa_key_id TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','disabled')),
  created_at INTEGER NOT NULL
);

CREATE TABLE sessions (
  id_hash TEXT PRIMARY KEY,           -- SHA-256 of the session token
  account_id TEXT REFERENCES accounts(id) ON DELETE CASCADE,
  admin_id TEXT REFERENCES admins(id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  last_seen_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  password_confirmed_at INTEGER,      -- set when the password is re-entered for a W-9 download
  ip TEXT,
  user_agent TEXT,
  CHECK ((account_id IS NOT NULL) <> (admin_id IS NOT NULL))
);
CREATE INDEX idx_sessions_account ON sessions(account_id);

CREATE TABLE email_tokens (           -- account verification and password reset
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  purpose TEXT NOT NULL CHECK (purpose IN ('verify_email','reset_password')),
  token_hash TEXT NOT NULL UNIQUE,
  expires_at INTEGER NOT NULL,
  used_at INTEGER,
  created_at INTEGER NOT NULL
);

CREATE TABLE signin_throttle (        -- counts failures by email address, including unknown addresses
  email TEXT PRIMARY KEY,
  failed_count INTEGER NOT NULL DEFAULT 0,
  locked_until INTEGER,
  updated_at INTEGER NOT NULL
);

CREATE TABLE consent_log (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN ('marketing','terms','esign')),
  value INTEGER NOT NULL CHECK (value IN (0,1)),
  text_version TEXT NOT NULL,
  at INTEGER NOT NULL
);

-- ---------- businesses and payees ----------

CREATE TABLE businesses (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_key TEXT NOT NULL,             -- lowercase, spaces collapsed, used for the duplicate check
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  notification_email TEXT NOT NULL,
  pending_notification_email TEXT,    -- waits for verification
  notification_email_verified_at INTEGER,
  reminder_interval_days INTEGER NOT NULL DEFAULT 7 CHECK (reminder_interval_days BETWEEN 3 AND 30),
  reminder_cap INTEGER NOT NULL DEFAULT 3 CHECK (reminder_cap BETWEEN 1 AND 6),
  reminders_enabled INTEGER NOT NULL DEFAULT 1 CHECK (reminders_enabled IN (0,1)),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (account_id, name_key)
);

CREATE TABLE payees (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived')),
  archived_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (account_id, email)
);
CREATE INDEX idx_payees_account_status ON payees(account_id, status);

CREATE TABLE payee_businesses (
  payee_id TEXT NOT NULL REFERENCES payees(id) ON DELETE CASCADE,
  business_id TEXT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  PRIMARY KEY (payee_id, business_id)
);

-- ---------- signed W-9 documents ----------

CREATE TABLE w9_documents (           -- one row per signed PDF
  id TEXT PRIMARY KEY,
  payee_account_id TEXT REFERENCES accounts(id),   -- set when the signer has an account
  requester_business_id TEXT REFERENCES businesses(id), -- the business shown as requester, null for a payee-sent copy
  legal_name TEXT NOT NULL,
  business_name TEXT,
  tax_classification TEXT NOT NULL,
  llc_classification TEXT,
  exempt_payee_code TEXT,
  fatca_code TEXT,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  tin_type TEXT NOT NULL CHECK (tin_type IN ('ssn','ein')),
  tin_last4 TEXT NOT NULL,
  tin_enc TEXT NOT NULL,
  tin_iv TEXT NOT NULL,
  tin_key_id TEXT NOT NULL,
  pdf_object_key TEXT NOT NULL,       -- UUIDv4 key in R2
  pdf_iv TEXT NOT NULL,
  pdf_key_id TEXT NOT NULL,
  pdf_sha256 TEXT NOT NULL,
  w9_form_revision TEXT NOT NULL,
  signer_email TEXT NOT NULL,
  signer_ip TEXT,
  signer_user_agent TEXT,
  esign_consent_version TEXT NOT NULL,
  approval_method TEXT NOT NULL CHECK (approval_method IN ('typed_and_signed','saved_info_approved')),
  signed_at INTEGER NOT NULL
);

CREATE TABLE payee_profiles (         -- saved information for a Payee account
  account_id TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  legal_name TEXT NOT NULL,
  business_name TEXT,
  tax_classification TEXT NOT NULL,
  llc_classification TEXT,
  exempt_payee_code TEXT,
  fatca_code TEXT,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  tin_type TEXT NOT NULL CHECK (tin_type IN ('ssn','ein')),
  tin_last4 TEXT NOT NULL,
  tin_enc TEXT NOT NULL,
  tin_iv TEXT NOT NULL,
  tin_key_id TEXT NOT NULL,
  latest_document_id TEXT REFERENCES w9_documents(id),
  last_confirmed_at INTEGER,
  updated_at INTEGER NOT NULL
);

-- ---------- requests ----------

CREATE TABLE requests (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  payee_id TEXT NOT NULL REFERENCES payees(id),
  token_hash TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('sent','delivery_failed','completed','declined','canceled')),
  decline_code TEXT CHECK (decline_code IN ('declined','not_right_person','foreign_payee')),
  decline_reason TEXT,
  reminders_ended INTEGER NOT NULL DEFAULT 0 CHECK (reminders_ended IN (0,1)),  -- shown as the note "Reminders ended" beside Sent
  reminder_interval_days INTEGER CHECK (reminder_interval_days BETWEEN 3 AND 30), -- per-request override
  reminder_cap INTEGER CHECK (reminder_cap BETWEEN 1 AND 6),                       -- per-request override
  reminder_count INTEGER NOT NULL DEFAULT 0,
  next_reminder_at INTEGER,
  resend_count INTEGER NOT NULL DEFAULT 0,
  sent_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  completed_at INTEGER,
  closed_at INTEGER,                  -- declined or canceled
  completion_token_hash TEXT,         -- lets the Payee create an account right after completing, valid 30 minutes
  completion_token_expires_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX idx_requests_account ON requests(account_id, status);
CREATE INDEX idx_requests_due ON requests(next_reminder_at) WHERE status = 'sent' AND next_reminder_at IS NOT NULL;
CREATE INDEX idx_requests_payee ON requests(payee_id);

CREATE TABLE request_businesses (
  request_id TEXT NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
  business_id TEXT NOT NULL REFERENCES businesses(id),
  payee_id TEXT NOT NULL REFERENCES payees(id),
  is_open INTEGER NOT NULL DEFAULT 1 CHECK (is_open IN (0,1)),
  PRIMARY KEY (request_id, business_id)
);
-- One open request per payee and business.
CREATE UNIQUE INDEX uq_open_request ON request_businesses(payee_id, business_id) WHERE is_open = 1;

CREATE TABLE w9_versions (            -- the copy a business holds
  id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL REFERENCES businesses(id),
  payee_id TEXT NOT NULL REFERENCES payees(id),
  document_id TEXT NOT NULL REFERENCES w9_documents(id),
  request_id TEXT REFERENCES requests(id),
  share_id TEXT REFERENCES shares(id),
  source TEXT NOT NULL CHECK (source IN ('requested','reused','updated','sent_by_payee')),
  version_no INTEGER NOT NULL,
  updated_marker INTEGER NOT NULL DEFAULT 0 CHECK (updated_marker IN (0,1)),
  created_at INTEGER NOT NULL,
  UNIQUE (business_id, payee_id, version_no)
);
CREATE INDEX idx_w9_versions_business ON w9_versions(business_id, payee_id);

-- ---------- payee-sent W-9s ----------

CREATE TABLE shares (
  id TEXT PRIMARY KEY,
  sender_account_id TEXT NOT NULL REFERENCES accounts(id),
  document_id TEXT NOT NULL REFERENCES w9_documents(id),
  recipient_email TEXT NOT NULL,
  recipient_business_name TEXT NOT NULL,
  token_hash TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('sent','delivery_failed','retrieved','misdirected','not_accepted','saved')),
  link_active INTEGER NOT NULL DEFAULT 1 CHECK (link_active IN (0,1)),
  daily_download_cap INTEGER NOT NULL,   -- copied from settings when sent
  sent_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,           -- copied from settings when sent
  retrieved_at INTEGER,
  saved_account_id TEXT REFERENCES accounts(id),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX idx_shares_sender ON shares(sender_account_id, status);
CREATE INDEX idx_shares_recipient ON shares(sender_account_id, recipient_email);

CREATE TABLE download_log (           -- every download attempt on a payee-sent link
  id TEXT PRIMARY KEY,
  share_id TEXT NOT NULL REFERENCES shares(id) ON DELETE CASCADE,
  download_no INTEGER,
  blocked INTEGER NOT NULL DEFAULT 0 CHECK (blocked IN (0,1)),
  ip TEXT,
  user_agent TEXT,
  at INTEGER NOT NULL
);
CREATE INDEX idx_download_log_share ON download_log(share_id, at);

CREATE TABLE otp_codes (
  id TEXT PRIMARY KEY,
  purpose TEXT NOT NULL CHECK (purpose IN ('share_retrieve','opt_out')),
  email TEXT NOT NULL,
  share_id TEXT REFERENCES shares(id) ON DELETE CASCADE,
  code_hash TEXT NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0,
  locked_until INTEGER,
  expires_at INTEGER NOT NULL,
  used_at INTEGER,
  created_at INTEGER NOT NULL
);
CREATE INDEX idx_otp_email ON otp_codes(email, purpose);

CREATE TABLE opt_outs (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  scope TEXT NOT NULL CHECK (scope IN ('payee','all')),
  payee_account_id TEXT REFERENCES accounts(id),   -- set when scope is payee
  kind TEXT NOT NULL CHECK (kind IN ('opt_out','unwanted','misdirected')),
  share_id TEXT REFERENCES shares(id),
  created_at INTEGER NOT NULL
);
CREATE INDEX idx_opt_outs_email ON opt_outs(email);

CREATE TABLE pending_saves (          -- a Save to account that waits for an upgrade
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  share_id TEXT NOT NULL REFERENCES shares(id) ON DELETE CASCADE,
  business_id TEXT REFERENCES businesses(id),
  new_business_json TEXT,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE reminder_stops (         -- a Payee used Stop reminders, by email address
  email TEXT PRIMARY KEY,
  created_at INTEGER NOT NULL
);

CREATE TABLE abuse_flags (
  id TEXT PRIMARY KEY,
  payee_account_id TEXT NOT NULL REFERENCES accounts(id),
  reason TEXT NOT NULL CHECK (reason IN ('bounce_pattern','reports','send_cap_abuse','other')),
  detail TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','reviewed')),
  decision TEXT CHECK (decision IN ('lift_pause','keep_pause','block')),
  note TEXT,
  reviewer_admin_id TEXT REFERENCES admins(id),
  created_at INTEGER NOT NULL,
  reviewed_at INTEGER
);
CREATE INDEX idx_abuse_flags_status ON abuse_flags(status, created_at);

-- ---------- email, payments, exports, usage ----------

CREATE TABLE email_log (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL,                  -- for example request, reminder, completed_notice, otp
  to_email TEXT NOT NULL,
  account_id TEXT REFERENCES accounts(id),
  request_id TEXT REFERENCES requests(id),
  share_id TEXT REFERENCES shares(id),
  provider TEXT NOT NULL,
  provider_message_id TEXT,
  status TEXT NOT NULL CHECK (status IN ('queued','sent','delivered','bounced','complained','failed')),
  error TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX idx_email_log_provider ON email_log(provider_message_id);
CREATE INDEX idx_email_log_recipient_day ON email_log(to_email, kind, created_at);

CREATE TABLE payments (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id),
  plan_id TEXT NOT NULL REFERENCES plans(id),
  stripe_session_id TEXT UNIQUE,
  stripe_payment_intent TEXT,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  status TEXT NOT NULL CHECK (status IN ('pending','paid','failed','refunded')),
  receipt_sent_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE export_log (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id),
  business_ids TEXT NOT NULL,          -- JSON array
  format TEXT NOT NULL CHECK (format IN ('qbo_csv','xero_csv','general_csv','zip_pdf')),
  tin_option TEXT NOT NULL CHECK (tin_option IN ('masked','full')),
  created_at INTEGER NOT NULL
);

CREATE TABLE account_usage (
  account_id TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  w9_count INTEGER NOT NULL DEFAULT 0,
  storage_bytes INTEGER NOT NULL DEFAULT 0,
  emails_sent INTEGER NOT NULL DEFAULT 0,
  updated_at INTEGER NOT NULL
);

-- ---------- email templates ----------

CREATE TABLE email_templates (        -- one row per message. The layout is shared by several messages.
  event_key TEXT PRIMARY KEY,          -- for example request, reminder, owner_completed, otp
  layout TEXT NOT NULL DEFAULT 'standard', -- one layout today. Others can be added later.
  audience TEXT NOT NULL CHECK (audience IN ('business_owner','payee','recipient','any')),
  subject TEXT NOT NULL,               -- may hold placeholders such as {{payee_name}}
  heading TEXT NOT NULL,
  body TEXT NOT NULL,
  button_label TEXT,
  button_url_key TEXT,                 -- names the link the application supplies, for example secure_link
  details TEXT NOT NULL DEFAULT '[]',  -- JSON array of {label, value} rows, values may hold placeholders
  footnote TEXT,
  show_code INTEGER NOT NULL DEFAULT 0 CHECK (show_code IN (0,1)),
  unsubscribe INTEGER NOT NULL DEFAULT 0 CHECK (unsubscribe IN (0,1)),
  placeholders TEXT NOT NULL,          -- JSON array of the placeholders this message may use
  enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0,1)),
  version INTEGER NOT NULL DEFAULT 1,
  updated_at INTEGER NOT NULL,
  updated_by TEXT REFERENCES admins(id)
);

-- ---------- history, settings, audit ----------

CREATE TABLE status_events (          -- status history for requests and shares
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('request','share')),
  entity_id TEXT NOT NULL,
  status TEXT NOT NULL,
  note TEXT,
  at INTEGER NOT NULL
);
CREATE INDEX idx_status_events_entity ON status_events(entity_type, entity_id, at);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  group_name TEXT NOT NULL,
  label TEXT NOT NULL,
  value_type TEXT NOT NULL CHECK (value_type IN ('integer','boolean','text','enum')),
  value TEXT NOT NULL,
  default_value TEXT NOT NULL,
  min_value INTEGER,
  max_value INTEGER,
  allowed_values TEXT,                 -- JSON array for enum settings
  applies TEXT NOT NULL DEFAULT 'immediate' CHECK (applies IN ('immediate','future_items')),
  updated_at INTEGER NOT NULL,
  updated_by TEXT REFERENCES admins(id)
);

CREATE TABLE secrets (                -- provider keys entered in the administrator screens, encrypted
  key TEXT PRIMARY KEY,                -- for example smtp2go_api_key, stripe_secret_key, stripe_webhook_secret
  value_enc TEXT NOT NULL,
  iv TEXT NOT NULL,
  key_id TEXT NOT NULL,
  last4 TEXT,
  updated_at INTEGER NOT NULL,
  updated_by TEXT REFERENCES admins(id)
);

CREATE TABLE audit_log (
  id TEXT PRIMARY KEY,
  actor_type TEXT NOT NULL CHECK (actor_type IN ('account','admin','system')),
  actor_id TEXT,
  action TEXT NOT NULL,
  target_type TEXT,
  target_id TEXT,
  before_json TEXT,
  after_json TEXT,
  ip TEXT,
  at INTEGER NOT NULL
);
CREATE INDEX idx_audit_target ON audit_log(target_type, target_id, at);
CREATE INDEX idx_audit_actor ON audit_log(actor_type, actor_id, at);
