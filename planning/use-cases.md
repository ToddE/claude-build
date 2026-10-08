*inform9 Use Cases. Draft 15. Version 2026-10-08 14:10 ET. Draft 14 plus View Sent W-9s.*

# inform9 Use Cases

## Document Notes

**Format applied.** Every Basic Path row is numbered, and each row is one action. Alternate and exception paths are labeled `A<N>` and `E<N>` after the Basic Path step they leave, with steps `A<N>.1`, `E<N>.1`, and so on. A path that sets a choice or data that later steps use includes a step that saves it. Each use case lists only the actors that act in it.

**Actors used across this document**
- Business Owner: the person who signs in to inform9.com to request and manage W-9s.
- Payee: the contractor or vendor who completes a W-9.
- inform9 Platform: the web service, storage, and notification logic behind inform9.com.
- Email Service: the third-party service that delivers email.
- Payment Processor: the third-party service that handles paid plan payments.
- Administrator: the inform9 administrator, who sets platform-wide limits and reviews abuse flags. This is an internal role. Customers never see these screens.
- Business Recipient: the person at a business who receives a W-9 that a Payee sent on their own. They may have no inform9 account, and they become a Business Owner when they save the W-9 to an account.

**Decisions applied**
- The free plan includes up to 3 payees.
- A Payee approves each share of saved information with a business. inform9 never sends it automatically.
- Each business holds its own signed copy of a W-9, and earlier versions are kept.
- The Business Owner is notified by email when a Payee completes or updates a W-9.
- An updated W-9 goes only to the businesses the Payee selects. The Payee sees the list of businesses that hold a past W-9 and checks the ones to update, or selects all.
- Each Business Owner account holds one payee record per payee. The free plan allows up to 3 payee records per account, however many of the account's businesses the payee is linked to.
- A Payee with a saved W-9 can send it to a business without waiting for a request. The Business Recipient verifies their email address with a one-time code before seeing anything.
- A Business Recipient can download a payee-sent W-9 more than once, without an account, from any number of Payees. The link expires after a period an Administrator sets, up to 7 days. Each link allows 3 to 5 downloads in 24 hours, also set by an Administrator. inform9 logs every download for reporting. Downloads do not count toward the plan limit.
- Storing and managing a payee-sent W-9 requires an inform9 account. A saved W-9 adds a payee to the account and counts toward the 3-payee limit like any other payee. This invites businesses to create a free account and upgrade when they need more.
- Link expiry and the daily download cap are set by the inform9 administrator and apply only to links sent after a change. The first release may use environment variables, and an administrator screen is the target.
- A Business Owner can export payee data as a file for QuickBooks Online, Xero, or general use, or as a ZIP of W-9 PDFs. The taxpayer ID is masked by default, and a full taxpayer ID requires the Business Owner to re-enter their password.
- Business Owners and Payees can check an unchecked box when creating an account to receive updates and information about inform9 products and services. They can change it later. Request, reminder, notice, and receipt emails do not depend on it.
- Opt-out links in payee-sent emails never expire.
- Payee-initiated sends are limited by send caps and recipient opt-outs, and recipients can report unwanted or misdirected sends.
- inform9 reminds a Payee about an open request by default: every 7 days, up to 3 reminders. A Business Owner can change the interval (3 to 30 days) and the cap (up to 6) for a business or a single request.
- A Payee receives at most one reminder email per day, even with open requests from several businesses.
- Reminders stop when the Payee completes, declines, says they are the wrong recipient, or stops reminders, when the Business Owner cancels the request, when the email bounces, or when the cap is reached.
- Only paid plans can change the reminder schedule. The free plan uses the default.
- The free plan includes one business. A paid plan raises the limit to [PAID_BUSINESS_LIMIT].
- Plan prices and the paid limits [PAID_LIMIT] and [PAID_BUSINESS_LIMIT] are settings, and they stay open until after the beta.
- One email address has one account. The same account can manage businesses as a Business Owner and keep saved W-9 information as a Payee.
- The portal shows five request statuses: Not requested, Sent, Delivery failed, Declined, and Completed. A request whose reminders ended shows Sent with the note "Reminders ended". A request where the Payee said they are not the right person shows Declined with the reason "Not the right person". A request where the Payee is not a U.S. person shows Declined with the reason "Foreign payee". A request the Business Owner canceled shows the payee as Not requested.
- The request email and every reminder email include a Decline option and an "I am not the right person" option. Every reminder email also includes a Stop reminders option.
- The Payee is told that a reason for declining is shared with the Business Owner. The reason is optional.
- A Business Owner can resend a request up to [MAX_RESENDS] times. Each resend resets the reminder count.
- A Business Owner can cancel an open request. inform9 does not notify the Payee.
- A Business Owner can archive a payee. An archived payee does not count toward the plan limit, and its completed W-9s stay available.
- A request can list several businesses. The Payee completes the form once, and each business receives its own signed W-9 that shows that business as the requester.
- Downloading a W-9 PDF asks the Business Owner for their password once per sign-in session. Exporting a ZIP of W-9 PDFs asks for the password on every export.

**Out of scope for the first release**
- Connect to inform9 systems. For now, a Business Owner downloads a W-9 and attaches it manually, for example to a ServicePro contact in TenantCloud. Later integrations with TenantCloud and ZipBooks are possible.
- Foreign payee forms (W-8 series), 1099 preparation or filing, taxpayer ID matching, and direct accounting software integrations. A file export for accounting tools is in scope. See Export Payee Data.

**Use cases**
1. [Create Account and Sign In](#use-case-create-account-and-sign-in)
2. [Reset Password](#use-case-reset-password)
3. [Add Business](#use-case-add-business)
4. [Add Payee Contact](#use-case-add-payee-contact)
5. [Request W-9](#use-case-request-w-9)
6. [Complete and Sign W-9](#use-case-complete-and-sign-w-9)
7. [Create Payee Account](#use-case-create-payee-account)
8. [Confirm and Reuse Saved Payee Information](#use-case-confirm-and-reuse-saved-payee-information)
9. [Payee Declines Request](#use-case-payee-declines-request)
10. [View and Download W-9s](#use-case-view-and-download-w-9s)
11. [Follow Up on Incomplete Request](#use-case-follow-up-on-incomplete-request)
12. [Update a W-9](#use-case-update-a-w-9)
13. [Upgrade After Free Limit](#use-case-upgrade-after-free-limit)
14. [Cancel Account and Data Handling](#use-case-cancel-account-and-data-handling)
15. [Payee Sends W-9 to Business](#use-case-payee-sends-w-9-to-business)
16. [Business Recipient Retrieves Payee-Sent W-9](#use-case-business-recipient-retrieves-payee-sent-w-9)
17. [Save Payee-Sent W-9 to Account](#use-case-save-payee-sent-w-9-to-account)
18. [Limit Unsolicited Sends](#use-case-limit-unsolicited-sends)
19. [Opt Out of Payee-Sent W-9s](#use-case-opt-out-of-payee-sent-w-9s)
20. [Send W-9 Reminders](#use-case-send-w-9-reminders)
21. [Set Reminder Schedule](#use-case-set-reminder-schedule)
22. [Configure Platform Settings](#use-case-configure-platform-settings)
23. [Export Payee Data](#use-case-export-payee-data)
24. [Manage Communication Preferences](#use-case-manage-communication-preferences)
25. [Cancel Request](#use-case-cancel-request)
26. [Edit or Archive Payee](#use-case-edit-or-archive-payee)
27. [Edit Business](#use-case-edit-business)
28. [Review Abuse Flags](#use-case-review-abuse-flags)
29. [Sign Out](#use-case-sign-out)
30. [View Sent W-9s](#use-case-view-sent-w-9s)

---

## Use Case: Create Account and Sign In

A Business Owner creates an inform9 account and signs in so they can request and manage W-9s.

**Assumptions**
- The Business Owner has a working email address.
- inform9.com is available.

**Actors**
- Business Owner: person creating the account or signing in.
- inform9 Platform: validates the entries and creates, verifies, and activates the account.
- Email Service: delivers the verification email.

**Trigger(s)**
- The Business Owner visits inform9.com and chooses to sign up.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Enters name, email address, and password |
| 2. | Business Owner | Chooses whether to check the box to receive updates and information about inform9 products and services |
| 3. | inform9 Platform | Validates the entries |
| 4. | inform9 Platform | Creates a pending account with the update preference as chosen |
| 5. | Email Service | Delivers a verification email containing a link |
| 6. | Business Owner | Clicks the verification link |
| 7. | inform9 Platform | Activates the account |
| 8. | inform9 Platform | Signs the Business Owner in |
| 9. | inform9 Platform | Prompts the Business Owner to add a first business |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A1 (from Basic Path #1): The Business Owner already has an account
  - A1.1 **Business Owner:** Enters email address and password for the existing account.
  - A1.2 **inform9 Platform:** Validates the credentials.
  - A1.3 **inform9 Platform:** Signs the **Business Owner** in.
  - A1.4 End of use case.

**Exception Paths**

- Exception Path E1 (from Basic Path #1): The credentials entered for an existing account are wrong
  - E1.1 **Business Owner:** Enters an email address and password that do not match an account.
  - E1.2 **inform9 Platform:** Shows a message that the email address or password is incorrect, without saying which.
  - E1.3 **inform9 Platform:** Counts the failed attempt against the email address entered.
  - E1.4 **inform9 Platform:** Locks sign-in for that email address for [LOCK_MINUTES] minutes after [MAX_SIGNIN_ATTEMPTS] failed attempts.
  - E1.5 Use case continues at Basic Path #1.

- Exception Path E3 (from Basic Path #3): The email address is already registered
  - E3.1 **inform9 Platform:** Finds that the email address is already registered.
  - E3.2 **inform9 Platform:** Shows a message with links to sign in or [reset the password](#use-case-reset-password).
  - E3.3 End of use case.

- Exception Path E6 (from Basic Path #6): The verification link has expired
  - E6.1 **Business Owner:** Clicks a verification link that has expired.
  - E6.2 **inform9 Platform:** Offers to send a new verification email.
  - E6.3 **Business Owner:** Accepts.
  - E6.4 **inform9 Platform:** Issues a new verification link and saves it with the pending account.
  - E6.5 Use case continues at Basic Path #5.

**Post-Condition(s)**
- **Basic Path exit:** An account record exists with status Active and email verified. The Business Owner has an authenticated session. The account holds the update preference as chosen, unchecked unless the Business Owner checked the box.
- **Alternate Path A1 exit:** An authenticated session exists for the existing account. No new account record was created.
- **Exception Path E3 exit:** No new account record exists and no session was created.
- **Exception Path E6 exit:** A new verification link is saved with the pending account, and the use case continues at Basic Path #5.
- **Exception Path E1 exit:** No session was created, the failed attempt is counted, sign-in is locked once the attempt limit is reached, and the use case continues at Basic Path #1.

**Open Issues/Notes**
- The update box is unchecked by default. The Business Owner can change the preference later. See [Use Case: Manage Communication Preferences](#use-case-manage-communication-preferences).
- Password rules and whether to require multi-factor sign-in. The platform stores sensitive tax information, so this deserves a decision before launch.
- Sign in with Google is the only single sign-on option planned. It is not in the first release, and an Administrator will turn it on in the platform settings. No use case is written yet.
- One email address has one account. The same account holds the Business Owner role and the Payee role, so this use case, [Use Case: Create Payee Account](#use-case-create-payee-account), and [Use Case: Reset Password](#use-case-reset-password) all work on that account.

---

## Use Case: Reset Password

A Business Owner who cannot sign in resets their password using a link sent by email.

**Assumptions**
- The Business Owner has an active account.

**Actors**
- Business Owner: person resetting the password.
- inform9 Platform: issues the reset link and updates the password.
- Email Service: delivers the reset email.

**Trigger(s)**
- The Business Owner selects "Forgot password" on the sign-in page.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Enters their email address |
| 2. | inform9 Platform | Creates a time-limited reset link |
| 3. | inform9 Platform | Shows a confirmation message |
| 4. | Email Service | Delivers the reset email |
| 5. | Business Owner | Clicks the reset link |
| 6. | inform9 Platform | Shows a form for a new password |
| 7. | Business Owner | Enters and confirms a new password |
| 8. | inform9 Platform | Updates the password |
| 9. | inform9 Platform | Ends other active sessions |
| 10. | inform9 Platform | Confirms the change |
| | | END OF USE CASE |

**Alternate Paths**

- No alternate paths identified for this use case.

**Exception Paths**

- Exception Path E2 (from Basic Path #2): No account uses the email address
  - E2.1 **inform9 Platform:** Finds no account for the email address.
  - E2.2 **inform9 Platform:** Shows the same confirmation message and sends no email.
  - E2.3 End of use case.

- Exception Path E5 (from Basic Path #5): The reset link has expired
  - E5.1 **Business Owner:** Clicks a reset link that has expired.
  - E5.2 **inform9 Platform:** Offers to send a new link.
  - E5.3 **Business Owner:** Accepts.
  - E5.4 **inform9 Platform:** Creates a new time-limited reset link for the same account.
  - E5.5 Use case continues at Basic Path #4.

**Post-Condition(s)**
- **Basic Path exit:** The account password is changed. Prior sessions are ended. The used reset link is invalid.
- **Exception Path E2 exit:** No email was sent and no account data changed.
- **Exception Path E5 exit:** A new time-limited reset link exists for the same account, the password is unchanged, and the use case continues at Basic Path #4.

**Open Issues/Notes**
- Payee accounts use the same flow.
- Reset link lifetime: [RESET_LINK_HOURS].

---

## Use Case: Add Business

A Business Owner adds a business to the account so W-9s can be requested and stored for it.

**Assumptions**
- The Business Owner is signed in.
- The account has fewer businesses than the plan limit (1 on the free plan).

**Actors**
- Business Owner: person adding the business.
- inform9 Platform: validates and stores the business record.

**Trigger(s)**
- The Business Owner chooses to add a business.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Selects Add Business |
| 2. | inform9 Platform | Shows the business form |
| 3. | Business Owner | Enters the business name, address, and notification email |
| 4. | inform9 Platform | Checks that required fields are complete and that the account is within the plan limit for businesses |
| 5. | inform9 Platform | Saves the business with the default reminder schedule (every 7 days, up to 3 reminders) |
| 6. | inform9 Platform | Shows the business in the business list |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A6 (from Basic Path #6): The Business Owner adds another business
  - A6.1 **Business Owner:** Selects Add Business again.
  - A6.2 Use case continues at Basic Path #2.

**Exception Paths**

- Exception Path E4a (from Basic Path #4): A required field is empty
  - E4a.1 **inform9 Platform:** Finds a required field empty.
  - E4a.2 **inform9 Platform:** Highlights the missing fields.
  - E4a.3 Use case continues at Basic Path #3.

- Exception Path E4b (from Basic Path #4): A business with the same name already exists in the account
  - E4b.1 **inform9 Platform:** Finds a business with the same name in the account.
  - E4b.2 **inform9 Platform:** Shows a message that each business needs its own distinct legal name.
  - E4b.3 Use case continues at Basic Path #3.

- Exception Path E4c (from Basic Path #4): The account is at the plan limit for businesses
  - E4c.1 **inform9 Platform:** Finds that the account is at the plan limit for businesses.
  - E4c.2 **inform9 Platform:** Explains the limit.
  - E4c.3 **inform9 Platform:** Offers an upgrade.
  - E4c.4 **Business Owner:** Chooses to upgrade, or closes the message.
  - E4c.5 End of use case. If the **Business Owner** chose to upgrade, they continue at [Use Case: Upgrade After Free Limit](#use-case-upgrade-after-free-limit).

**Post-Condition(s)**
- **Basic Path exit:** A business record exists in the account with the entered name, address, and notification email, and with a reminder schedule of every 7 days and up to 3 reminders.
- **Exception Path E4a exit:** No business record was created.
- **Alternate Path A6 exit:** The business from the Basic Path exists, and the use case restarts at Basic Path #2 for another business.
- **Exception Path E4b exit:** No business record was created, and the use case continues at Basic Path #3.
- **Exception Path E4c exit:** No business record was created and the business count is unchanged.

**Open Issues/Notes**
- Required fields. The requester name and address appear on the W-9 shown to payees.
- The free plan allows one business. A paid plan raises the limit to [PAID_BUSINESS_LIMIT].
- To change a business after it is saved, see [Use Case: Edit Business](#use-case-edit-business).
- To change a business's reminder schedule, see [Use Case: Set Reminder Schedule](#use-case-set-reminder-schedule).

---

## Use Case: Add Payee Contact

A Business Owner creates a payee contact linked to one or more businesses so a W-9 can be requested from them.

**Assumptions**
- The Business Owner is signed in and has added at least one business.
- The account has fewer active payees than the plan limit (3 on the free plan). Archived payees do not count.

**Actors**
- Business Owner: person adding the payee.
- inform9 Platform: stores the payee contact and checks the plan limit.

**Trigger(s)**
- The Business Owner chooses to add a payee.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Selects Add Payee |
| 2. | inform9 Platform | Shows the payee form with the list of businesses |
| 3. | Business Owner | Enters the payee name and email address |
| 4. | Business Owner | Selects one or more businesses to link |
| 5. | inform9 Platform | Checks the payee count against the plan limit |
| 6. | inform9 Platform | Validates the entries and checks for an existing payee with the same email address |
| 7. | inform9 Platform | Saves the payee contact |
| 8. | inform9 Platform | Shows the payee in the payee list with status Not requested |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A8 (from Basic Path #8): The Business Owner chooses to send a request now
  - A8.1 **Business Owner:** Selects Send Request for the new payee.
  - A8.2 **inform9 Platform:** Starts [Use Case: Request W-9](#use-case-request-w-9) for the payee's linked businesses.
  - A8.3 End of use case.

**Exception Paths**

- Exception Path E5 (from Basic Path #5): The account is at the plan limit
  - E5.1 **inform9 Platform:** Finds that the account is at the plan limit.
  - E5.2 **inform9 Platform:** Explains the limit.
  - E5.3 **inform9 Platform:** Offers an upgrade.
  - E5.4 **Business Owner:** Chooses to upgrade, or closes the message.
  - E5.5 End of use case. If the **Business Owner** chose to upgrade, they continue at [Use Case: Upgrade After Free Limit](#use-case-upgrade-after-free-limit).

- Exception Path E6 (from Basic Path #6): A payee with the same email address already exists in the account
  - E6.1 **inform9 Platform:** Finds an existing payee with the same email address.
  - E6.2 **inform9 Platform:** Shows the existing payee.
  - E6.3 **inform9 Platform:** Offers to link the additional businesses to the existing payee.
  - E6.4 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** A payee contact exists with the entered name, email, and linked businesses, and counts toward the plan limit.
- **Alternate Path A8 exit:** The payee contact exists as in the Basic Path exit, and the request flow has started.
- **Exception Path E5 exit:** No payee contact was created and the payee count is unchanged.
- **Exception Path E6 exit:** No new payee contact was created.

**Open Issues/Notes**
- A payee linked to several businesses is one payee record in the account and counts once toward the plan limit.
- Whether bulk import of payees is wanted later.
- To change or archive a payee, see [Use Case: Edit or Archive Payee](#use-case-edit-or-archive-payee).
- A payee contact is also created when a Business Recipient saves a payee-sent W-9. See [Use Case: Save Payee-Sent W-9 to Account](#use-case-save-payee-sent-w-9-to-account).

---

## Use Case: Request W-9

inform9 emails a payee a secure link so they can complete a W-9 for one or more of the Business Owner's businesses.

**Assumptions**
- A payee contact exists with a valid email address and at least one linked business.

**Actors**
- Business Owner: person requesting the W-9.
- inform9 Platform: creates the request, secure link, and reminder schedule.
- Email Service: delivers the request email.

**Trigger(s)**
- The Business Owner chooses Send Request for a payee.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Selects a payee and the businesses to request the W-9 for |
| 2. | Business Owner | Selects Send Request |
| 3. | inform9 Platform | Checks for an open request for the same payee and business |
| 4. | inform9 Platform | Creates a request record that lists the selected business, has a unique, time-limited secure link and status Sent, and includes the reminder override if one was saved |
| 5. | inform9 Platform | Schedules reminders using the reminder override on the request, or the business reminder schedule if there is no override |
| 6. | Email Service | Delivers an email to the payee that names each business on the request and contains the link, a Decline option, and an "I am not the right person" option |
| 7. | inform9 Platform | Records the delivery result |
| 8. | inform9 Platform | Shows the request as Sent to the Business Owner |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Business Owner changes the reminder schedule for this request
  - A2.1 **Business Owner:** Enters the days between reminders and the maximum number of reminders for this request.
  - A2.2 **inform9 Platform:** Checks the values against the allowed limits. See [Use Case: Set Reminder Schedule](#use-case-set-reminder-schedule).
  - A2.3 **inform9 Platform:** Saves the values as the reminder override on the pending request.
  - A2.4 Use case continues at Basic Path #3.

- Alternate Path A4 (from Basic Path #4): The Business Owner selected more than one business
  - A4.1 **inform9 Platform:** Creates one request record that lists every selected business, has a unique, time-limited secure link and status Sent, and includes the reminder override if one was saved.
  - A4.2 Use case continues at Basic Path #5.

**Exception Paths**

- Exception Path E3 (from Basic Path #3): An open request already exists for the same payee and business
  - E3.1 **inform9 Platform:** Finds an open request for the same payee and business.
  - E3.2 **inform9 Platform:** Warns the **Business Owner**.
  - E3.3 **inform9 Platform:** Offers to resend the existing request.
  - E3.4 End of use case. The **Business Owner** continues at [Use Case: Follow Up on Incomplete Request](#use-case-follow-up-on-incomplete-request).

- Exception Path E6 (from Basic Path #6): The email bounces
  - E6.1 **Email Service:** Reports that the email bounced.
  - E6.2 **inform9 Platform:** Marks the request Delivery failed.
  - E6.3 **inform9 Platform:** Cancels the scheduled reminders.
  - E6.4 **inform9 Platform:** Notifies the **Business Owner**.
  - E6.5 End of use case. The **Business Owner** continues at [Use Case: Follow Up on Incomplete Request](#use-case-follow-up-on-incomplete-request).

**Post-Condition(s)**
- **Basic Path exit:** A request record exists with status Sent, the selected business, a secure link, and an expiration date. An email was delivered to the payee. Reminders are scheduled with the interval and cap in effect for the request.
- **Alternate Path A4 exit:** One request record lists every selected business. The payee's single submission is saved to each listed business.
- **Exception Path E3 exit:** No new request record was created.
- **Exception Path E6 exit:** The request status is Delivery failed, no reminders are scheduled, and the Business Owner was notified.
- **Alternate Path A2 exit:** The pending request holds the entered interval and cap as its reminder override, and the use case continues at Basic Path #3.

**Open Issues/Notes**
- Link lifetime: [REQUEST_LINK_DAYS]. With the default reminders, the last reminder goes out on day 21, so the link should stay valid at least 30 days.
- Whether the email shows inform9 as sender on behalf of the business.
- The Decline and "I am not the right person" options in the email lead to [Use Case: Payee Declines Request](#use-case-payee-declines-request).
- To cancel an open request, see [Use Case: Cancel Request](#use-case-cancel-request).

---

## Use Case: Complete and Sign W-9

A Payee opens a request link, completes and signs a W-9 online, and inform9 stores it under the requesting business or businesses.

**Assumptions**
- The Payee received a request email containing a valid link.
- The Payee has no inform9 account, or chooses to complete the form manually.

**Actors**
- Payee: person completing the W-9.
- inform9 Platform: validates, stores, and notifies.
- Email Service: delivers confirmation and notices.

**Trigger(s)**
- The Payee clicks the link in a request email.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Opens the link from the email |
| 2. | inform9 Platform | Validates the link |
| 3. | inform9 Platform | Shows the W-9 form with the name and address of each requesting business filled in |
| 4. | Payee | Enters name, business name if different, federal tax classification, address, and taxpayer identification number |
| 5. | inform9 Platform | Checks the entries for completeness and format |
| 6. | Payee | Reviews the entries and certifies them |
| 7. | Payee | Signs electronically |
| 8. | inform9 Platform | Generates a completed W-9 for each business on the request, with that business shown as the requester |
| 9. | inform9 Platform | Stores each W-9 securely under its business |
| 10. | inform9 Platform | Marks the request Completed |
| 11. | inform9 Platform | Cancels the scheduled reminders |
| 12. | Email Service | Delivers a confirmation email to the Payee |
| 13. | Email Service | Delivers a completion notice to the Business Owner |
| 14. | inform9 Platform | Offers the Payee the option to create an account to save their information |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Payee already has an inform9 account
  - A2.1 **inform9 Platform:** Finds an inform9 account for the **Payee**'s email address.
  - A2.2 **inform9 Platform:** Prompts the **Payee** to sign in.
  - A2.3 End of use case. The **Payee** continues at [Use Case: Confirm and Reuse Saved Payee Information](#use-case-confirm-and-reuse-saved-payee-information).

- Alternate Path A3 (from Basic Path #3): The Payee chooses to decline
  - A3.1 **Payee:** Chooses Decline instead of completing the form.
  - A3.2 End of use case. The **Payee** continues at [Use Case: Payee Declines Request](#use-case-payee-declines-request).

- Alternate Path A4 (from Basic Path #4): The Payee is not a U.S. person
  - A4.1 **Payee:** Selects "I am not a U.S. person."
  - A4.2 **inform9 Platform:** Explains that inform9 collects the W-9 only and cannot collect a W-8 form.
  - A4.3 **Payee:** Confirms.
  - A4.4 **inform9 Platform:** Marks the request Declined with the reason "Foreign payee".
  - A4.5 **inform9 Platform:** Cancels the scheduled reminders.
  - A4.6 **inform9 Platform:** Deactivates the link.
  - A4.7 **Email Service:** Delivers a decline notice to the Business Owner that includes the reason.
  - A4.8 End of use case.

- Alternate Path A14 (from Basic Path #14): The Payee chooses to create an account
  - A14.1 **Payee:** Chooses to create an account.
  - A14.2 End of use case. The **Payee** continues at [Use Case: Create Payee Account](#use-case-create-payee-account).

**Exception Paths**

- Exception Path E2 (from Basic Path #2): The link is invalid, used, or expired
  - E2.1 **inform9 Platform:** Finds the link invalid, used, or expired.
  - E2.2 **inform9 Platform:** Shows a message telling the **Payee** to ask the business for a new request.
  - E2.3 End of use case.

- Exception Path E5 (from Basic Path #5): An entry is missing or has an invalid format
  - E5.1 **inform9 Platform:** Finds an entry missing or in an invalid format.
  - E5.2 **inform9 Platform:** Highlights the fields to correct.
  - E5.3 Use case continues at Basic Path #4.

- Exception Path E9 (from Basic Path #9): Storage fails
  - E9.1 **inform9 Platform:** Finds that the W-9 could not be stored.
  - E9.2 **inform9 Platform:** Shows the **Payee** an error and keeps the entries on screen.
  - E9.3 **inform9 Platform:** Raises an alert for the inform9 administrator.
  - E9.4 Use case continues at Basic Path #6.

**Post-Condition(s)**
- **Basic Path exit:** A W-9 record exists under each business on the request with the Payee's entries, electronic signature, and timestamp. Each record shows its own business as the requester. The request status is Completed and no reminders are scheduled. The Business Owner and Payee were notified by email.
- **Exception Path E2 exit:** No W-9 record was created and the request status is unchanged.
- **Alternate Path A2 exit:** No W-9 record was created, the Payee is prompted to sign in, and the Payee continues at Confirm and Reuse Saved Payee Information.
- **Alternate Path A3 exit:** No W-9 record was created, and the Payee continues at Payee Declines Request.
- **Alternate Path A4 exit:** The request status is Declined with the reason "Foreign payee", the link is inactive, no reminders are scheduled, no W-9 record was created, and the Business Owner was notified.
- **Alternate Path A14 exit:** The Basic Path post-conditions hold, and the Payee continues at Create Payee Account.
- **Exception Path E5 exit:** No W-9 record was created, the fields to correct are highlighted, and the use case continues at Basic Path #4.
- **Exception Path E9 exit:** No W-9 record was created, the request status is unchanged, the Payee's entries remain on screen, an alert was raised for the inform9 administrator, and the use case continues at Basic Path #6.

**Open Issues/Notes**
- IRS conditions for electronic W-9 signature and certification need legal review.
- Whether a Payee can save partial progress.
- Which signature details to record, such as time and IP address.

---

## Use Case: Create Payee Account

A Payee creates an inform9 account to save their W-9 information for future requests.

**Assumptions**
- The Payee has completed a W-9 in the current session.

**Actors**
- Payee: person creating the account.
- inform9 Platform: creates and verifies the account and stores saved information.
- Email Service: delivers the verification email.

**Trigger(s)**
- The Payee chooses to save their information after completing a W-9.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Selects Create account |
| 2. | inform9 Platform | Shows an account form with the Payee's email address filled in |
| 3. | Payee | Enters a password |
| 4. | Payee | Accepts the terms |
| 5. | Payee | Chooses whether to check the box to receive updates and information about inform9 products and services |
| 6. | inform9 Platform | Creates a pending account with the update preference as chosen |
| 7. | Email Service | Delivers a verification email |
| 8. | Payee | Clicks the verification link |
| 9. | inform9 Platform | Activates the account |
| 10. | inform9 Platform | Saves the submitted W-9 information to the account |
| | | END OF USE CASE |

**Alternate Paths**

- No alternate paths identified for this use case.

**Exception Paths**

- Exception Path E6 (from Basic Path #6): An account already exists for the email address
  - E6.1 **inform9 Platform:** Finds an account for the email address, either a Business Owner account or a Payee account.
  - E6.2 **inform9 Platform:** Asks the **Payee** to sign in.
  - E6.3 **inform9 Platform:** Offers to save the information to that account.
  - E6.4 End of use case.

- Exception Path E8 (from Basic Path #8): The verification link has expired
  - E8.1 **Payee:** Clicks a verification link that has expired.
  - E8.2 **inform9 Platform:** Offers to send a new link.
  - E8.3 **Payee:** Accepts.
  - E8.4 **inform9 Platform:** Issues a new verification link and saves it with the pending account.
  - E8.5 Use case continues at Basic Path #7.

**Post-Condition(s)**
- **Basic Path exit:** An active Payee account exists, and the submitted W-9 information is stored in it. The completed W-9 remains stored under each business. The account holds the update preference as chosen, unchecked unless the Payee checked the box.
- **Exception Path E6 exit:** No new account was created.
- **Exception Path E8 exit:** A new verification link is saved with the pending account, and the use case continues at Basic Path #7.

**Open Issues/Notes**
- Whether saved information is one profile or several, since a Payee may use different tax identities for different businesses.
- One email address has one account. A person who already has a Business Owner account adds saved W-9 information to that account.
- Payee account passwords and multi-factor sign-in need the same decision as Business Owner accounts.
- A Payee needs an account with saved information to send a W-9 on their own. See [Use Case: Payee Sends W-9 to Business](#use-case-payee-sends-w-9-to-business).

---

## Use Case: Confirm and Reuse Saved Payee Information

A Payee with a saved account responds to a new request by reviewing saved information and approving it with one click.

**Assumptions**
- The Payee has an active account with saved W-9 information.
- A new request email was delivered to the Payee.

**Actors**
- Payee: person approving the share.
- inform9 Platform: verifies the Payee, generates the W-9, and stores it.
- Email Service: delivers confirmation and notices.

**Trigger(s)**
- The Payee clicks the link in a request email.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Opens the link from the email |
| 2. | inform9 Platform | Validates the link |
| 3. | inform9 Platform | Requires the Payee to sign in before showing any saved information |
| 4. | Payee | Signs in |
| 5. | inform9 Platform | Shows the request, the businesses on the request, and the saved W-9 information |
| 6. | Payee | Reviews the information |
| 7. | Payee | Approves sending it to the businesses with one click |
| 8. | inform9 Platform | Generates a W-9 for each business on the request from the saved information as approved, including any edits saved on this request |
| 9. | inform9 Platform | Stores each W-9 under its business |
| 10. | inform9 Platform | Marks the request Completed |
| 11. | inform9 Platform | Cancels the scheduled reminders |
| 12. | Email Service | Delivers a confirmation email to the Payee |
| 13. | Email Service | Delivers a completion notice to the Business Owner |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A6 (from Basic Path #6): The Payee edits the information before approving
  - A6.1 **Payee:** Changes one or more fields.
  - A6.2 **inform9 Platform:** Validates the changes.
  - A6.3 **inform9 Platform:** Saves the changes to the **Payee**'s saved information.
  - A6.4 Use case continues at Basic Path #6.

- Alternate Path A7 (from Basic Path #7): The Payee declines
  - A7.1 **Payee:** Declines instead of approving.
  - A7.2 End of use case. The **Payee** continues at [Use Case: Payee Declines Request](#use-case-payee-declines-request).

**Exception Paths**

- Exception Path E2 (from Basic Path #2): The link is invalid, used, or expired
  - E2.1 **inform9 Platform:** Finds the link invalid, used, or expired.
  - E2.2 **inform9 Platform:** Shows a message telling the **Payee** to ask the business for a new request.
  - E2.3 End of use case.

- Exception Path E4 (from Basic Path #4): The Payee cannot sign in
  - E4.1 **Payee:** Cannot sign in.
  - E4.2 **inform9 Platform:** Offers [password reset](#use-case-reset-password).
  - E4.3 End of use case.

- Exception Path E5 (from Basic Path #5): Saved information is incomplete
  - E5.1 **inform9 Platform:** Finds that required fields are missing from the saved information.
  - E5.2 **inform9 Platform:** Shows the missing fields and withholds the approval option until they are complete.
  - E5.3 **Payee:** Enters the missing information.
  - E5.4 **inform9 Platform:** Validates the entries.
  - E5.5 **inform9 Platform:** Saves the entries to the **Payee**'s saved information.
  - E5.6 Use case continues at Basic Path #6.

**Post-Condition(s)**
- **Basic Path exit:** A W-9 record exists under each business on the request with the approved information and an approval timestamp. The request status is Completed and no reminders are scheduled. Both parties were notified.
- **Alternate Path A6 exit:** The saved information holds the edited values, and the Basic Path post-conditions also hold.
- **Exception Path E2 and E4 exits:** No W-9 record was created and the request status is unchanged.
- **Alternate Path A7 exit:** Nothing was shared with the business, and the Payee continues at Payee Declines Request.
- **Exception Path E5 exit:** Approval was not available until all required fields were complete, the saved information holds the entered values, and the use case continues at Basic Path #6.

**Open Issues/Notes**
- Whether a one-click approval meets IRS signature and certification conditions. Review with legal counsel.
- Whether saved information must be reconfirmed after [REVALIDATION_PERIOD].
- The sign-in step protects against anyone reaching saved information through an email link alone.

---

## Use Case: Payee Declines Request

A Payee declines a W-9 request so the Business Owner knows the form will not be provided.

**Assumptions**
- The Payee received a request email containing a valid link.

**Actors**
- Payee: person declining.
- inform9 Platform: records the decision.
- Email Service: delivers the notice.

**Trigger(s)**
- The Payee opens a request link and chooses Decline.
- The Payee chooses Decline or "I am not the right person" in a request or reminder email.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Opens the request link |
| 2. | Payee | Selects Decline |
| 3. | inform9 Platform | Asks the Payee for an optional reason and says the reason is shared with the Business Owner |
| 4. | Payee | Enters a reason or leaves it blank |
| 5. | Payee | Confirms the decline |
| 6. | inform9 Platform | Marks the request Declined and saves the reason if one was entered |
| 7. | inform9 Platform | Cancels the scheduled reminders |
| 8. | inform9 Platform | Deactivates the link |
| 9. | Email Service | Delivers a decline notice to the Business Owner, including the reason if one was saved |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Payee selects "I am not the right person"
  - A2.1 **Payee:** Selects "I am not the right person" instead of Decline.
  - A2.2 **inform9 Platform:** Marks the request Declined with the reason "Not the right person".
  - A2.3 **inform9 Platform:** Cancels the scheduled reminders.
  - A2.4 **inform9 Platform:** Deactivates the link.
  - A2.5 **Email Service:** Delivers a notice to the Business Owner that the Payee is not the right person.
  - A2.6 End of use case.

- Alternate Path A3 (from Basic Path #3): The Payee changes their mind
  - A3.1 **Payee:** Closes the decline page.
  - A3.2 End of use case. The request stays open.

**Exception Paths**

- Exception Path E1 (from Basic Path #1): The link is invalid, used, or expired
  - E1.1 **inform9 Platform:** Finds the link invalid, used, or expired.
  - E1.2 **inform9 Platform:** Shows a message telling the **Payee** to ask the business for a new request.
  - E1.3 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** The request status is Declined, the link is inactive, no reminders are scheduled, no W-9 record was created, and the Business Owner was notified.
- **Alternate Path A2 exit:** The request status is Declined with the reason "Not the right person", the link is inactive, no reminders are scheduled, no W-9 record was created, and the Business Owner was notified.
- **Alternate Path A3 exit:** The request status is unchanged.
- **Exception Path E1 exit:** No request data changed.

**Open Issues/Notes**
- Whether a Declined payee still counts toward the plan limit. By default the payee contact still counts.

---

## Use Case: View and Download W-9s

A Business Owner reviews payees and their W-9 status by business and downloads completed forms.

**Assumptions**
- The Business Owner is signed in and has at least one payee.

**Actors**
- Business Owner: person reviewing and downloading.
- inform9 Platform: shows records and delivers files.

**Trigger(s)**
- The Business Owner opens the payee list.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens the payee list for a business |
| 2. | inform9 Platform | Shows each payee with a status (Not requested, Sent, Delivery failed, Declined, Completed), a Reminders ended note beside Sent where reminders ended, the reason beside Declined where one exists, and an Updated marker where a newer W-9 was added |
| 3. | Business Owner | Selects a payee |
| 4. | inform9 Platform | Shows the payee details with each W-9 version and its date |
| 5. | Business Owner | Selects Download for a version |
| 6. | inform9 Platform | Checks the Business Owner's access and whether the password was confirmed in this sign-in session |
| 7. | inform9 Platform | Delivers the W-9 as a PDF file |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Business Owner switches business or applies a status filter
  - A2.1 **Business Owner:** Selects a different business or a status filter.
  - A2.2 **inform9 Platform:** Saves the selection as the current view.
  - A2.3 **inform9 Platform:** Refreshes the list for the current view.
  - A2.4 Use case continues at Basic Path #3.

- Alternate Path A6 (from Basic Path #6): The password was not confirmed in this sign-in session
  - A6.1 **inform9 Platform:** Explains that the PDF shows the full taxpayer ID and asks the **Business Owner** to enter their password.
  - A6.2 **Business Owner:** Enters their password.
  - A6.3 **inform9 Platform:** Verifies the password.
  - A6.4 **inform9 Platform:** Saves the password confirmation with the sign-in session.
  - A6.5 Use case continues at Basic Path #7.

**Exception Paths**

- Exception Path E6 (from Alternate Path A6, step A6.3): The password is wrong
  - E6.1 **inform9 Platform:** Finds that the password is wrong.
  - E6.2 **inform9 Platform:** Shows an error and delivers no file.
  - E6.3 **inform9 Platform:** Counts the failed attempt toward the sign-in attempt limit. See [Use Case: Create Account and Sign In](#use-case-create-account-and-sign-in).
  - E6.4 Use case continues at Basic Path #5.

- Exception Path E7 (from Basic Path #7): The W-9 file is unavailable
  - E7.1 **inform9 Platform:** Cannot find the stored file for the selected version.
  - E7.2 **inform9 Platform:** Shows the **Business Owner** an error and offers to try again.
  - E7.3 **inform9 Platform:** Raises an alert for the inform9 administrator.
  - E7.4 Use case continues at Basic Path #5.

**Post-Condition(s)**
- **Basic Path exit:** The downloaded file matches the stored version. No records changed.
- **Exception Path E7 exit:** No file was delivered, no records changed, an alert was raised for the inform9 administrator, and the use case continues at Basic Path #5.
- **Alternate Path A2 exit:** The selected business or status filter is saved as the current view, and the list shows that view.
- **Alternate Path A6 exit:** The password confirmation is saved with the sign-in session, and the use case continues at Basic Path #7.
- **Exception Path E6 exit:** No file was delivered, no records changed, the failed attempt is counted, and the use case continues at Basic Path #5.

**Open Issues/Notes**
- Whether to offer a bulk download of all W-9s for a business.
- For now, attaching a W-9 to a contact in TenantCloud is a manual step after download.
- Whether downloads are logged for audit.
- The password is asked once per sign-in session by default. [Use Case: Export Payee Data](#use-case-export-payee-data) asks for it on every export.

---

## Use Case: Follow Up on Incomplete Request

A Business Owner finds a request that has not been completed or failed to deliver and sends it again.

**Assumptions**
- The Business Owner is signed in.
- At least one request has status Sent (including Sent with the note Reminders ended) or Delivery failed.

**Actors**
- Business Owner: person following up.
- inform9 Platform: reissues the request.
- Email Service: delivers the new email.

**Trigger(s)**
- The Business Owner sees a request still open after [FOLLOW_UP_DAYS], or marked Delivery failed or Sent with the note Reminders ended.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Filters the payee list to open requests |
| 2. | inform9 Platform | Shows open requests with the number of days open and the Reminders ended note where reminders ended |
| 3. | Business Owner | Selects a request |
| 4. | Business Owner | Chooses Resend |
| 5. | inform9 Platform | Checks that the request is still open |
| 6. | inform9 Platform | Issues a new secure link |
| 7. | inform9 Platform | Deactivates the earlier link |
| 8. | inform9 Platform | Updates the request date and adds one to the resend count |
| 9. | inform9 Platform | Resets the reminder count and restarts the reminder schedule from the new date |
| 10. | Email Service | Delivers the request email to the payee's email address on file |
| 11. | inform9 Platform | Shows the request as Sent with the new date |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A4 (from Basic Path #4): The Business Owner corrects the payee email address first
  - A4.1 **Business Owner:** Edits the payee email address before resending.
  - A4.2 **inform9 Platform:** Validates the email address.
  - A4.3 **inform9 Platform:** Saves the corrected email address with the payee contact.
  - A4.4 Use case continues at Basic Path #5.

**Exception Paths**

- Exception Path E4 (from Basic Path #4): The resend limit is reached
  - E4.1 **inform9 Platform:** Finds that the request reached [MAX_RESENDS] resends.
  - E4.2 **inform9 Platform:** Shows a message that the limit is reached and suggests contacting the payee another way or [canceling the request](#use-case-cancel-request).
  - E4.3 End of use case.

- Exception Path E5 (from Basic Path #5): The request was completed in the meantime
  - E5.1 **inform9 Platform:** Finds that the request is Completed.
  - E5.2 **inform9 Platform:** Shows the request as Completed.
  - E5.3 **inform9 Platform:** Sends nothing.
  - E5.4 End of use case.

- Exception Path E10 (from Basic Path #10): The new email also bounces
  - E10.1 **Email Service:** Reports that the email bounced.
  - E10.2 **inform9 Platform:** Marks the request Delivery failed.
  - E10.3 **inform9 Platform:** Cancels the restarted reminder schedule.
  - E10.4 **inform9 Platform:** Suggests contacting the payee another way.
  - E10.5 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** The earlier link is inactive, a new link is active, the request status is Sent with the new date, the resend count is up by one, the reminder count is zero, and reminders are scheduled from the new date.
- **Alternate Path A4 exit:** The payee contact holds the corrected email address, and the Basic Path post-conditions also hold.
- **Exception Path E4 exit:** No email was sent and the request is unchanged.
- **Exception Path E5 exit:** No email was sent and the request status is Completed.
- **Exception Path E10 exit:** The request status is Delivery failed and no reminders are scheduled.

**Open Issues/Notes**
- Automatic reminders are covered by [Use Case: Send W-9 Reminders](#use-case-send-w-9-reminders). A manual resend restarts that schedule.
- [MAX_RESENDS] is suggested at 3 per request. A canceled request followed by a new request starts a new count. Decide whether that is acceptable.

---

## Use Case: Update a W-9

A Payee submits an updated W-9 to the businesses they choose, and each Business Owner is notified.

**Assumptions**
- The Payee has an active account with at least one completed W-9 stored with a business.

**Actors**
- Payee: person updating the W-9.
- inform9 Platform: stores new versions and notifies.
- Email Service: delivers notices.

**Trigger(s)**
- The Payee chooses to update their information in their account.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Signs in |
| 2. | Payee | Selects Update W-9 |
| 3. | inform9 Platform | Shows the saved information and the businesses that hold a W-9 from the Payee |
| 4. | Payee | Edits the information |
| 5. | inform9 Platform | Checks the entries for completeness and format |
| 6. | Payee | Selects all businesses to receive the update |
| 7. | Payee | Certifies the entries |
| 8. | Payee | Signs electronically |
| 9. | inform9 Platform | Stores a new W-9 version under each recipient business, which is all businesses or the businesses saved as recipients on this update |
| 10. | inform9 Platform | Keeps the earlier versions |
| 11. | inform9 Platform | Marks each new version Updated |
| 12. | Email Service | Delivers an update notice to the Business Owner of each recipient business |
| 13. | inform9 Platform | Confirms to the Payee which businesses received the update |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A1 (from Basic Path #1): A business requests a new W-9 instead of the Payee starting an update
  - A1.1 **Payee:** Completes the new request through [Use Case: Complete and Sign W-9](#use-case-complete-and-sign-w-9) or [Use Case: Confirm and Reuse Saved Payee Information](#use-case-confirm-and-reuse-saved-payee-information).
  - A1.2 **inform9 Platform:** Stores the result as a new version for the requesting business.
  - A1.3 **inform9 Platform:** Marks the new version Updated.
  - A1.4 End of use case.

- Alternate Path A6 (from Basic Path #6): The Payee selects only some businesses
  - A6.1 **Payee:** Checks only the businesses that should receive the update.
  - A6.2 **inform9 Platform:** Saves the checked businesses as the recipients of this update.
  - A6.3 **inform9 Platform:** Keeps the earlier version for each unchecked business.
  - A6.4 Use case continues at Basic Path #7.

**Exception Paths**

- Exception Path E5 (from Basic Path #5): An entry is missing or invalid
  - E5.1 **inform9 Platform:** Finds an entry missing or invalid.
  - E5.2 **inform9 Platform:** Highlights the fields to correct.
  - E5.3 Use case continues at Basic Path #4.

- Exception Path E6 (from Basic Path #6): The Payee selects no businesses
  - E6.1 **Payee:** Selects no businesses.
  - E6.2 **inform9 Platform:** Asks the **Payee** to select at least one business or cancel.
  - E6.3 **Payee:** Selects at least one business, or cancels.
  - E6.4 End of use case if the **Payee** cancels. Otherwise, use case continues at Basic Path #6.

**Post-Condition(s)**
- **Basic Path exit:** Each recipient business holds a new W-9 version with the new information, signature, and date. Earlier versions are kept. The Business Owner of each recipient business was notified by email.
- **Alternate Path A6 exit:** Only the checked businesses hold a new version. Unchecked businesses are unchanged.
- **Exception Path E6 exit (canceled):** No new version was created.
- **Alternate Path A1 exit:** The requesting business holds a new version marked Updated.
- **Exception Path E5 exit:** No new version was created, the fields to correct are highlighted, and the use case continues at Basic Path #4.

**Open Issues/Notes**
- Notices are email only in the first release.
- Businesses that do not receive the update keep the earlier version and are not told that an update exists.
- The list of businesses includes those that saved a payee-sent W-9. A business that only downloaded a payee-sent W-9 holds no stored copy, so the Payee sends it again to reach that business.

---

## Use Case: Upgrade After Free Limit

A Business Owner on the free plan subscribes to a paid plan to add more than 3 payees.

**Assumptions**
- The Business Owner is signed in on the free plan.
- Paid plans are available at [PLAN_PRICE] per year ($20 to $36 expected).

**Actors**
- Business Owner: person upgrading.
- inform9 Platform: shows plans and activates the paid plan.
- Payment Processor: authorizes and charges payment.
- Email Service: delivers the receipt.

**Trigger(s)**
- The Business Owner is blocked from adding a fourth payee, from adding a second business, or from saving a payee-sent W-9 that would exceed the limit, or chooses Upgrade in account settings.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Selects Upgrade |
| 2. | inform9 Platform | Shows the paid plan options and prices |
| 3. | Business Owner | Selects a plan |
| 4. | inform9 Platform | Sends the Business Owner to the Payment Processor's payment form |
| 5. | Business Owner | Enters payment details |
| 6. | Payment Processor | Authorizes the payment |
| 7. | Payment Processor | Charges the annual fee |
| 8. | inform9 Platform | Activates the paid plan |
| 9. | inform9 Platform | Raises the payee limit |
| 10. | inform9 Platform | Shows a confirmation |
| 11. | Email Service | Delivers a receipt |
| 12. | inform9 Platform | Returns the Business Owner to the action they were attempting |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Business Owner decides not to upgrade
  - A2.1 **Business Owner:** Closes the plan page.
  - A2.2 End of use case.

**Exception Paths**

- Exception Path E6a (from Basic Path #6): Payment is declined and the Business Owner tries another method
  - E6a.1 **Payment Processor:** Reports that the payment was declined.
  - E6a.2 **inform9 Platform:** Shows a message.
  - E6a.3 **inform9 Platform:** Offers another payment method.
  - E6a.4 **Business Owner:** Enters a different payment method.
  - E6a.5 Use case continues at Basic Path #6.

- Exception Path E6b (from Basic Path #6): Payment is declined and the Business Owner cancels
  - E6b.1 **Payment Processor:** Reports that the payment was declined.
  - E6b.2 **inform9 Platform:** Shows a message.
  - E6b.3 **Business Owner:** Cancels instead of retrying.
  - E6b.4 End of use case.

- Exception Path E6c (from Basic Path #6): The Payment Processor is unavailable
  - E6c.1 **Payment Processor:** Does not respond.
  - E6c.2 **inform9 Platform:** Shows a message that payment cannot be processed now and to try again later.
  - E6c.3 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** The account plan is Paid, the renewal date is one year out, the payee limit is [PAID_LIMIT], and the charge and receipt are recorded.
- **Alternate Path A2 and Exception Paths E6b and E6c exits:** The plan remains Free and no charge was made.
- **Exception Path E6a exit:** The plan is unchanged, the Business Owner is offered another payment method, and the use case continues at Basic Path #6.

**Open Issues/Notes**
- Pricing tiers, renewal and lapse rules, refunds, and sales tax. The paid limits [PAID_LIMIT] and [PAID_BUSINESS_LIMIT] are settings that stay open until after the beta.
- When a paid plan lapses, existing forms stay available, per the PR/FAQ. Whether payees above 3 stay editable is undecided.

---

## Use Case: Cancel Account and Data Handling

A Business Owner cancels their account and inform9 handles stored W-9 data under the retention policy.

**Assumptions**
- The Business Owner is signed in.
- A retention policy exists: [RETENTION_POLICY].

**Actors**
- Business Owner: person cancelling.
- inform9 Platform: cancels the plan and schedules data handling.
- Email Service: delivers confirmation.

**Trigger(s)**
- The Business Owner selects Cancel Account in settings.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Selects Cancel Account |
| 2. | inform9 Platform | Explains what happens to stored W-9s |
| 3. | inform9 Platform | Offers to let the Business Owner download W-9s first |
| 4. | inform9 Platform | States the retention policy |
| 5. | Business Owner | Confirms cancellation by entering their password |
| 6. | inform9 Platform | Ends the plan |
| 7. | inform9 Platform | Cancels all scheduled reminders |
| 8. | inform9 Platform | Schedules data handling per the policy |
| 9. | inform9 Platform | Signs the Business Owner out |
| 10. | Email Service | Delivers a cancellation confirmation |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A3 (from Basic Path #3): The Business Owner downloads W-9s first
  - A3.1 **Business Owner:** Chooses to download W-9s first.
  - A3.2 **Business Owner:** Completes [Use Case: View and Download W-9s](#use-case-view-and-download-w-9s).
  - A3.3 Use case continues at Basic Path #5.

**Exception Paths**

- Exception Path E5a (from Basic Path #5): The Business Owner changes their mind
  - E5a.1 **Business Owner:** Closes the confirmation without cancelling.
  - E5a.2 End of use case.

- Exception Path E5b (from Basic Path #5): The password is wrong
  - E5b.1 **inform9 Platform:** Finds that the password is wrong.
  - E5b.2 **inform9 Platform:** Shows an error and cancels nothing.
  - E5b.3 **inform9 Platform:** Counts the failed attempt toward the sign-in attempt limit. See [Use Case: Create Account and Sign In](#use-case-create-account-and-sign-in).
  - E5b.4 Use case continues at Basic Path #5.

**Post-Condition(s)**
- **Basic Path exit:** The account status is Canceled, the plan has ended, no reminders are scheduled, data handling is scheduled for [DATE], the Business Owner is signed out, and a confirmation was sent.
- **Exception Path E5a exit:** The account is unchanged.
- **Alternate Path A3 exit:** The Business Owner has completed View and Download W-9s, no account data changed, and the use case continues at Basic Path #5.
- **Exception Path E5b exit:** The account is unchanged, the failed attempt is counted, and the use case continues at Basic Path #5.

**Open Issues/Notes**
- The retention and deletion policy is not defined yet.
- Businesses may need to keep W-9 records for several years under IRS rules. Confirm with legal counsel before setting deletion timing.
- One account holds both the Business Owner role and the Payee role. Cancel Account ends the plan and starts business data handling. Whether the saved W-9 information, and the ability to sign in as a Payee, stay after cancellation is undecided. Deleting saved Payee information on request is a candidate use case.

---

## Use Case: Payee Sends W-9 to Business

A Payee with a saved W-9 sends it to a business on their own, without waiting for a request.

**Assumptions**
- The Payee has an active account.
- The Payee knows the receiving business name and a contact email address.
- The Payee is within send limits. See [Use Case: Limit Unsolicited Sends](#use-case-limit-unsolicited-sends).

**Actors**
- Payee: person sending the W-9.
- inform9 Platform: creates the share and secure link.
- Email Service: delivers the email.

**Trigger(s)**
- The Payee chooses Send W-9 in their account.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Signs in |
| 2. | Payee | Selects Send W-9 |
| 3. | inform9 Platform | Shows the saved W-9 information and a form for the business name and recipient email address |
| 4. | Payee | Enters the business name and recipient email address |
| 5. | Payee | Reviews the information |
| 6. | Payee | Approves sending it |
| 7. | inform9 Platform | Applies the send limits and opt-out check in [Use Case: Limit Unsolicited Sends](#use-case-limit-unsolicited-sends) |
| 8. | inform9 Platform | Creates a share record with a unique, time-limited secure link |
| 9. | inform9 Platform | Sets the share status to Sent |
| 10. | Email Service | Delivers an email to the recipient that names the Payee, says a W-9 is waiting, includes the link, and includes an opt-out link |
| 11. | inform9 Platform | Shows the share to the Payee as Sent |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Payee has an account but no saved W-9
  - A2.1 **Payee:** Selects Send W-9 without a saved W-9.
  - A2.2 **inform9 Platform:** Asks the **Payee** to complete a W-9, using the same fields as [Use Case: Complete and Sign W-9](#use-case-complete-and-sign-w-9).
  - A2.3 **Payee:** Completes and signs the W-9.
  - A2.4 **inform9 Platform:** Saves the information to the **Payee**'s account.
  - A2.5 Use case continues at Basic Path #3.

**Exception Paths**

- Exception Path E7 (from Basic Path #7): A send limit is exceeded or the recipient has opted out
  - E7.1 **inform9 Platform:** Finds that a send limit is exceeded or the recipient has opted out.
  - E7.2 **inform9 Platform:** Shows a message to the **Payee**.
  - E7.3 **inform9 Platform:** Sends nothing.
  - E7.4 End of use case.

- Exception Path E10 (from Basic Path #10): The email bounces
  - E10.1 **Email Service:** Reports that the email bounced.
  - E10.2 **inform9 Platform:** Marks the share Delivery failed.
  - E10.3 **inform9 Platform:** Notifies the **Payee**, who can correct the address and send again.
  - E10.4 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** A share record exists with status Sent, an active secure link, and an expiration date. It references the version of the W-9 the Payee approved. An email was delivered to the recipient. No W-9 is stored under any business.
- **Exception Path E7 exit:** No share record was created and no email was sent.
- **Exception Path E10 exit:** The share status is Delivery failed and the link is inactive.
- **Alternate Path A2 exit:** The Payee's account holds the newly completed W-9, and the use case continues at Basic Path #3.

**Open Issues/Notes**
- Whether to ask the Payee to enter the recipient email twice, since a mistyped address sends a W-9 to the wrong person.
- Share link lifetime is set by an Administrator, up to 7 days. See [Use Case: Configure Platform Settings](#use-case-configure-platform-settings).
- Whether the Payee can resend quickly to businesses they have sent to before.
- The Payee reviews sends in [Use Case: View Sent W-9s](#use-case-view-sent-w-9s).

---

## Use Case: Business Recipient Retrieves Payee-Sent W-9

A Business Recipient verifies their email address, views a W-9 a Payee sent, and downloads it without needing an account, for as long as the link is active.

**Assumptions**
- A share record exists with an active secure link.
- The Business Recipient may have no inform9 account.

**Actors**
- Business Recipient: person retrieving the W-9.
- inform9 Platform: verifies the recipient and delivers the file.
- Email Service: delivers the one-time code and the notice to the Payee.

**Trigger(s)**
- The Business Recipient clicks the link in a payee-sent email.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Recipient | Opens the link |
| 2. | inform9 Platform | Validates the link |
| 3. | inform9 Platform | Shows only the sender's name |
| 4. | inform9 Platform | Requests a one-time code for the email address the Payee entered |
| 5. | Email Service | Delivers the one-time code |
| 6. | Business Recipient | Enters the code |
| 7. | inform9 Platform | Verifies the code |
| 8. | inform9 Platform | Shows the W-9 with a Download button and a Save to account option |
| 9. | Business Recipient | Selects Download |
| 10. | inform9 Platform | Checks that the link is active and that downloads in the last 24 hours are under the daily cap |
| 11. | inform9 Platform | Delivers the W-9 as a PDF file |
| 12. | inform9 Platform | Logs the download with the date, time, share, and download number for the link |
| 13. | inform9 Platform | Marks the share Retrieved |
| 14. | Email Service | Delivers a retrieval notice to the Payee after the first download only |
| 15. | inform9 Platform | Offers the Business Recipient a free account to store and manage W-9s |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A8a (from Basic Path #8): The Business Recipient chooses Save to account
  - A8a.1 **Business Recipient:** Chooses Save to account instead of Download.
  - A8a.2 End of use case. The **Business Recipient** continues at [Use Case: Save Payee-Sent W-9 to Account](#use-case-save-payee-sent-w-9-to-account).

- Alternate Path A8b (from Basic Path #8): The Business Recipient selects "I am not the right recipient"
  - A8b.1 **Business Recipient:** Selects "I am not the right recipient."
  - A8b.2 **inform9 Platform:** Marks the share Misdirected.
  - A8b.3 **inform9 Platform:** Deactivates the link.
  - A8b.4 **Email Service:** Delivers a notice to the Payee.
  - A8b.5 End of use case.

- Alternate Path A15 (from Basic Path #15): The Business Recipient downloads the W-9 again while the link is active
  - A15.1 **Business Recipient:** Selects Download again.
  - A15.2 **inform9 Platform:** Checks that the link is active and that downloads in the last 24 hours are under the daily cap.
  - A15.3 **inform9 Platform:** Delivers the W-9 as a PDF file.
  - A15.4 **inform9 Platform:** Logs the download with the date, time, share, and download number for the link.
  - A15.5 End of use case. No further notice goes to the **Payee**.

**Exception Paths**

- Exception Path E2 (from Basic Path #2): The link is invalid, expired, or deactivated
  - E2.1 **inform9 Platform:** Finds the link invalid, expired, or deactivated.
  - E2.2 **inform9 Platform:** Shows a message that the sender must send the W-9 again.
  - E2.3 End of use case.

- Exception Path E7 (from Basic Path #7): The code is wrong or expired
  - E7.1 **Business Recipient:** Enters a code that is wrong or expired.
  - E7.2 **inform9 Platform:** Shows an error.
  - E7.3 **inform9 Platform:** Offers a new code.
  - E7.4 **inform9 Platform:** Locks the link for [LOCK_MINUTES] after [MAX_CODE_ATTEMPTS] wrong entries.
  - E7.5 Use case continues at Basic Path #4.

- Exception Path E10a (from Basic Path #10): The link expires before the download
  - E10a.1 **inform9 Platform:** Finds that the link expired after the **Business Recipient** was verified.
  - E10a.2 **inform9 Platform:** Shows a message that the sender must send the W-9 again.
  - E10a.3 End of use case.

- Exception Path E10b (from Basic Path #10): The daily download cap is reached
  - E10b.1 **inform9 Platform:** Finds that downloads in the last 24 hours reached the daily cap.
  - E10b.2 **inform9 Platform:** Logs the blocked attempt with the date, time, and share.
  - E10b.3 **inform9 Platform:** Shows a message that the daily limit was reached and to try again later or save the W-9 to a free account.
  - E10b.4 End of use case. The **Business Recipient** can continue at [Use Case: Save Payee-Sent W-9 to Account](#use-case-save-payee-sent-w-9-to-account) while the link is active.

**Post-Condition(s)**
- **Basic Path exit:** The share status is Retrieved. The download is recorded. The link stays active until it expires. The downloaded file matches the version the Payee approved. The Payee was notified. No W-9 is stored under any business.
- **Alternate Path A8b exit:** The share status is Misdirected, the link is inactive, and the Payee was notified.
- **Alternate Path A15 exit:** An additional download is logged and the Payee received no further notice.
- **Exception Path E10b exit:** The blocked attempt is logged and no file was delivered.
- **Exception Path E2, E7, and E10a exits:** No W-9 was shown or delivered.
- **Alternate Path A8a exit:** No download was logged, and the Business Recipient continues at Save Payee-Sent W-9 to Account.

**Open Issues/Notes**
- Link expiry is set by an Administrator, up to 7 days. See [Use Case: Configure Platform Settings](#use-case-configure-platform-settings). A Payee can send again after expiry.
- The daily cap is per link over a rolling 24 hours, set by an Administrator between 3 and 5 downloads.
- The download log supports reporting on repeat downloads, to learn whether they come from difficulty with the page or from other causes. Consider also logging whether the Business Recipient chose Save to account, and the device type.
- A report view of the download log is not yet a use case.
- One-time code length and lifetime: [CODE_MINUTES].

---

## Use Case: Save Payee-Sent W-9 to Account

A Business Recipient stores a payee-sent W-9 under a business in a free account so they can manage it with other W-9s.

**Assumptions**
- The Business Recipient has verified the email address on an active share link.
- The free plan allows up to 3 payees.

**Actors**
- Business Recipient: person saving the W-9. They become a Business Owner.
- inform9 Platform: creates the account records.

**Trigger(s)**
- The Business Recipient chooses Save to account, either instead of downloading or after a download.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Recipient | Selects Save to account |
| 2. | inform9 Platform | Asks the Business Recipient to sign in or create a free account. See [Use Case: Create Account and Sign In](#use-case-create-account-and-sign-in) |
| 3. | Business Recipient | Signs in or completes sign-up |
| 4. | inform9 Platform | Asks which business to store the W-9 under, or to add a new one |
| 5. | Business Recipient | Selects or adds the business. See [Use Case: Add Business](#use-case-add-business) |
| 6. | inform9 Platform | Checks the payee count against the plan limit |
| 7. | inform9 Platform | Creates a payee contact from the sender's name and email |
| 8. | inform9 Platform | Links the payee contact to the selected business |
| 9. | inform9 Platform | Stores the W-9 under the selected business |
| 10. | inform9 Platform | Marks the share Saved |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Business Recipient is already signed in
  - A2.1 **inform9 Platform:** Finds the **Business Recipient** already signed in.
  - A2.2 Use case continues at Basic Path #4.

- Alternate Path A6 (from Basic Path #6): A payee contact with the sender's email already exists in the account
  - A6.1 **inform9 Platform:** Finds a payee contact with the sender's email address in the account.
  - A6.2 **inform9 Platform:** Stores the W-9 as a new version for that payee and the selected business.
  - A6.3 **inform9 Platform:** Marks the share Saved.
  - A6.4 End of use case.

**Exception Paths**

- Exception Path E6a (from Basic Path #6): The account is at the plan limit and the Business Recipient declines to upgrade
  - E6a.1 **inform9 Platform:** Finds that the account is at the plan limit.
  - E6a.2 **inform9 Platform:** Explains the limit.
  - E6a.3 **inform9 Platform:** Offers an upgrade. See [Use Case: Upgrade After Free Limit](#use-case-upgrade-after-free-limit).
  - E6a.4 **Business Recipient:** Declines the upgrade.
  - E6a.5 End of use case. Nothing is saved, and downloads remain available until the link expires or the daily cap is reached.

- Exception Path E6b (from Basic Path #6): The account is at the plan limit and the Business Recipient upgrades
  - E6b.1 **inform9 Platform:** Finds that the account is at the plan limit.
  - E6b.2 **inform9 Platform:** Offers an upgrade.
  - E6b.3 **Business Recipient:** Chooses to upgrade.
  - E6b.4 **inform9 Platform:** Saves the selected business and share with the pending upgrade.
  - E6b.5 Use case continues at Basic Path #6 after the upgrade completes.

**Post-Condition(s)**
- **Basic Path exit:** A payee contact exists in the account, linked to the selected business, and counts toward the plan limit. The W-9 is stored under the business with source "Sent by Payee." The share status is Saved.
- **Alternate Path A6 exit:** The payee count is unchanged and a new W-9 version exists for the payee.
- **Exception Path E6a exit:** No payee contact or W-9 record was created.
- **Alternate Path A2 exit:** The Business Recipient's session is unchanged, and the use case continues at Basic Path #4.
- **Exception Path E6b exit:** The selected business and share are saved with the pending upgrade, no payee contact or W-9 record exists yet, and the use case continues at Basic Path #6 after the upgrade completes.

**Open Issues/Notes**
- Whether a saved payee-sent W-9 appears in the Payee's list of businesses that hold their W-9. By default it does, so later updates can reach that business.
- The Business Recipient can save only while the link is active, which ends when the link expires, up to 7 days after sending.

---

## Use Case: Limit Unsolicited Sends

inform9 limits payee-initiated sends so the feature cannot be used to flood businesses with unwanted email.

**Assumptions**
- Send limits are defined: [DAILY_SEND_CAP] per Payee, [PER_RECIPIENT_LIMIT] per recipient, and an opt-out list.

**Actors**
- Payee: person attempting to send.
- inform9 Platform: applies the limits.

**Trigger(s)**
- The Payee approves a send in [Use Case: Payee Sends W-9 to Business](#use-case-payee-sends-w-9-to-business).

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Approves a send |
| 2. | inform9 Platform | Compares the Payee's sends in the last 24 hours to the daily cap |
| 3. | inform9 Platform | Checks the recipient address and domain against the opt-out list |
| 4. | inform9 Platform | Checks earlier sends from this Payee to the same recipient |
| 5. | inform9 Platform | Allows the send |
| 6. | inform9 Platform | Returns to the sending flow |
| | | END OF USE CASE |

**Alternate Paths**

- No alternate paths identified for this use case.

**Exception Paths**

- Exception Path E2a (from Basic Path #2): The daily cap is reached
  - E2a.1 **inform9 Platform:** Finds that the daily cap is reached.
  - E2a.2 **inform9 Platform:** Tells the **Payee** when sending is available again.
  - E2a.3 End of use case.

- Exception Path E2b (from Basic Path #2): Sending patterns look abusive
  - E2b.1 **inform9 Platform:** Finds a pattern such as many recipients with many bounces.
  - E2b.2 **inform9 Platform:** Pauses sending for the **Payee**.
  - E2b.3 **inform9 Platform:** Tells the **Payee** that inform9 is reviewing an issue flagged on their account.
  - E2b.4 **inform9 Platform:** Raises a flag for the inform9 administrator to review.
  - E2b.5 End of use case. An Administrator reviews the flag in [Use Case: Review Abuse Flags](#use-case-review-abuse-flags).

- Exception Path E3 (from Basic Path #3): The recipient has opted out
  - E3.1 **inform9 Platform:** Finds that the recipient has opted out.
  - E3.2 **inform9 Platform:** Tells the **Payee** that the recipient does not accept W-9s through inform9.
  - E3.3 **inform9 Platform:** Offers to let the **Payee** download their own W-9 to send another way.
  - E3.4 End of use case.

- Exception Path E4 (from Basic Path #4): The Payee already sent to this recipient recently
  - E4.1 **inform9 Platform:** Finds an earlier send to this recipient within [REPEAT_WINDOW].
  - E4.2 **inform9 Platform:** Shows the earlier send and its status to the **Payee**.
  - E4.3 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** The send is allowed and counted in the Payee's 24-hour total.
- **Exception Path E2a, E3, and E4 exits:** No share record was created, no email was sent, and the daily total is unchanged.
- **Exception Path E2b exit:** No share record was created, no email was sent, the Payee's sending is paused, the Payee was told an issue is under review, and a flag is recorded for the inform9 administrator.

**Open Issues/Notes**
- Cap values, and whether new Payee accounts start with lower caps until their email has been verified for some time.
- Unsolicited email rules, such as sender identification and opt-out links. Review with legal counsel.

---

## Use Case: Opt Out of Payee-Sent W-9s

A Business Recipient who does not want W-9s from inform9 opts out or reports an unwanted or misdirected send.

**Assumptions**
- The Business Recipient received a payee-sent email that includes an opt-out link.
- The opt-out link never expires. It is separate from the download link, which expires.

**Actors**
- Business Recipient: person opting out.
- inform9 Platform: records the opt-out.

**Trigger(s)**
- The Business Recipient clicks the opt-out link in a payee-sent email or on the retrieval page.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Recipient | Opens the opt-out link |
| 2. | inform9 Platform | Shows the options: stop sends from this Payee, stop all payee-sent W-9s to this address, or report the send as unwanted or misdirected |
| 3. | Business Recipient | Selects an option |
| 4. | Business Recipient | Confirms the choice |
| 5. | inform9 Platform | Adds the opt-out record for the chosen scope |
| 6. | inform9 Platform | Deactivates the share link |
| 7. | inform9 Platform | Marks the share Not accepted |
| 8. | inform9 Platform | Shows the Business Recipient a confirmation |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A1 (from Basic Path #1): The Business Recipient already opted out
  - A1.1 **inform9 Platform:** Finds an opt-out record for the address on the link.
  - A1.2 **inform9 Platform:** Shows a confirmation that the opt-out is already in place.
  - A1.3 End of use case.

**Exception Paths**

- Exception Path E1 (from Basic Path #1): The link is not recognized
  - E1.1 **inform9 Platform:** Finds that the link is not recognized.
  - E1.2 **inform9 Platform:** Asks the **Business Recipient** for the email address to opt out.
  - E1.3 **Business Recipient:** Enters the email address.
  - E1.4 **inform9 Platform:** Requests a one-time code for that email address.
  - E1.5 **Email Service:** Delivers the one-time code.
  - E1.6 **Business Recipient:** Enters the code.
  - E1.7 **inform9 Platform:** Verifies the code.
  - E1.8 **inform9 Platform:** Adds an opt-out record for all payee-sent W-9s to that address.
  - E1.9 **inform9 Platform:** Shows the **Business Recipient** a confirmation.
  - E1.10 End of use case.

**Post-Condition(s)**
- **Alternate Path A1 exit:** The existing opt-out record is unchanged.
- **Exception Path E1 exit:** An opt-out record exists for all payee-sent W-9s to the verified email address.
- **Basic Path exit:** An opt-out record exists for the chosen scope, the share link is inactive, and the share status is Not accepted. Later sends in that scope are blocked by [Use Case: Limit Unsolicited Sends](#use-case-limit-unsolicited-sends).

**Open Issues/Notes**
- Reports against one Payee past [REPORT_THRESHOLD] raise a flag for review. See [Use Case: Review Abuse Flags](#use-case-review-abuse-flags).
- Whether a Business Recipient can opt back in.
- Exception Path E1 is the fallback for a link that is damaged or missing. If the code is wrong, the Business Recipient can request a new code. Define the code rules with [CODE_MINUTES] and [MAX_CODE_ATTEMPTS], as in Business Recipient Retrieves Payee-Sent W-9.

---

## Use Case: Send W-9 Reminders

inform9 sends a payee reminder emails about an open W-9 request until the form is received or the reminders stop.

**Assumptions**
- A request exists with status Sent and a reminder schedule. The default is every 7 days, up to 3 reminders.
- The payee has not completed, declined, or stopped reminders.

**Actors**
- inform9 Platform: decides when a reminder is due, creates it, and records it.
- Email Service: delivers the reminder and notices.
- Payee: recipient who can choose an option in the reminder email.

**Trigger(s)**
- The next reminder date for an open request arrives.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | inform9 Platform | Detects that a reminder is due for an open request |
| 2. | inform9 Platform | Checks that the request is still open |
| 3. | inform9 Platform | Checks that the reminder cap has not been reached |
| 4. | inform9 Platform | Checks the Payee's email address for earlier bounces and reminder stop records |
| 5. | inform9 Platform | Checks whether the Payee already received a reminder email today |
| 6. | inform9 Platform | Creates a reminder email for the request that names the business and includes the link, a Decline option, an "I am not the right person" option, and a Stop reminders option |
| 7. | Email Service | Delivers the reminder email to the Payee |
| 8. | inform9 Platform | Records the reminder as sent for each request in the email and adds one to each reminder count |
| 9. | inform9 Platform | Schedules the next reminder for each request in the email |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A5 (from Basic Path #5): The Payee already received a reminder email today
  - A5.1 **inform9 Platform:** Finds that the **Payee** already received a reminder email today.
  - A5.2 **inform9 Platform:** Moves this reminder to the next day and saves the new reminder date with the request.
  - A5.3 End of use case. The reminder is processed again when it is due.

- Alternate Path A6 (from Basic Path #6): The Payee has open requests from more than one business that are due
  - A6.1 **inform9 Platform:** Creates one reminder email that lists each due request and its business, and includes the link, a Decline option, an "I am not the right person" option, and a Stop reminders option.
  - A6.2 Use case continues at Basic Path #7.

- Alternate Path A7a (from Basic Path #7): The Payee selects Decline in the email
  - A7a.1 **Payee:** Selects Decline in the reminder email.
  - A7a.2 End of use case. The **Payee** continues at [Use Case: Payee Declines Request](#use-case-payee-declines-request).

- Alternate Path A7b (from Basic Path #7): The Payee selects "I am not the right person"
  - A7b.1 **Payee:** Selects "I am not the right person."
  - A7b.2 End of use case. The **Payee** continues at [Use Case: Payee Declines Request](#use-case-payee-declines-request), Alternate Path A2.

- Alternate Path A7c (from Basic Path #7): The Payee selects Stop reminders
  - A7c.1 **Payee:** Selects Stop reminders in the reminder email.
  - A7c.2 **inform9 Platform:** Adds a reminder stop record for the Payee's email address.
  - A7c.3 **inform9 Platform:** Cancels the remaining reminders for every open request to that email address.
  - A7c.4 **Email Service:** Delivers a notice to the Business Owner of each affected request that the Payee stopped reminders.
  - A7c.5 End of use case.

**Exception Paths**

- Exception Path E2 (from Basic Path #2): The request is no longer open
  - E2.1 **inform9 Platform:** Finds that the request is no longer open.
  - E2.2 **inform9 Platform:** Cancels the remaining reminders.
  - E2.3 End of use case.

- Exception Path E3 (from Basic Path #3): The reminder cap has been reached
  - E3.1 **inform9 Platform:** Finds that the reminder cap has been reached.
  - E3.2 **inform9 Platform:** Stops sending reminders.
  - E3.3 **inform9 Platform:** Marks the request Sent with the note Reminders ended.
  - E3.4 **Email Service:** Delivers a notice to the Business Owner that the request is still open and that reminders have ended.
  - E3.5 End of use case. The Business Owner can continue at [Use Case: Follow Up on Incomplete Request](#use-case-follow-up-on-incomplete-request).

- Exception Path E4 (from Basic Path #4): The Payee's address bounced earlier or the Payee stopped reminders
  - E4.1 **inform9 Platform:** Finds an earlier bounce or a reminder stop record for the **Payee**'s email address.
  - E4.2 **inform9 Platform:** Cancels the remaining reminders.
  - E4.3 **Email Service:** Delivers a notice to the Business Owner that reminders stopped and why.
  - E4.4 End of use case.

- Exception Path E7 (from Basic Path #7): The email bounces
  - E7.1 **Email Service:** Reports that the email bounced.
  - E7.2 **inform9 Platform:** Marks the request Delivery failed.
  - E7.3 **inform9 Platform:** Cancels the remaining reminders.
  - E7.4 **Email Service:** Delivers a notice to the Business Owner.
  - E7.5 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** One reminder email was delivered to the Payee, the reminder count increased by one, and the next reminder is scheduled at the configured interval.
- **Alternate Path A5 exit:** No email was sent today and the reminder is scheduled for the next day.
- **Alternate Path A7b exit:** The Payee continues at Payee Declines Request, Alternate Path A2.
- **Alternate Path A7c exit:** A reminder stop record exists for the email address, no reminders are scheduled for any open request to that address, and the Business Owner of each affected request was notified.
- **Exception Path E3 exit:** The request status is Sent with the note Reminders ended, no reminders are scheduled, and the Business Owner was notified.
- **Exception Path E2, E4, and E7 exits:** No reminders are scheduled for the request.
- **Alternate Path A6 exit:** One reminder email lists each due request and its business, and the use case continues at Basic Path #7.
- **Alternate Path A7a exit:** The Payee continues at Payee Declines Request.

**Open Issues/Notes**
- Request links must stay valid longer than the last reminder. With the defaults, the last reminder goes out on day 21, so [REQUEST_LINK_DAYS] should be at least 30.
- Reminder wording and time of day.
- Unsolicited email rules, such as sender identification and an unsubscribe link. Review with legal counsel.
- Whether to add a Business Owner option to pause reminders for one payee.
- A Business Owner can cancel a request. See [Use Case: Cancel Request](#use-case-cancel-request).

---

## Use Case: Set Reminder Schedule

A Business Owner sets how often inform9 reminds payees, and how many times, for a business.

**Assumptions**
- The Business Owner is signed in and has at least one business.
- Defaults apply until changed: every 7 days, up to 3 reminders.
- Allowed settings: an interval of 3 to 30 days and a cap of 1 to 6 reminders.
- Only paid plans can change the schedule.

**Actors**
- Business Owner: person setting the schedule.
- inform9 Platform: checks and saves the settings.

**Trigger(s)**
- The Business Owner opens the reminder settings for a business.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens the reminder settings for a business |
| 2. | inform9 Platform | Shows the current interval, cap, and whether reminders are on |
| 3. | Business Owner | Enters the number of days between reminders |
| 4. | Business Owner | Enters the maximum number of reminders |
| 5. | Business Owner | Selects Save |
| 6. | inform9 Platform | Checks the interval and cap against the allowed limits and the plan |
| 7. | inform9 Platform | Saves the schedule for the business |
| 8. | inform9 Platform | Confirms that the new schedule applies to future requests |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Business Owner turns reminders off
  - A2.1 **Business Owner:** Selects Turn off reminders.
  - A2.2 **inform9 Platform:** Saves reminders as off for the business.
  - A2.3 **inform9 Platform:** Confirms the change.
  - A2.4 End of use case.

- Alternate Path A8 (from Basic Path #8): The Business Owner applies the schedule to open requests
  - A8.1 **Business Owner:** Selects Apply to open requests.
  - A8.2 **inform9 Platform:** Recalculates the next reminder date for each open request using the saved schedule.
  - A8.3 End of use case.

**Exception Paths**

- Exception Path E6a (from Basic Path #6): The interval or cap is outside the allowed limits
  - E6a.1 **inform9 Platform:** Finds the interval or cap outside the allowed limits.
  - E6a.2 **inform9 Platform:** Shows the allowed ranges.
  - E6a.3 Use case continues at Basic Path #3.

- Exception Path E6b (from Basic Path #6): The plan does not allow changes
  - E6b.1 **inform9 Platform:** Finds that the plan does not allow changes.
  - E6b.2 **inform9 Platform:** Explains that the default schedule applies on the free plan.
  - E6b.3 **inform9 Platform:** Offers an upgrade. See [Use Case: Upgrade After Free Limit](#use-case-upgrade-after-free-limit).
  - E6b.4 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** The business has the saved interval and cap. Open requests are unchanged. Future requests for the business use the new schedule.
- **Alternate Path A2 exit:** Reminders are off for the business and future requests schedule none.
- **Alternate Path A8 exit:** Each open request has a recalculated next reminder date.
- **Exception Path E6a and E6b exits:** The saved schedule is unchanged.

**Open Issues/Notes**
- A single request can override the business schedule. See [Use Case: Request W-9](#use-case-request-w-9).
- Reminders are not scheduled for payee-sent W-9s, since no request exists.

---

## Use Case: Configure Platform Settings

An Administrator reviews and changes platform settings, such as link limits, sign-in rules, email provider, and plan values, without a code change or a redeploy.

**Assumptions**
- The Administrator is signed in with administrator rights and a second factor.
- This is an internal feature that customers never see.
- Each setting has a default, a minimum, and a maximum. The list is in the data model, section 4.
- A change applies at once, or only to items created afterward, as the setting states.

**Actors**
- Administrator: inform9 staff member changing settings.
- inform9 Platform: checks, saves, and applies the settings and keeps the audit log.
- Email Service: delivers the test message.
- Payment Processor: confirms the payment connection.

**Trigger(s)**
- The Administrator opens Settings.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Administrator | Opens Settings |
| 2. | inform9 Platform | Shows the setting groups: Email, Sign-in options, Sign-in and security, Links and codes, Reminders, Payee-sent controls, Abuse review, Plans, Analytics, and Retention |
| 3. | Administrator | Selects a group |
| 4. | inform9 Platform | Shows each setting in the group with its current value, its default, and its allowed range |
| 5. | Administrator | Enters one or more new values |
| 6. | Administrator | Selects Save |
| 7. | inform9 Platform | Checks each value against its allowed range |
| 8. | inform9 Platform | Saves the values |
| 9. | inform9 Platform | Records who made the change, the old values, the new values, and the time |
| 10. | inform9 Platform | Confirms the change and names the values that apply only to items created afterward |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A5a (from Basic Path #5): The Administrator restores a default
  - A5a.1 **Administrator:** Selects Restore default for a setting.
  - A5a.2 **inform9 Platform:** Fills in the default value for that setting.
  - A5a.3 Use case continues at Basic Path #6.

- Alternate Path A5b (from Basic Path #5): The Administrator enters a provider key
  - A5b.1 **Administrator:** Enters a key for the email provider, the payment processor, or Google sign-in in a write-only field.
  - A5b.2 **inform9 Platform:** Encrypts the key and saves it with its last four characters.
  - A5b.3 **inform9 Platform:** Records the change in the audit log without the key.
  - A5b.4 **inform9 Platform:** Shows only the last four characters from then on.
  - A5b.5 End of use case.

- Alternate Path A6a (from Basic Path #6): The Administrator sends a test email
  - A6a.1 **Administrator:** Selects Send test email and enters an address.
  - A6a.2 **inform9 Platform:** Asks the **Email Service** to send a test message with the saved provider settings.
  - A6a.3 **Email Service:** Delivers the test message.
  - A6a.4 **inform9 Platform:** Shows the result.
  - A6a.5 Use case continues at Basic Path #5.

- Alternate Path A6b (from Basic Path #6): The Administrator tests the payment connection
  - A6b.1 **Administrator:** Selects Test payment connection.
  - A6b.2 **inform9 Platform:** Asks the **Payment Processor** to confirm the saved key.
  - A6b.3 **Payment Processor:** Confirms or rejects the key.
  - A6b.4 **inform9 Platform:** Shows the result.
  - A6b.5 Use case continues at Basic Path #5.

- Alternate Path A6c (from Basic Path #6): The Administrator edits an email message
  - A6c.1 **Administrator:** Opens Email messages and selects a message.
  - A6c.2 **inform9 Platform:** Shows the subject, heading, body, button label, and the placeholders the message may use.
  - A6c.3 **Administrator:** Edits the text and selects Save.
  - A6c.4 **inform9 Platform:** Checks that every placeholder is allowed for that message and that every link is https.
  - A6c.5 **inform9 Platform:** Saves the text as a new version of the message.
  - A6c.6 **inform9 Platform:** Records the change in the audit log.
  - A6c.7 End of use case.

- Alternate Path A6d (from Basic Path #6): The Administrator cancels
  - A6d.1 **Administrator:** Selects Cancel.
  - A6d.2 **inform9 Platform:** Discards the entries.
  - A6d.3 End of use case.

**Exception Paths**

- Exception Path E7 (from Basic Path #7): A value is outside its allowed range
  - E7.1 **inform9 Platform:** Finds a value outside its allowed range.
  - E7.2 **inform9 Platform:** Shows the allowed range next to the value and saves nothing.
  - E7.3 Use case continues at Basic Path #5.

- Exception Path E8 (from Basic Path #8): The values cannot be saved
  - E8.1 **inform9 Platform:** Finds that the values could not be saved.
  - E8.2 **inform9 Platform:** Shows an error, saves none of the values, and keeps the entries on screen.
  - E8.3 Use case continues at Basic Path #6.

- Exception Path E6a (from Alternate Path A6a, step A6a.3): The test email fails
  - E6a.1 **Email Service:** Reports an error.
  - E6a.2 **inform9 Platform:** Shows the error without showing the key.
  - E6a.3 Use case continues at Basic Path #5.

**Post-Condition(s)**
- **Basic Path exit:** Each saved value equals the entered value. The audit log holds the Administrator, the old values, the new values, and the time. Items created before the change keep the values they were created with, where the setting applies only to later items.
- **Alternate Path A5a exit:** The entry holds the default, and the use case continues at Basic Path #6.
- **Alternate Path A5b exit:** The key is stored encrypted, only its last four characters are shown, and the audit log has no key value.
- **Alternate Path A6a and A6b exits:** One test message was sent, or one key check was made. Nothing else changed.
- **Alternate Path A6c exit:** The message has a new version with the edited text, and the change is in the audit log.
- **Alternate Path A6d exit:** The saved settings are unchanged.
- **Exception Path E7 exit:** The saved settings are unchanged, and the use case continues at Basic Path #5.
- **Exception Path E8 exit:** No value was saved, the entries remain on screen, and the use case continues at Basic Path #6.
- **Exception Path E6a exit:** No setting changed, and the use case continues at Basic Path #5.

**Open Issues/Notes**
- First release: values come from environment variables, and the checks in Basic Path #7 run when the service starts. The Settings screens are the target. A key set as a Worker secret with the same name takes precedence over a key saved in the screens.
- No second approver is required.
- Whether to add a "reason for change" field to the audit log.
- Link expiry (up to 7 days), the daily download cap (3 to 5), and the other ranges are in the data model, section 4. Links already sent keep the values they were sent with.
---

## Use Case: Export Payee Data

A Business Owner exports payee data, or the W-9 PDFs, for selected businesses as a file to import into accounting software or to keep.

**Assumptions**
- The Business Owner is signed in and has at least one payee with a completed W-9.
- The file formats are a QuickBooks Online vendor CSV, a Xero contacts CSV, a general CSV, and a ZIP of W-9 PDFs.
- The taxpayer ID in a CSV file is masked to the last four digits unless the Business Owner chooses the full number.

**Actors**
- Business Owner: person exporting the data.
- inform9 Platform: builds and delivers the file and logs the export.

**Trigger(s)**
- The Business Owner opens Export.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens Export |
| 2. | inform9 Platform | Shows the businesses, the file formats, and the taxpayer ID options |
| 3. | Business Owner | Selects one business or all businesses |
| 4. | Business Owner | Selects a CSV format |
| 5. | inform9 Platform | Shows that the taxpayer ID will be masked to the last four digits |
| 6. | Business Owner | Selects Export |
| 7. | inform9 Platform | Saves the businesses, the format, and the taxpayer ID option for this export |
| 8. | inform9 Platform | Finds the payees with a completed W-9 in the selected businesses |
| 9. | inform9 Platform | Builds the CSV file with one row per payee in the selected format |
| 10. | inform9 Platform | Delivers the file for download |
| 11. | inform9 Platform | Logs the export with the Business Owner, the time, the businesses, the format, and the taxpayer ID option |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A4 (from Basic Path #4): The Business Owner selects the ZIP of W-9 PDFs
  - A4.1 **Business Owner:** Selects ZIP of W-9 PDFs.
  - A4.2 **inform9 Platform:** Explains that the PDFs show the full taxpayer ID and asks the **Business Owner** to re-enter their password.
  - A4.3 **Business Owner:** Re-enters their password.
  - A4.4 **inform9 Platform:** Verifies the password.
  - A4.5 **inform9 Platform:** Saves the businesses and the ZIP format for this export.
  - A4.6 **inform9 Platform:** Finds the payees with a completed W-9 in the selected businesses.
  - A4.7 **inform9 Platform:** Builds a ZIP with the latest signed W-9 for each payee, named by business and payee.
  - A4.8 **inform9 Platform:** Delivers the file for download.
  - A4.9 **inform9 Platform:** Logs the export with the **Business Owner**, the time, the businesses, and the format.
  - A4.10 End of use case.

- Alternate Path A5 (from Basic Path #5): The Business Owner chooses the full taxpayer ID
  - A5.1 **Business Owner:** Chooses to include the full taxpayer ID.
  - A5.2 **inform9 Platform:** Warns that the file will hold unencrypted taxpayer IDs and asks the **Business Owner** to re-enter their password.
  - A5.3 **Business Owner:** Re-enters their password.
  - A5.4 **inform9 Platform:** Verifies the password.
  - A5.5 **inform9 Platform:** Sets the taxpayer ID option to full for this export.
  - A5.6 Use case continues at Basic Path #6.

**Exception Paths**

- Exception Path E8 (from Basic Path #8): No selected payee has a completed W-9
  - E8.1 **inform9 Platform:** Finds no payee with a completed W-9 in the selected businesses.
  - E8.2 **inform9 Platform:** Shows a message that nothing is available to export.
  - E8.3 Use case continues at Basic Path #3.

- Exception Path E5 (from Alternate Path A5, step A5.4): The password is wrong
  - E5.1 **inform9 Platform:** Finds that the password is wrong.
  - E5.2 **inform9 Platform:** Shows an error and keeps the taxpayer ID option at masked.
  - E5.3 Use case continues at Basic Path #5.

- Exception Path E9 (from Basic Path #9): The file cannot be built
  - E9.1 **inform9 Platform:** Finds that the file could not be built.
  - E9.2 **inform9 Platform:** Shows an error and offers to try again.
  - E9.3 **inform9 Platform:** Raises an alert for the inform9 administrator.
  - E9.4 Use case continues at Basic Path #6.

**Post-Condition(s)**
- **Basic Path exit:** The Business Owner received a CSV with one row per payee that has a completed W-9. The taxpayer ID is masked. The export is logged. No payee or W-9 record changed.
- **Alternate Path A4 exit:** The Business Owner received a ZIP with the latest signed W-9 for each payee. The export is logged.
- **Alternate Path A5 exit:** Use case continues in the Basic Path. The CSV then holds the full taxpayer ID, and the export log records the full option.
- **Exception Path E5 and E8 exits:** No file was delivered and nothing is logged.
- **Exception Path E9 exit:** No file was delivered, no successful export is logged, an alert was raised for the inform9 administrator, and the use case continues at Basic Path #6.

**Open Issues/Notes**
- CSV columns for QuickBooks Online and Xero: payee name, business name, email address, mailing address, taxpayer ID, and W-9 completion date. QuickBooks also has a "Track payments for 1099" field. These come from third-party import guides and need checking against the current official import templates.
- CSV files cannot carry the W-9 PDFs. Attaching PDFs in QuickBooks or Xero needs a direct integration, which is out of scope for the first release.
- Whether pending, declined, or archived payees appear in the file. By default only payees with a completed W-9 appear.
- Whether export is available on the free plan. By default it is.
- Whether exports expire from the download link, and how long the generated file is kept.
- E5 returns to Basic Path #5, which shows the masked default again.
- Mailing address and taxpayer ID formats may vary by tax classification. Define the mapping in requirements.

---

## Use Case: Manage Communication Preferences

A Business Owner or Payee views and changes whether they receive updates and information about inform9 products and services.

**Assumptions**
- The person has an inform9 account.
- Request, reminder, notice, and receipt emails continue whatever the preference.
- The unsubscribe link in every update email never expires.

**Actors**
- Business Owner: account holder changing the preference.
- Payee: account holder changing the preference.
- inform9 Platform: saves the preference and records the change.

**Trigger(s)**
- The Business Owner opens Communication Preferences in the account settings.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens Communication Preferences |
| 2. | inform9 Platform | Shows the current update preference and a list of emails that always apply |
| 3. | Business Owner | Changes the update preference |
| 4. | Business Owner | Selects Save |
| 5. | inform9 Platform | Saves the update preference with the date and time of the change |
| 6. | inform9 Platform | Confirms the change |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A1a (from Basic Path #1): A Payee changes the preference
  - A1a.1 **Payee:** Opens Communication Preferences.
  - A1a.2 **inform9 Platform:** Shows the current update preference and a list of emails that always apply.
  - A1a.3 **Payee:** Changes the update preference.
  - A1a.4 **Payee:** Selects Save.
  - A1a.5 **inform9 Platform:** Saves the update preference with the date and time of the change.
  - A1a.6 **inform9 Platform:** Confirms the change.
  - A1a.7 End of use case.

- Alternate Path A1b (from Basic Path #1): The account holder unsubscribes from an update email
  - A1b.1 **Business Owner:** Opens the unsubscribe link in an update email.
  - A1b.2 **inform9 Platform:** Validates the link.
  - A1b.3 **inform9 Platform:** Sets the update preference to unchecked and saves it with the date and time of the change.
  - A1b.4 **inform9 Platform:** Shows a confirmation that no more update emails will be sent.
  - A1b.5 End of use case.

**Exception Paths**

- Exception Path E5 (from Basic Path #5): The preference cannot be saved
  - E5.1 **inform9 Platform:** Finds that the preference could not be saved.
  - E5.2 **inform9 Platform:** Shows an error and keeps the earlier preference.
  - E5.3 Use case continues at Basic Path #3.

**Post-Condition(s)**
- **Basic Path exit:** The account holds the new update preference with the date and time of the change. Request, reminder, notice, and receipt emails are unchanged.
- **Alternate Path A1a exit:** The account holds the new update preference with the date and time of the change.
- **Alternate Path A1b exit:** The account holds an unchecked update preference with the date and time of the change, and no update emails are sent to it.
- **Exception Path E5 exit:** The earlier preference is unchanged, and the use case continues at Basic Path #3.

**Open Issues/Notes**
- Keep a record of when each person consented, and the wording they saw. Review the rules for marketing email with legal counsel before launch.
- A Business Recipient who only downloads a payee-sent W-9 is not added to update emails. A Business Recipient who saves to an account sees the box during sign-up.
- This preference is separate from opting out of payee-sent W-9s. See [Use Case: Opt Out of Payee-Sent W-9s](#use-case-opt-out-of-payee-sent-w-9s).
- The Payee version of this screen and the Business Owner version could share one screen. Keep them as one use case unless the screens differ.
---

## Use Case: Cancel Request

A Business Owner cancels an open W-9 request so the payee can no longer use the link and no more reminders go out.

**Assumptions**
- The Business Owner is signed in.
- At least one request has status Sent or Delivery failed.

**Actors**
- Business Owner: person canceling the request.
- inform9 Platform: deactivates the link, stops reminders, and updates the payee list.

**Trigger(s)**
- The Business Owner chooses Cancel Request on an open request in the payee list.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens the payee list for a business |
| 2. | Business Owner | Selects a payee with an open request |
| 3. | Business Owner | Selects Cancel Request |
| 4. | inform9 Platform | Explains that the link stops working, reminders stop, and the payee is not told |
| 5. | Business Owner | Confirms the cancellation |
| 6. | inform9 Platform | Checks that the request is still open |
| 7. | inform9 Platform | Deactivates the secure link |
| 8. | inform9 Platform | Cancels the scheduled reminders |
| 9. | inform9 Platform | Marks the request Canceled |
| 10. | inform9 Platform | Shows the payee as Not requested |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A5 (from Basic Path #5): The Business Owner changes their mind
  - A5.1 **Business Owner:** Closes the confirmation without canceling.
  - A5.2 End of use case. The request stays open.

**Exception Paths**

- Exception Path E6 (from Basic Path #6): The request is no longer open
  - E6.1 **inform9 Platform:** Finds that the Payee completed, declined, or bounced the request in the meantime.
  - E6.2 **inform9 Platform:** Shows the current status of the request.
  - E6.3 **inform9 Platform:** Cancels nothing.
  - E6.4 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** The request status is Canceled, the link is inactive, no reminders are scheduled, and the payee shows as Not requested. No email was sent to the Payee. The payee still counts toward the plan limit.
- **Alternate Path A5 exit:** The request status is unchanged.
- **Exception Path E6 exit:** The request is unchanged and nothing was canceled.

**Open Issues/Notes**
- A canceled request ends the whole request, including every business listed on it. To change the businesses, cancel the request and send a new one.
- A Payee who opens a canceled link sees the message in [Use Case: Complete and Sign W-9](#use-case-complete-and-sign-w-9), Exception Path E2.
- A canceled request followed by a new request starts a new resend count. See [Use Case: Follow Up on Incomplete Request](#use-case-follow-up-on-incomplete-request).
- Whether the Business Owner can choose to tell the Payee.

---

## Use Case: Edit or Archive Payee

A Business Owner changes the details of a payee, or archives a payee to free a place on the plan.

**Assumptions**
- The Business Owner is signed in and has at least one payee.

**Actors**
- Business Owner: person changing or archiving the payee.
- inform9 Platform: validates and saves the changes, and applies the plan limit.

**Trigger(s)**
- The Business Owner chooses Edit Payee or Archive Payee in the payee list.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens the payee list for a business |
| 2. | Business Owner | Selects a payee |
| 3. | Business Owner | Selects Edit Payee |
| 4. | inform9 Platform | Shows the payee name, email address, and linked businesses |
| 5. | Business Owner | Changes the name, the email address, or the linked businesses |
| 6. | Business Owner | Selects Save |
| 7. | inform9 Platform | Validates the entries and checks for another payee in the account with the same email address |
| 8. | inform9 Platform | Saves the changes to the payee contact |
| 9. | inform9 Platform | Shows the updated payee in the payee list |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A1 (from Basic Path #1): The Business Owner restores an archived payee
  - A1.1 **Business Owner:** Filters the payee list to archived payees and selects Restore for a payee.
  - A1.2 **inform9 Platform:** Checks the active payee count against the plan limit.
  - A1.3 **inform9 Platform:** Returns the payee to the active list with the status it had before it was archived.
  - A1.4 End of use case.

- Alternate Path A3 (from Basic Path #3): The Business Owner archives the payee
  - A3.1 **Business Owner:** Selects Archive Payee.
  - A3.2 **inform9 Platform:** Explains that open requests will be canceled, completed W-9s stay available, and the payee stops counting toward the plan limit.
  - A3.3 **Business Owner:** Confirms.
  - A3.4 **inform9 Platform:** Cancels each open request for the payee, as in [Use Case: Cancel Request](#use-case-cancel-request).
  - A3.5 **inform9 Platform:** Marks the payee Archived.
  - A3.6 **inform9 Platform:** Removes the payee from the active list and from the active payee count.
  - A3.7 End of use case.

- Alternate Path A8 (from Basic Path #8): The email address changed and the payee has an open request
  - A8.1 **inform9 Platform:** Finds an open request for the payee.
  - A8.2 **inform9 Platform:** Offers to resend the request to the new email address.
  - A8.3 **Business Owner:** Accepts.
  - A8.4 End of use case. The **Business Owner** continues at [Use Case: Follow Up on Incomplete Request](#use-case-follow-up-on-incomplete-request).

**Exception Paths**

- Exception Path E1 (from Alternate Path A1, step A1.2): The account is at the plan limit
  - E1.1 **inform9 Platform:** Finds that restoring the payee would exceed the plan limit.
  - E1.2 **inform9 Platform:** Explains the limit.
  - E1.3 **inform9 Platform:** Offers an upgrade. See [Use Case: Upgrade After Free Limit](#use-case-upgrade-after-free-limit).
  - E1.4 End of use case.

- Exception Path E7a (from Basic Path #7): An entry is missing or invalid
  - E7a.1 **inform9 Platform:** Finds an entry missing or invalid.
  - E7a.2 **inform9 Platform:** Highlights the fields to correct.
  - E7a.3 Use case continues at Basic Path #5.

- Exception Path E7b (from Basic Path #7): Another payee in the account has the same email address
  - E7b.1 **inform9 Platform:** Finds another payee with the same email address.
  - E7b.2 **inform9 Platform:** Shows that payee and explains that each email address needs one payee.
  - E7b.3 Use case continues at Basic Path #5.

**Post-Condition(s)**
- **Basic Path exit:** The payee contact holds the entered name, email address, and linked businesses. The payee count is unchanged. Completed W-9s and their earlier versions are unchanged.
- **Alternate Path A1 exit:** The payee is active and counts toward the plan limit.
- **Alternate Path A3 exit:** The payee status is Archived, each open request is Canceled with its link inactive and no reminders scheduled, the payee is not in the active payee count, and completed W-9s remain available to download.
- **Alternate Path A8 exit:** The payee holds the new email address and the Business Owner continues at Follow Up on Incomplete Request.
- **Exception Path E1 exit:** The payee remains archived and the payee count is unchanged.
- **Exception Path E7a and E7b exits:** No change was saved, and the use case continues at Basic Path #5.

**Open Issues/Notes**
- Removing a linked business from a payee does not delete a W-9 already stored under that business.
- Archived payees stay out of payee exports by default. See [Use Case: Export Payee Data](#use-case-export-payee-data).
- Permanent deletion of a payee follows the retention policy, which is not defined yet. See [Use Case: Cancel Account and Data Handling](#use-case-cancel-account-and-data-handling).
- If the Business Owner declines the resend in Alternate Path A8, the open request keeps its link, which went to the earlier email address.

---

## Use Case: Edit Business

A Business Owner changes the name, address, or notification email of a business.

**Assumptions**
- The Business Owner is signed in and has added at least one business.

**Actors**
- Business Owner: person changing the business.
- inform9 Platform: validates and saves the changes.

**Trigger(s)**
- The Business Owner chooses Edit Business in the business list.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Opens the business list |
| 2. | Business Owner | Selects a business |
| 3. | Business Owner | Selects Edit Business |
| 4. | inform9 Platform | Shows the business name, address, and notification email |
| 5. | Business Owner | Changes one or more of the fields |
| 6. | Business Owner | Selects Save |
| 7. | inform9 Platform | Checks that required fields are complete and that no other business in the account has the same name |
| 8. | inform9 Platform | Saves the changes to the business record |
| 9. | inform9 Platform | Confirms that the changes apply to forms shown to payees from now on |
| | | END OF USE CASE |

**Alternate Paths**

- No alternate paths identified for this use case.

**Exception Paths**

- Exception Path E7a (from Basic Path #7): A required field is empty
  - E7a.1 **inform9 Platform:** Finds a required field empty.
  - E7a.2 **inform9 Platform:** Highlights the missing fields.
  - E7a.3 Use case continues at Basic Path #5.

- Exception Path E7b (from Basic Path #7): Another business in the account has the same name
  - E7b.1 **inform9 Platform:** Finds a business with the same name in the account.
  - E7b.2 **inform9 Platform:** Shows a message that each business needs its own distinct legal name.
  - E7b.3 Use case continues at Basic Path #5.

**Post-Condition(s)**
- **Basic Path exit:** The business record holds the new name, address, and notification email. W-9s already signed keep the requester name and address they were signed with. A payee who opens an open request link later sees the new name and address.
- **Exception Path E7a and E7b exits:** The business record is unchanged, and the use case continues at Basic Path #5.

**Open Issues/Notes**
- Whether a new notification email needs verification before it receives notices.
- Whether a business can be archived or removed. Archiving would follow the same rules as [Use Case: Edit or Archive Payee](#use-case-edit-or-archive-payee).
- The business name and address appear on the W-9 shown to payees. See [Use Case: Add Business](#use-case-add-business).

---

## Use Case: Review Abuse Flags

An Administrator reviews a flag raised against a Payee who sends W-9s on their own, and decides whether sending resumes.

**Assumptions**
- The Administrator is signed in with administrator rights.
- This is an internal feature that customers never see.
- A flag exists. A flag is raised when [Use Case: Limit Unsolicited Sends](#use-case-limit-unsolicited-sends) pauses a Payee, or when reports against one Payee pass [REPORT_THRESHOLD].

**Actors**
- Administrator: inform9 staff member reviewing the flag.
- inform9 Platform: shows the evidence, applies the decision, and keeps the audit log.
- Email Service: delivers the notice to the Payee.

**Trigger(s)**
- The Administrator opens the list of flags.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Administrator | Opens the list of flags |
| 2. | inform9 Platform | Shows each open flag with the Payee, the reason, and the date |
| 3. | Administrator | Selects a flag |
| 4. | inform9 Platform | Shows the Payee's sends in the last [REVIEW_DAYS] days, bounces, recipient reports, and recipient opt-outs |
| 5. | Administrator | Reviews the details |
| 6. | Administrator | Selects Lift pause and enters a note |
| 7. | inform9 Platform | Resumes sending for the Payee |
| 8. | inform9 Platform | Marks the flag Reviewed |
| 9. | inform9 Platform | Records the Administrator, the decision, the note, and the time in the audit log |
| 10. | Email Service | Delivers a notice to the Payee that sending is available again |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A6a (from Basic Path #6): The Administrator keeps the pause
  - A6a.1 **Administrator:** Selects Keep pause and enters a note.
  - A6a.2 **inform9 Platform:** Keeps sending paused for the Payee.
  - A6a.3 **inform9 Platform:** Marks the flag Reviewed.
  - A6a.4 **inform9 Platform:** Records the Administrator, the decision, the note, and the time in the audit log.
  - A6a.5 End of use case.

- Alternate Path A6b (from Basic Path #6): The Administrator blocks the Payee from sending
  - A6b.1 **Administrator:** Selects Block sending and enters a note.
  - A6b.2 **inform9 Platform:** Blocks the Payee from sending W-9s on their own.
  - A6b.3 **inform9 Platform:** Marks the flag Reviewed.
  - A6b.4 **inform9 Platform:** Records the Administrator, the decision, the note, and the time in the audit log.
  - A6b.5 **Email Service:** Delivers a notice to the Payee that sending is blocked.
  - A6b.6 End of use case.

**Exception Paths**

- Exception Path E2 (from Basic Path #2): No flags are open
  - E2.1 **inform9 Platform:** Finds no open flags.
  - E2.2 **inform9 Platform:** Shows a message that nothing needs review.
  - E2.3 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** Sending is available for the Payee, the flag is Reviewed, the decision is in the audit log, and the Payee was notified.
- **Alternate Path A6a exit:** Sending stays paused, the flag is Reviewed, and the decision is in the audit log.
- **Alternate Path A6b exit:** The Payee is blocked from sending, the flag is Reviewed, the decision is in the audit log, and the Payee was notified.
- **Exception Path E2 exit:** Nothing changed.

**Open Issues/Notes**
- Values for [REPORT_THRESHOLD] and [REVIEW_DAYS].
- Whether the Payee can appeal a block, and how.
- First release: the Administrator may review flags by running reports against the data. The administrator screen in this use case is the target.
- Whether the notice to the Payee explains the reason for the pause.

---

## Use Case: Sign Out

An account holder ends their session so the next person at the device cannot reach their account.

**Assumptions**
- The account holder is signed in.

**Actors**
- Business Owner: account holder signing out.
- Payee: account holder signing out.
- inform9 Platform: ends the session.

**Trigger(s)**
- The Business Owner chooses Sign out.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Business Owner | Selects Sign out |
| 2. | inform9 Platform | Ends the session |
| 3. | inform9 Platform | Removes the session from the browser |
| 4. | inform9 Platform | Shows the sign-in page |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A1a (from Basic Path #1): A Payee signs out
  - A1a.1 **Payee:** Selects Sign out.
  - A1a.2 **inform9 Platform:** Ends the session and removes it from the browser.
  - A1a.3 **inform9 Platform:** Shows the sign-in page.
  - A1a.4 End of use case.

- Alternate Path A1b (from Basic Path #1): The session times out
  - A1b.1 **inform9 Platform:** Finds no activity in the session for [IDLE_MINUTES] minutes.
  - A1b.2 **inform9 Platform:** Ends the session and removes it from the browser.
  - A1b.3 **inform9 Platform:** Shows the sign-in page with a message that the session ended.
  - A1b.4 End of use case.

**Exception Paths**

- No exception paths identified for this use case.

**Post-Condition(s)**
- **Basic Path exit:** The session is ended and cannot be used again. The password confirmation saved for downloads is discarded.
- **Alternate Path A1a exit:** The session is ended, and the password confirmation is discarded.
- **Alternate Path A1b exit:** The session is ended, and the password confirmation is discarded.

**Open Issues/Notes**
- Value for [IDLE_MINUTES].
- Whether to offer sign out on all devices.
- A password reset also ends other sessions. See [Use Case: Reset Password](#use-case-reset-password).

---

## Use Case: View Sent W-9s

A Payee reviews the W-9s they sent on their own and sees whether each one was delivered, retrieved, or saved by the recipient.

**Assumptions**
- The Payee is signed in.
- The Payee has sent at least one W-9 through [Use Case: Payee Sends W-9 to Business](#use-case-payee-sends-w-9-to-business).

**Actors**
- Payee: account holder reviewing their sends.
- inform9 Platform: shows the sends and their status.

**Trigger(s)**
- The Payee opens Sent W-9s in their account.

**Basic Path**

| Step | Actor | Action |
| --- | --- | --- |
| 1. | Payee | Opens Sent W-9s |
| 2. | inform9 Platform | Shows each send with the recipient email address, the date sent, and a status (Sent, Retrieved, Delivery failed, Misdirected, Not accepted, Saved) |
| 3. | Payee | Selects a send |
| 4. | inform9 Platform | Shows the recipient email address, the business name entered, the date sent, the link expiry date, the W-9 version sent, and the date of each status change |
| | | END OF USE CASE |

**Alternate Paths**

- Alternate Path A2 (from Basic Path #2): The Payee filters by status
  - A2.1 **Payee:** Selects a status filter.
  - A2.2 **inform9 Platform:** Saves the selection as the current view.
  - A2.3 **inform9 Platform:** Refreshes the list for the current view.
  - A2.4 Use case continues at Basic Path #3.

- Alternate Path A4 (from Basic Path #4): The Payee sends the W-9 again
  - A4.1 **Payee:** Selects Send again for a send with status Delivery failed or for a send whose link expired.
  - A4.2 **inform9 Platform:** Starts [Use Case: Payee Sends W-9 to Business](#use-case-payee-sends-w-9-to-business) with the business name and recipient email address filled in.
  - A4.3 End of use case.

**Exception Paths**

- Exception Path E2 (from Basic Path #2): The Payee has no sends
  - E2.1 **inform9 Platform:** Finds no sends for the Payee.
  - E2.2 **inform9 Platform:** Shows a message and offers Send W-9.
  - E2.3 End of use case.

**Post-Condition(s)**
- **Basic Path exit:** No records changed. The Payee saw only sends made from their own account.
- **Alternate Path A2 exit:** The selected status filter is saved as the current view, and the list shows that view.
- **Alternate Path A4 exit:** No records changed, and the Payee continues at Payee Sends W-9 to Business.
- **Exception Path E2 exit:** No records changed.

**Open Issues/Notes**
- A send whose link passed its expiry date without a download shows as Sent. Whether to show it as Expired.
- Whether the Payee sees how many times the recipient downloaded the W-9. By default the Payee sees only the date of the first retrieval, which matches the one retrieval notice.
- Whether the Payee can revoke a send that is still active. This would need its own path.
- How long send history is kept. It follows the retention policy, which is not defined yet.
