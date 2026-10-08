*inform9 Test Cases. Draft 2. Version 2026-10-08 14:30 ET. Matches use cases Draft 15 (2026-10-08 14:10).*

# inform9 Test Cases

## Document Notes

- 151 test cases cover 30 use cases, one per Basic Path, Alternate Path, and Exception Path. Test cases added in Draft 2 follow the original ones in each use case.
- Source use cases: [use-cases.md](use-cases.md). Each test case cites the use case step it exercises. Preconditions refer to the use case Assumptions instead of copying them.
- Expected Results are the use case Post-Condition(s), copied as written. System-only steps (saving, checking, logging) are checked through the Expected Result.
- Test cases that need a post-condition: none.

**Use cases**

1. [Create Account and Sign In](#create-account-and-sign-in) (TC-CreateAccount-01 to TC-CreateAccount-05)
2. [Reset Password](#reset-password) (TC-ResetPassword-01 to TC-ResetPassword-03)
3. [Add Business](#add-business) (TC-AddBusiness-01 to TC-AddBusiness-05)
4. [Add Payee Contact](#add-payee-contact) (TC-AddPayee-01 to TC-AddPayee-04)
5. [Request W-9](#request-w-9) (TC-RequestW9-01 to TC-RequestW9-05)
6. [Complete and Sign W-9](#complete-and-sign-w-9) (TC-CompleteW9-01 to TC-CompleteW9-08)
7. [Create Payee Account](#create-payee-account) (TC-CreatePayeeAccount-01 to TC-CreatePayeeAccount-03)
8. [Confirm and Reuse Saved Payee Information](#confirm-and-reuse-saved-payee-information) (TC-ReusePayeeInfo-01 to TC-ReusePayeeInfo-06)
9. [Payee Declines Request](#payee-declines-request) (TC-DeclineRequest-01 to TC-DeclineRequest-04)
10. [View and Download W-9s](#view-and-download-w-9s) (TC-ViewDownload-01 to TC-ViewDownload-05)
11. [Follow Up on Incomplete Request](#follow-up-on-incomplete-request) (TC-FollowUp-01 to TC-FollowUp-05)
12. [Update a W-9](#update-a-w-9) (TC-UpdateW9-01 to TC-UpdateW9-05)
13. [Upgrade After Free Limit](#upgrade-after-free-limit) (TC-Upgrade-01 to TC-Upgrade-05)
14. [Cancel Account and Data Handling](#cancel-account-and-data-handling) (TC-CancelAccount-01 to TC-CancelAccount-04)
15. [Payee Sends W-9 to Business](#payee-sends-w-9-to-business) (TC-PayeeSends-01 to TC-PayeeSends-04)
16. [Business Recipient Retrieves Payee-Sent W-9](#business-recipient-retrieves-payee-sent-w-9) (TC-RecipientRetrieves-01 to TC-RecipientRetrieves-08)
17. [Save Payee-Sent W-9 to Account](#save-payee-sent-w-9-to-account) (TC-SaveSentW9-01 to TC-SaveSentW9-05)
18. [Limit Unsolicited Sends](#limit-unsolicited-sends) (TC-LimitSends-01 to TC-LimitSends-05)
19. [Opt Out of Payee-Sent W-9s](#opt-out-of-payee-sent-w-9s) (TC-OptOut-01 to TC-OptOut-03)
20. [Send W-9 Reminders](#send-w-9-reminders) (TC-Reminders-01 to TC-Reminders-10)
21. [Set Reminder Schedule](#set-reminder-schedule) (TC-ReminderSchedule-01 to TC-ReminderSchedule-05)
22. [Configure Platform Settings](#configure-platform-settings) (TC-PlatformSettings-01 to TC-PlatformSettings-10)
23. [Export Payee Data](#export-payee-data) (TC-ExportData-01 to TC-ExportData-06)
24. [Manage Communication Preferences](#manage-communication-preferences) (TC-Preferences-01 to TC-Preferences-04)
25. [Cancel Request](#cancel-request) (TC-CancelRequest-01 to TC-CancelRequest-03)
26. [Edit or Archive Payee](#edit-or-archive-payee) (TC-EditPayee-01 to TC-EditPayee-07)
27. [Edit Business](#edit-business) (TC-EditBusiness-01 to TC-EditBusiness-03)
28. [Review Abuse Flags](#review-abuse-flags) (TC-ReviewAbuse-01 to TC-ReviewAbuse-04)
29. [Sign Out](#sign-out) (TC-SignOut-01 to TC-SignOut-03)
30. [View Sent W-9s](#view-sent-w-9s) (TC-ViewShares-01 to TC-ViewShares-04)

---

## Create Account and Sign In

**Source:** [Use Case: Create Account and Sign In](use-cases.md#use-case-create-account-and-sign-in)

### TC-CreateAccount-01: Successful: Create Account and Sign In

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Enters name, email address, and password (Basic Path #1).
2. Business Owner: Chooses whether to check the box to receive updates and information about inform9 products and services (Basic Path #2).
3. Verify the Email Service delivers a verification email containing a link (Basic Path #5).
4. Business Owner: Clicks the verification link (Basic Path #6).
5. Verify inform9 prompts the Business Owner to add a first business (Basic Path #9).

**Expected Result:**
- Post-Condition (Basic Path exit): An account record exists with status Active and email verified. The Business Owner has an authenticated session. The account holds the update preference as chosen, unchecked unless the Business Owner checked the box.

### TC-CreateAccount-02: The Business Owner already has an account

**Covers:** Alternate Path A1

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Enters email address and password for the existing account (A1.1).

**Expected Result:**
- Post-Condition (Alternate Path A1 exit): An authenticated session exists for the existing account. No new account record was created.

### TC-CreateAccount-03: The credentials entered for an existing account are wrong

**Covers:** Exception Path E1

**Preconditions:**
- Source use case Assumptions.
- The credentials entered for an existing account are wrong.

**Steps:**
1. Business Owner: Enters an email address and password that do not match an account (E1.1).
2. Verify inform9 shows a message that the email address or password is incorrect, without saying which (E1.2).
3. Verify the use case continues at Basic Path #1 (E1.5).

**Expected Result:**
- Post-Condition (Exception Path E1 exit): No session was created, the failed attempt is counted, sign-in is locked once the attempt limit is reached, and the use case continues at Basic Path #1.

### TC-CreateAccount-04: The email address is already registered

**Covers:** Exception Path E3

**Preconditions:**
- Source use case Assumptions.
- The email address is already registered.

**Steps:**
1. Run Basic Path #1-2.
2. Verify inform9 shows a message with links to sign in or reset the password (E3.2).

**Expected Result:**
- Post-Condition (Exception Path E3 exit): No new account record exists and no session was created.

### TC-CreateAccount-05: The verification link has expired

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- The verification link has expired.

**Steps:**
1. Run Basic Path #1-5.
2. Business Owner: Clicks a verification link that has expired (E6.1).
3. Verify inform9 offers to send a new verification email (E6.2).
4. Business Owner: Accepts (E6.3).
5. Verify the use case continues at Basic Path #5 (E6.5).

**Expected Result:**
- Post-Condition (Exception Path E6 exit): A new verification link is saved with the pending account, and the use case continues at Basic Path #5.

---

## Reset Password

**Source:** [Use Case: Reset Password](use-cases.md#use-case-reset-password)

### TC-ResetPassword-01: Successful: Reset Password

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Enters their email address (Basic Path #1).
2. Verify inform9 shows a confirmation message (Basic Path #3).
3. Verify the Email Service delivers the reset email (Basic Path #4).
4. Business Owner: Clicks the reset link (Basic Path #5).
5. Verify inform9 shows a form for a new password (Basic Path #6).
6. Business Owner: Enters and confirms a new password (Basic Path #7).
7. Verify inform9 confirms the change (Basic Path #10).

**Expected Result:**
- Post-Condition (Basic Path exit): The account password is changed. Prior sessions are ended. The used reset link is invalid.

### TC-ResetPassword-02: No account uses the email address

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- No account uses the email address.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 shows the same confirmation message and sends no email (E2.2).

**Expected Result:**
- Post-Condition (Exception Path E2 exit): No email was sent and no account data changed.

### TC-ResetPassword-03: The reset link has expired

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- The reset link has expired.

**Steps:**
1. Run Basic Path #1-4.
2. Business Owner: Clicks a reset link that has expired (E5.1).
3. Verify inform9 offers to send a new link (E5.2).
4. Business Owner: Accepts (E5.3).
5. Verify the use case continues at Basic Path #4 (E5.5).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): A new time-limited reset link exists for the same account, the password is unchanged, and the use case continues at Basic Path #4.

---

## Add Business

**Source:** [Use Case: Add Business](use-cases.md#use-case-add-business)

### TC-AddBusiness-01: Successful: Add Business

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Selects Add Business (Basic Path #1).
2. Verify inform9 shows the business form (Basic Path #2).
3. Business Owner: Enters the business name, address, and notification email (Basic Path #3).
4. Verify inform9 shows the business in the business list (Basic Path #6).

**Expected Result:**
- Post-Condition (Basic Path exit): A business record exists in the account with the entered name, address, and notification email, and with a reminder schedule of every 7 days and up to 3 reminders.

### TC-AddBusiness-02: The Business Owner adds another business

**Covers:** Alternate Path A6

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Business Owner: Selects Add Business again (A6.1).
3. Verify the use case continues at Basic Path #2 (A6.2).

**Expected Result:**
- Post-Condition (Alternate Path A6 exit): The business from the Basic Path exists, and the use case restarts at Basic Path #2 for another business.

### TC-AddBusiness-03: A required field is empty

**Covers:** Exception Path E4a

**Preconditions:**
- Source use case Assumptions.
- A required field is empty.

**Steps:**
1. Run Basic Path #1-3.
2. Verify inform9 highlights the missing fields (E4a.2).
3. Verify the use case continues at Basic Path #3 (E4a.3).

**Expected Result:**
- Post-Condition (Exception Path E4a exit): No business record was created.

### TC-AddBusiness-04: A business with the same name already exists in the account

**Covers:** Exception Path E4b

**Preconditions:**
- Source use case Assumptions.
- A business with the same name already exists in the account.

**Steps:**
1. Run Basic Path #1-3.
2. Verify inform9 shows a message that each business needs its own distinct legal name (E4b.2).
3. Verify the use case continues at Basic Path #3 (E4b.3).

**Expected Result:**
- Post-Condition (Exception Path E4b exit): No business record was created, and the use case continues at Basic Path #3.

### TC-AddBusiness-05: The account is at the plan limit for businesses

**Covers:** Exception Path E4c

**Preconditions:**
- Source use case Assumptions.
- The account is at the plan limit for businesses.

**Steps:**
1. Run Basic Path #1-3.
2. Verify inform9 explains the limit (E4c.2).
3. Verify inform9 offers an upgrade (E4c.3).

**Expected Result:**
- Post-Condition (Exception Path E4c exit): No business record was created and the business count is unchanged.

---

## Add Payee Contact

**Source:** [Use Case: Add Payee Contact](use-cases.md#use-case-add-payee-contact)

### TC-AddPayee-01: Successful: Add Payee Contact

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Selects Add Payee (Basic Path #1).
2. Verify inform9 shows the payee form with the list of businesses (Basic Path #2).
3. Business Owner: Enters the payee name and email address (Basic Path #3).
4. Business Owner: Selects one or more businesses to link (Basic Path #4).
5. Verify inform9 shows the payee in the payee list with status Not requested (Basic Path #8).

**Expected Result:**
- Post-Condition (Basic Path exit): A payee contact exists with the entered name, email, and linked businesses, and counts toward the plan limit.

### TC-AddPayee-02: The Business Owner chooses to send a request now

**Covers:** Alternate Path A8

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-7.
2. Business Owner: Selects Send Request for the new payee (A8.1).

**Expected Result:**
- Post-Condition (Alternate Path A8 exit): The payee contact exists as in the Basic Path exit, and the request flow has started.

### TC-AddPayee-03: The account is at the plan limit

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- The account is at the plan limit.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 explains the limit (E5.2).
3. Verify inform9 offers an upgrade (E5.3).
4. Business Owner: Chooses to upgrade, or closes the message (E5.4).
5. Verify if the Business Owner chose to upgrade, they continue at Upgrade After Free Limit (E5.5).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): No payee contact was created and the payee count is unchanged.

### TC-AddPayee-04: A payee with the same email address already exists in the account

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- A payee with the same email address already exists in the account.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 shows the existing payee (E6.2).
3. Verify inform9 offers to link the additional businesses to the existing payee (E6.3).

**Expected Result:**
- Post-Condition (Exception Path E6 exit): No new payee contact was created.

---

## Request W-9

**Source:** [Use Case: Request W-9](use-cases.md#use-case-request-w-9)

### TC-RequestW9-01: Successful: Request W-9

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Selects a payee and the businesses to request the W-9 for (Basic Path #1).
2. Business Owner: Selects Send Request (Basic Path #2).
3. Verify the Email Service delivers an email to the payee that names each business on the request and contains the link, a Decline option, and an "I am not the right person" option (Basic Path #6).
4. Verify inform9 shows the request as Sent to the Business Owner (Basic Path #8).

**Expected Result:**
- Post-Condition (Basic Path exit): A request record exists with status Sent, the selected business, a secure link, and an expiration date. An email was delivered to the payee. Reminders are scheduled with the interval and cap in effect for the request.

### TC-RequestW9-02: The Business Owner changes the reminder schedule for this request

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Business Owner: Enters the days between reminders and the maximum number of reminders for this request (A2.1).
3. Verify the use case continues at Basic Path #3 (A2.4).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): The pending request holds the entered interval and cap as its reminder override, and the use case continues at Basic Path #3.

### TC-RequestW9-03: The Business Owner selected more than one business

**Covers:** Alternate Path A4

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-3.
2. Verify the use case continues at Basic Path #5 (A4.2).

**Expected Result:**
- Post-Condition (Alternate Path A4 exit): One request record lists every selected business. The payee's single submission is saved to each listed business.

### TC-RequestW9-04: An open request already exists for the same payee and business

**Covers:** Exception Path E3

**Preconditions:**
- Source use case Assumptions.
- An open request already exists for the same payee and business.

**Steps:**
1. Run Basic Path #1-2.
2. Verify inform9 warns the Business Owner (E3.2).
3. Verify inform9 offers to resend the existing request (E3.3).
4. Verify the Business Owner continues at Follow Up on Incomplete Request (E3.4).

**Expected Result:**
- Post-Condition (Exception Path E3 exit): No new request record was created.

### TC-RequestW9-05: The email bounces

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- The email bounces.

**Steps:**
1. Run Basic Path #1-5.
2. Verify the Email Service reports that the email bounced (E6.1).
3. Verify the Business Owner continues at Follow Up on Incomplete Request (E6.5).

**Expected Result:**
- Post-Condition (Exception Path E6 exit): The request status is Delivery failed, no reminders are scheduled, and the Business Owner was notified.

---

## Complete and Sign W-9

**Source:** [Use Case: Complete and Sign W-9](use-cases.md#use-case-complete-and-sign-w-9)

### TC-CompleteW9-01: Successful: Complete and Sign W-9

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Opens the link from the email (Basic Path #1).
2. Verify inform9 shows the W-9 form with the name and address of each requesting business filled in (Basic Path #3).
3. Payee: Enters name, business name if different, federal tax classification, address, and taxpayer identification number (Basic Path #4).
4. Payee: Reviews the entries and certifies them (Basic Path #6).
5. Payee: Signs electronically (Basic Path #7).
6. Verify the Email Service delivers a confirmation email to the Payee (Basic Path #12).
7. Verify the Email Service delivers a completion notice to the Business Owner (Basic Path #13).
8. Verify inform9 offers the Payee the option to create an account to save their information (Basic Path #14).

**Expected Result:**
- Post-Condition (Basic Path exit): A W-9 record exists under each business on the request with the Payee's entries, electronic signature, and timestamp. Each record shows its own business as the requester. The request status is Completed and no reminders are scheduled. The Business Owner and Payee were notified by email.

### TC-CompleteW9-02: The Payee already has an inform9 account

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 prompts the Payee to sign in (A2.2).
3. Verify the Payee continues at Confirm and Reuse Saved Payee Information (A2.3).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): No W-9 record was created, the Payee is prompted to sign in, and the Payee continues at Confirm and Reuse Saved Payee Information.

### TC-CompleteW9-03: The Payee chooses to decline

**Covers:** Alternate Path A3

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-2.
2. Payee: Chooses Decline instead of completing the form (A3.1).
3. Verify the Payee continues at Payee Declines Request (A3.2).

**Expected Result:**
- Post-Condition (Alternate Path A3 exit): No W-9 record was created, and the Payee continues at Payee Declines Request.

### TC-CompleteW9-04: The Payee chooses to create an account

**Covers:** Alternate Path A14

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-13.
2. Payee: Chooses to create an account (A14.1).
3. Verify the Payee continues at Create Payee Account (A14.2).

**Expected Result:**
- Post-Condition (Alternate Path A14 exit): The Basic Path post-conditions hold, and the Payee continues at Create Payee Account.

### TC-CompleteW9-05: The link is invalid, used, or expired

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- The link is invalid, used, or expired.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 shows a message telling the Payee to ask the business for a new request (E2.2).

**Expected Result:**
- Post-Condition (Exception Path E2 exit): No W-9 record was created and the request status is unchanged.

### TC-CompleteW9-06: An entry is missing or has an invalid format

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- An entry is missing or has an invalid format.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 highlights the fields to correct (E5.2).
3. Verify the use case continues at Basic Path #4 (E5.3).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): No W-9 record was created, the fields to correct are highlighted, and the use case continues at Basic Path #4.

### TC-CompleteW9-07: Storage fails

**Covers:** Exception Path E9

**Preconditions:**
- Source use case Assumptions.
- Storage fails.

**Steps:**
1. Run Basic Path #1-8.
2. Verify inform9 shows the Payee an error and keeps the entries on screen (E9.2).
3. Verify the use case continues at Basic Path #6 (E9.4).

**Expected Result:**
- Post-Condition (Exception Path E9 exit): No W-9 record was created, the request status is unchanged, the Payee's entries remain on screen, an alert was raised for the inform9 administrator, and the use case continues at Basic Path #6.

### TC-CompleteW9-08: The Payee is not a U.S. person

**Covers:** Alternate Path A4

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-3.
2. Payee: Selects "I am not a U.S. person." (A4.1).
3. Verify inform9 explains that it collects the W-9 only and cannot collect a W-8 form (A4.2).
4. Payee: Confirms (A4.3).
5. Verify the Email Service delivers a decline notice to the Business Owner that includes the reason (A4.7).

**Expected Result:**
- Post-Condition (Alternate Path A4 exit): The request status is Declined with the reason "Foreign payee", the link is inactive, no reminders are scheduled, no W-9 record was created, and the Business Owner was notified.

---

## Create Payee Account

**Source:** [Use Case: Create Payee Account](use-cases.md#use-case-create-payee-account)

### TC-CreatePayeeAccount-01: Successful: Create Payee Account

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Selects Create account (Basic Path #1).
2. Verify inform9 shows an account form with the Payee's email address filled in (Basic Path #2).
3. Payee: Enters a password (Basic Path #3).
4. Payee: Accepts the terms (Basic Path #4).
5. Payee: Chooses whether to check the box to receive updates and information about inform9 products and services (Basic Path #5).
6. Verify the Email Service delivers a verification email (Basic Path #7).
7. Payee: Clicks the verification link (Basic Path #8).

**Expected Result:**
- Post-Condition (Basic Path exit): An active Payee account exists, and the submitted W-9 information is stored in it. The completed W-9 remains stored under each business. The account holds the update preference as chosen, unchecked unless the Payee checked the box.

### TC-CreatePayeeAccount-02: An account already exists for the email address

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- An account already exists for the email address.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 asks the Payee to sign in (E6.2).
3. Verify inform9 offers to save the information to that account (E6.3).

**Expected Result:**
- Post-Condition (Exception Path E6 exit): No new account was created.

### TC-CreatePayeeAccount-03: The verification link has expired

**Covers:** Exception Path E8

**Preconditions:**
- Source use case Assumptions.
- The verification link has expired.

**Steps:**
1. Run Basic Path #1-7.
2. Payee: Clicks a verification link that has expired (E8.1).
3. Verify inform9 offers to send a new link (E8.2).
4. Payee: Accepts (E8.3).
5. Verify the use case continues at Basic Path #7 (E8.5).

**Expected Result:**
- Post-Condition (Exception Path E8 exit): A new verification link is saved with the pending account, and the use case continues at Basic Path #7.

---

## Confirm and Reuse Saved Payee Information

**Source:** [Use Case: Confirm and Reuse Saved Payee Information](use-cases.md#use-case-confirm-and-reuse-saved-payee-information)

### TC-ReusePayeeInfo-01: Successful: Confirm and Reuse Saved Payee Information

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Opens the link from the email (Basic Path #1).
2. Payee: Signs in (Basic Path #4).
3. Verify inform9 shows the request, the businesses on the request, and the saved W-9 information (Basic Path #5).
4. Payee: Reviews the information (Basic Path #6).
5. Payee: Approves sending it to the businesses with one click (Basic Path #7).
6. Verify the Email Service delivers a confirmation email to the Payee (Basic Path #12).
7. Verify the Email Service delivers a completion notice to the Business Owner (Basic Path #13).

**Expected Result:**
- Post-Condition (Basic Path exit): A W-9 record exists under each business on the request with the approved information and an approval timestamp. The request status is Completed and no reminders are scheduled. Both parties were notified.

### TC-ReusePayeeInfo-02: The Payee edits the information before approving

**Covers:** Alternate Path A6

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Payee: Changes one or more fields (A6.1).
3. Verify the use case continues at Basic Path #6 (A6.4).

**Expected Result:**
- Post-Condition (Alternate Path A6 exit): The saved information holds the edited values, and the Basic Path post-conditions also hold.

### TC-ReusePayeeInfo-03: The Payee declines

**Covers:** Alternate Path A7

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-6.
2. Payee: Declines instead of approving (A7.1).
3. Verify the Payee continues at Payee Declines Request (A7.2).

**Expected Result:**
- Post-Condition (Alternate Path A7 exit): Nothing was shared with the business, and the Payee continues at Payee Declines Request.

### TC-ReusePayeeInfo-04: The link is invalid, used, or expired

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- The link is invalid, used, or expired.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 shows a message telling the Payee to ask the business for a new request (E2.2).

**Expected Result:**
- Post-Condition (Exception Path E2 and E4 exit): No W-9 record was created and the request status is unchanged.

### TC-ReusePayeeInfo-05: The Payee cannot sign in

**Covers:** Exception Path E4

**Preconditions:**
- Source use case Assumptions.
- The Payee cannot sign in.

**Steps:**
1. Run Basic Path #1-3.
2. Payee: Cannot sign in (E4.1).
3. Verify inform9 offers password reset (E4.2).

**Expected Result:**
- Post-Condition (Exception Path E2 and E4 exit): No W-9 record was created and the request status is unchanged.

### TC-ReusePayeeInfo-06: Saved information is incomplete

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- Saved information is incomplete.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 shows the missing fields and withholds the approval option until they are complete (E5.2).
3. Payee: Enters the missing information (E5.3).
4. Verify the use case continues at Basic Path #6 (E5.6).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): Approval was not available until all required fields were complete, the saved information holds the entered values, and the use case continues at Basic Path #6.

---

## Payee Declines Request

**Source:** [Use Case: Payee Declines Request](use-cases.md#use-case-payee-declines-request)

### TC-DeclineRequest-01: Successful: Payee Declines Request

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Opens the request link (Basic Path #1).
2. Payee: Selects Decline (Basic Path #2).
3. Verify inform9 asks the Payee for an optional reason and says the reason is shared with the Business Owner (Basic Path #3).
4. Payee: Enters a reason or leaves it blank (Basic Path #4).
5. Payee: Confirms the decline (Basic Path #5).
6. Verify the Email Service delivers a decline notice to the Business Owner, including the reason if one was saved (Basic Path #9).

**Expected Result:**
- Post-Condition (Basic Path exit): The request status is Declined, the link is inactive, no reminders are scheduled, no W-9 record was created, and the Business Owner was notified.

### TC-DeclineRequest-02: The Payee changes their mind

**Covers:** Alternate Path A3

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-2.
2. Payee: Closes the decline page (A3.1).
3. Verify the request stays open (A3.2).

**Expected Result:**
- Post-Condition (Alternate Path A3 exit): The request status is unchanged.

### TC-DeclineRequest-03: The link is invalid, used, or expired

**Covers:** Exception Path E1

**Preconditions:**
- Source use case Assumptions.
- The link is invalid, used, or expired.

**Steps:**
1. Verify inform9 shows a message telling the Payee to ask the business for a new request (E1.2).

**Expected Result:**
- Post-Condition (Exception Path E1 exit): No request data changed.

### TC-DeclineRequest-04: The Payee selects "I am not the right person"

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Opens the request link (Basic Path #1).
2. Payee: Selects "I am not the right person" instead of Decline (A2.1).
3. Verify the Email Service delivers a notice to the Business Owner that the Payee is not the right person (A2.5).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): The request status is Declined with the reason "Not the right person", the link is inactive, no reminders are scheduled, no W-9 record was created, and the Business Owner was notified.

---

## View and Download W-9s

**Source:** [Use Case: View and Download W-9s](use-cases.md#use-case-view-and-download-w-9s)

### TC-ViewDownload-01: Successful: View and Download W-9s

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens the payee list for a business (Basic Path #1).
2. Verify inform9 shows each payee with a status (Not requested, Sent, Delivery failed, Declined, Completed) and an Updated marker where a newer W-9 was added (Basic Path #2).
3. Business Owner: Selects a payee (Basic Path #3).
4. Verify inform9 shows the payee details with each W-9 version and its date (Basic Path #4).
5. Business Owner: Selects Download for a version (Basic Path #5).
6. Verify inform9 delivers the W-9 as a PDF file (Basic Path #7).

**Expected Result:**
- Post-Condition (Basic Path exit): The downloaded file matches the stored version. No records changed.

### TC-ViewDownload-02: The Business Owner switches business or applies a status filter

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Business Owner: Selects a different business or a status filter (A2.1).
3. Verify the use case continues at Basic Path #3 (A2.4).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): The selected business or status filter is saved as the current view, and the list shows that view.

### TC-ViewDownload-03: The W-9 file is unavailable

**Covers:** Exception Path E7

**Preconditions:**
- Source use case Assumptions.
- The W-9 file is unavailable.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 shows the Business Owner an error and offers to try again (E7.2).
3. Verify the use case continues at Basic Path #5 (E7.4).

**Expected Result:**
- Post-Condition (Exception Path E7 exit): No file was delivered, no records changed, an alert was raised for the inform9 administrator, and the use case continues at Basic Path #5.

### TC-ViewDownload-04: The password was not confirmed in this sign-in session

**Covers:** Alternate Path A6

**Preconditions:**
- Source use case Assumptions.
- The password was not confirmed in this sign-in session.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 explains that the PDF shows the full taxpayer ID and asks the Business Owner to enter their password (A6.1).
3. Business Owner: Enters their password (A6.2).
4. Verify the use case continues at Basic Path #7 (A6.5).

**Expected Result:**
- Post-Condition (Alternate Path A6 exit): The password confirmation is saved with the sign-in session, and the use case continues at Basic Path #7.

### TC-ViewDownload-05: The password is wrong

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- The password was not confirmed in this sign-in session.

**Steps:**
1. Run Basic Path #1-5.
2. Business Owner: Enters a wrong password (A6.2).
3. Verify inform9 shows an error and delivers no file (E6.2).
4. Verify the use case continues at Basic Path #5 (E6.4).

**Expected Result:**
- Post-Condition (Exception Path E6 exit): No file was delivered, no records changed, the failed attempt is counted, and the use case continues at Basic Path #5.

---

## Follow Up on Incomplete Request

**Source:** [Use Case: Follow Up on Incomplete Request](use-cases.md#use-case-follow-up-on-incomplete-request)

### TC-FollowUp-01: Successful: Follow Up on Incomplete Request

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Filters the payee list to open requests (Basic Path #1).
2. Verify inform9 shows open requests with the number of days open and the Reminders ended note where reminders ended (Basic Path #2).
3. Business Owner: Selects a request (Basic Path #3).
4. Business Owner: Chooses Resend (Basic Path #4).
5. Verify the Email Service delivers the request email to the payee's email address on file (Basic Path #10).
6. Verify inform9 shows the request as Sent with the new date (Basic Path #11).

**Expected Result:**
- Post-Condition (Basic Path exit): The earlier link is inactive, a new link is active, the request status is Sent with the new date, the resend count is up by one, the reminder count is zero, and reminders are scheduled from the new date.

### TC-FollowUp-02: The Business Owner corrects the payee email address first

**Covers:** Alternate Path A4

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-3.
2. Business Owner: Edits the payee email address before resending (A4.1).
3. Verify the use case continues at Basic Path #5 (A4.4).

**Expected Result:**
- Post-Condition (Alternate Path A4 exit): The payee contact holds the corrected email address, and the Basic Path post-conditions also hold.

### TC-FollowUp-03: The request was completed in the meantime

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- The request was completed in the meantime.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 shows the request as Completed (E5.2).
3. Verify inform9 sends nothing (E5.3).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): No email was sent and the request status is Completed.

### TC-FollowUp-04: The new email also bounces

**Covers:** Exception Path E10

**Preconditions:**
- Source use case Assumptions.
- The new email also bounces.

**Steps:**
1. Run Basic Path #1-9.
2. Verify the Email Service reports that the email bounced (E10.1).

**Expected Result:**
- Post-Condition (Exception Path E10 exit): The request status is Delivery failed and no reminders are scheduled.

### TC-FollowUp-05: The resend limit is reached

**Covers:** Exception Path E4

**Preconditions:**
- Source use case Assumptions.
- The request reached [MAX_RESENDS] resends.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 shows a message that the limit is reached and suggests contacting the payee another way or canceling the request (E4.2).

**Expected Result:**
- Post-Condition (Exception Path E4 exit): No email was sent and the request is unchanged.

---

## Update a W-9

**Source:** [Use Case: Update a W-9](use-cases.md#use-case-update-a-w-9)

### TC-UpdateW9-01: Successful: Update a W-9

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Signs in (Basic Path #1).
2. Payee: Selects Update W-9 (Basic Path #2).
3. Verify inform9 shows the saved information and the businesses that hold a W-9 from the Payee (Basic Path #3).
4. Payee: Edits the information (Basic Path #4).
5. Payee: Selects all businesses to receive the update (Basic Path #6).
6. Payee: Certifies the entries (Basic Path #7).
7. Payee: Signs electronically (Basic Path #8).
8. Verify the Email Service delivers an update notice to the Business Owner of each recipient business (Basic Path #12).
9. Verify inform9 confirms to the Payee which businesses received the update (Basic Path #13).

**Expected Result:**
- Post-Condition (Basic Path exit): Each recipient business holds a new W-9 version with the new information, signature, and date. Earlier versions are kept. The Business Owner of each recipient business was notified by email.

### TC-UpdateW9-02: A business requests a new W-9 instead of the Payee starting an update

**Covers:** Alternate Path A1

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Completes the new request through Complete and Sign W-9 or Confirm and Reuse Saved Payee Information (A1.1).

**Expected Result:**
- Post-Condition (Alternate Path A1 exit): The requesting business holds a new version marked Updated.

### TC-UpdateW9-03: The Payee selects only some businesses

**Covers:** Alternate Path A6

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Payee: Checks only the businesses that should receive the update (A6.1).
3. Verify the use case continues at Basic Path #7 (A6.4).

**Expected Result:**
- Post-Condition (Alternate Path A6 exit): Only the checked businesses hold a new version. Unchecked businesses are unchanged.

### TC-UpdateW9-04: An entry is missing or invalid

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- An entry is missing or invalid.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 highlights the fields to correct (E5.2).
3. Verify the use case continues at Basic Path #4 (E5.3).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): No new version was created, the fields to correct are highlighted, and the use case continues at Basic Path #4.

### TC-UpdateW9-05: The Payee selects no businesses

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- The Payee selects no businesses.

**Steps:**
1. Run Basic Path #1-5.
2. Payee: Selects no businesses (E6.1).
3. Verify inform9 asks the Payee to select at least one business or cancel (E6.2).
4. Payee: Selects at least one business, or cancels (E6.3).

**Expected Result:**
- Post-Condition (Exception Path E6 exit (canceled) exit): No new version was created.

---

## Upgrade After Free Limit

**Source:** [Use Case: Upgrade After Free Limit](use-cases.md#use-case-upgrade-after-free-limit)

### TC-Upgrade-01: Successful: Upgrade After Free Limit

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Selects Upgrade (Basic Path #1).
2. Verify inform9 shows the paid plan options and prices (Basic Path #2).
3. Business Owner: Selects a plan (Basic Path #3).
4. Verify inform9 sends the Business Owner to the Payment Processor's payment form (Basic Path #4).
5. Business Owner: Enters payment details (Basic Path #5).
6. Verify the Payment Processor authorizes the payment (Basic Path #6).
7. Verify the Payment Processor charges the annual fee (Basic Path #7).
8. Verify inform9 shows a confirmation (Basic Path #10).
9. Verify the Email Service delivers a receipt (Basic Path #11).

**Expected Result:**
- Post-Condition (Basic Path exit): The account plan is Paid, the renewal date is one year out, the payee limit is [PAID_LIMIT], and the charge and receipt are recorded.

### TC-Upgrade-02: The Business Owner decides not to upgrade

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Business Owner: Closes the plan page (A2.1).

**Expected Result:**
- Post-Condition (Alternate Path A2 and Exception Paths E6b and E6c exit): The plan remains Free and no charge was made.

### TC-Upgrade-03: Payment is declined and the Business Owner tries another method

**Covers:** Exception Path E6a

**Preconditions:**
- Source use case Assumptions.
- Payment is declined and the Business Owner tries another method.

**Steps:**
1. Run Basic Path #1-5.
2. Verify the Payment Processor reports that the payment was declined (E6a.1).
3. Verify inform9 shows a message (E6a.2).
4. Verify inform9 offers another payment method (E6a.3).
5. Business Owner: Enters a different payment method (E6a.4).
6. Verify the use case continues at Basic Path #6 (E6a.5).

**Expected Result:**
- Post-Condition (Exception Path E6a exit): The plan is unchanged, the Business Owner is offered another payment method, and the use case continues at Basic Path #6.

### TC-Upgrade-04: Payment is declined and the Business Owner cancels

**Covers:** Exception Path E6b

**Preconditions:**
- Source use case Assumptions.
- Payment is declined and the Business Owner cancels.

**Steps:**
1. Run Basic Path #1-5.
2. Verify the Payment Processor reports that the payment was declined (E6b.1).
3. Verify inform9 shows a message (E6b.2).
4. Business Owner: Cancels instead of retrying (E6b.3).

**Expected Result:**
- Post-Condition (Alternate Path A2 and Exception Paths E6b and E6c exit): The plan remains Free and no charge was made.

### TC-Upgrade-05: The Payment Processor is unavailable

**Covers:** Exception Path E6c

**Preconditions:**
- Source use case Assumptions.
- The Payment Processor is unavailable.

**Steps:**
1. Run Basic Path #1-5.
2. Verify the Payment Processor does not respond (E6c.1).
3. Verify inform9 shows a message that payment cannot be processed now and to try again later (E6c.2).

**Expected Result:**
- Post-Condition (Alternate Path A2 and Exception Paths E6b and E6c exit): The plan remains Free and no charge was made.

---

## Cancel Account and Data Handling

**Source:** [Use Case: Cancel Account and Data Handling](use-cases.md#use-case-cancel-account-and-data-handling)

### TC-CancelAccount-01: Successful: Cancel Account and Data Handling

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Selects Cancel Account (Basic Path #1).
2. Verify inform9 explains what happens to stored W-9s (Basic Path #2).
3. Verify inform9 offers to let the Business Owner download W-9s first (Basic Path #3).
4. Business Owner: Confirms cancellation by entering their password (Basic Path #5).
5. Verify the Email Service delivers a cancellation confirmation (Basic Path #10).

**Expected Result:**
- Post-Condition (Basic Path exit): The account status is Canceled, the plan has ended, no reminders are scheduled, data handling is scheduled for [DATE], the Business Owner is signed out, and a confirmation was sent.

### TC-CancelAccount-02: The Business Owner downloads W-9s first

**Covers:** Alternate Path A3

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-2.
2. Business Owner: Chooses to download W-9s first (A3.1).
3. Business Owner: Completes View and Download W-9s (A3.2).
4. Verify the use case continues at Basic Path #5 (A3.3).

**Expected Result:**
- Post-Condition (Alternate Path A3 exit): The Business Owner has completed View and Download W-9s, no account data changed, and the use case continues at Basic Path #5.

### TC-CancelAccount-03: The Business Owner changes their mind

**Covers:** Exception Path E5a

**Preconditions:**
- Source use case Assumptions.
- The Business Owner changes their mind.

**Steps:**
1. Run Basic Path #1-4.
2. Business Owner: Closes the confirmation without cancelling (E5a.1).

**Expected Result:**
- Post-Condition (Exception Path E5a exit): The account is unchanged.

### TC-CancelAccount-04: The password is wrong

**Covers:** Exception Path E5b

**Preconditions:**
- Source use case Assumptions.
- The password is wrong.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 shows an error and cancels nothing (E5b.2).
3. Verify the use case continues at Basic Path #5 (E5b.4).

**Expected Result:**
- Post-Condition (Exception Path E5b exit): The account is unchanged, the failed attempt is counted, and the use case continues at Basic Path #5.

---

## Payee Sends W-9 to Business

**Source:** [Use Case: Payee Sends W-9 to Business](use-cases.md#use-case-payee-sends-w-9-to-business)

### TC-PayeeSends-01: Successful: Payee Sends W-9 to Business

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Signs in (Basic Path #1).
2. Payee: Selects Send W-9 (Basic Path #2).
3. Verify inform9 shows the saved W-9 information and a form for the business name and recipient email address (Basic Path #3).
4. Payee: Enters the business name and recipient email address (Basic Path #4).
5. Payee: Reviews the information (Basic Path #5).
6. Payee: Approves sending it (Basic Path #6).
7. Verify the Email Service delivers an email to the recipient that names the Payee, says a W-9 is waiting, includes the link, and includes an opt-out link (Basic Path #10).
8. Verify inform9 shows the share to the Payee as Sent (Basic Path #11).

**Expected Result:**
- Post-Condition (Basic Path exit): A share record exists with status Sent, an active secure link, and an expiration date. It references the version of the W-9 the Payee approved. An email was delivered to the recipient. No W-9 is stored under any business.

### TC-PayeeSends-02: The Payee has an account but no saved W-9

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Payee: Selects Send W-9 without a saved W-9 (A2.1).
3. Verify inform9 asks the Payee to complete a W-9, using the same fields as Complete and Sign W-9 (A2.2).
4. Payee: Completes and signs the W-9 (A2.3).
5. Verify the use case continues at Basic Path #3 (A2.5).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): The Payee's account holds the newly completed W-9, and the use case continues at Basic Path #3.

### TC-PayeeSends-03: A send limit is exceeded or the recipient has opted out

**Covers:** Exception Path E7

**Preconditions:**
- Source use case Assumptions.
- A send limit is exceeded or the recipient has opted out.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 shows a message to the Payee (E7.2).
3. Verify inform9 sends nothing (E7.3).

**Expected Result:**
- Post-Condition (Exception Path E7 exit): No share record was created and no email was sent.

### TC-PayeeSends-04: The email bounces

**Covers:** Exception Path E10

**Preconditions:**
- Source use case Assumptions.
- The email bounces.

**Steps:**
1. Run Basic Path #1-9.
2. Verify the Email Service reports that the email bounced (E10.1).

**Expected Result:**
- Post-Condition (Exception Path E10 exit): The share status is Delivery failed and the link is inactive.

---

## Business Recipient Retrieves Payee-Sent W-9

**Source:** [Use Case: Business Recipient Retrieves Payee-Sent W-9](use-cases.md#use-case-business-recipient-retrieves-payee-sent-w-9)

### TC-RecipientRetrieves-01: Successful: Business Recipient Retrieves Payee-Sent W-9

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Recipient: Opens the link (Basic Path #1).
2. Verify inform9 shows only the sender's name (Basic Path #3).
3. Verify inform9 requests a one-time code for the email address the Payee entered (Basic Path #4).
4. Verify the Email Service delivers the one-time code (Basic Path #5).
5. Business Recipient: Enters the code (Basic Path #6).
6. Verify inform9 shows the W-9 with a Download button and a Save to account option (Basic Path #8).
7. Business Recipient: Selects Download (Basic Path #9).
8. Verify inform9 delivers the W-9 as a PDF file (Basic Path #11).
9. Verify the Email Service delivers a retrieval notice to the Payee after the first download only (Basic Path #14).
10. Verify inform9 offers the Business Recipient a free account to store and manage W-9s (Basic Path #15).

**Expected Result:**
- Post-Condition (Basic Path exit): The share status is Retrieved. The download is recorded. The link stays active until it expires. The downloaded file matches the version the Payee approved. The Payee was notified. No W-9 is stored under any business.

### TC-RecipientRetrieves-02: The Business Recipient chooses Save to account

**Covers:** Alternate Path A8a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-7.
2. Business Recipient: Chooses Save to account instead of Download (A8a.1).
3. Verify the Business Recipient continues at Save Payee-Sent W-9 to Account (A8a.2).

**Expected Result:**
- Post-Condition (Alternate Path A8a exit): No download was logged, and the Business Recipient continues at Save Payee-Sent W-9 to Account.

### TC-RecipientRetrieves-03: The Business Recipient selects "I am not the right recipient"

**Covers:** Alternate Path A8b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-7.
2. Business Recipient: Selects "I am not the right recipient." (A8b.1).
3. Verify the Email Service delivers a notice to the Payee (A8b.4).

**Expected Result:**
- Post-Condition (Alternate Path A8b exit): The share status is Misdirected, the link is inactive, and the Payee was notified.

### TC-RecipientRetrieves-04: The Business Recipient downloads the W-9 again while the link is active

**Covers:** Alternate Path A15

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-14.
2. Business Recipient: Selects Download again (A15.1).
3. Verify inform9 delivers the W-9 as a PDF file (A15.3).
4. Verify no further notice goes to the Payee (A15.5).

**Expected Result:**
- Post-Condition (Alternate Path A15 exit): An additional download is logged and the Payee received no further notice.

### TC-RecipientRetrieves-05: The link is invalid, expired, or deactivated

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- The link is invalid, expired, or deactivated.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 shows a message that the sender must send the W-9 again (E2.2).

**Expected Result:**
- Post-Condition (Exception Path E2, E7, and E10a exit): No W-9 was shown or delivered.

### TC-RecipientRetrieves-06: The code is wrong or expired

**Covers:** Exception Path E7

**Preconditions:**
- Source use case Assumptions.
- The code is wrong or expired.

**Steps:**
1. Run Basic Path #1-6.
2. Business Recipient: Enters a code that is wrong or expired (E7.1).
3. Verify inform9 shows an error (E7.2).
4. Verify inform9 offers a new code (E7.3).
5. Verify the use case continues at Basic Path #4 (E7.5).

**Expected Result:**
- Post-Condition (Exception Path E2, E7, and E10a exit): No W-9 was shown or delivered.

### TC-RecipientRetrieves-07: The link expires before the download

**Covers:** Exception Path E10a

**Preconditions:**
- Source use case Assumptions.
- The link expires before the download.

**Steps:**
1. Run Basic Path #1-9.
2. Verify inform9 shows a message that the sender must send the W-9 again (E10a.2).

**Expected Result:**
- Post-Condition (Exception Path E2, E7, and E10a exit): No W-9 was shown or delivered.

### TC-RecipientRetrieves-08: The daily download cap is reached

**Covers:** Exception Path E10b

**Preconditions:**
- Source use case Assumptions.
- The daily download cap is reached.

**Steps:**
1. Run Basic Path #1-9.
2. Verify inform9 shows a message that the daily limit was reached and to try again later or save the W-9 to a free account (E10b.3).
3. Verify the Business Recipient can continue at Save Payee-Sent W-9 to Account while the link is active (E10b.4).

**Expected Result:**
- Post-Condition (Exception Path E10b exit): The blocked attempt is logged and no file was delivered.

---

## Save Payee-Sent W-9 to Account

**Source:** [Use Case: Save Payee-Sent W-9 to Account](use-cases.md#use-case-save-payee-sent-w-9-to-account)

### TC-SaveSentW9-01: Successful: Save Payee-Sent W-9 to Account

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Recipient: Selects Save to account (Basic Path #1).
2. Verify inform9 asks the Business Recipient to sign in or create a free account. See Create Account and Sign In (Basic Path #2).
3. Business Recipient: Signs in or completes sign-up (Basic Path #3).
4. Verify inform9 asks which business to store the W-9 under, or to add a new one (Basic Path #4).
5. Business Recipient: Selects or adds the business. See Add Business (Basic Path #5).

**Expected Result:**
- Post-Condition (Basic Path exit): A payee contact exists in the account, linked to the selected business, and counts toward the plan limit. The W-9 is stored under the business with source "Sent by Payee." The share status is Saved.

### TC-SaveSentW9-02: The Business Recipient is already signed in

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Verify the use case continues at Basic Path #4 (A2.2).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): The Business Recipient's session is unchanged, and the use case continues at Basic Path #4.

### TC-SaveSentW9-03: A payee contact with the sender's email already exists in the account

**Covers:** Alternate Path A6

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.

**Expected Result:**
- Post-Condition (Alternate Path A6 exit): The payee count is unchanged and a new W-9 version exists for the payee.

### TC-SaveSentW9-04: The account is at the plan limit and the Business Recipient declines to upgrade

**Covers:** Exception Path E6a

**Preconditions:**
- Source use case Assumptions.
- The account is at the plan limit and the Business Recipient declines to upgrade.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 explains the limit (E6a.2).
3. Verify inform9 offers an upgrade. See Upgrade After Free Limit (E6a.3).
4. Business Recipient: Declines the upgrade (E6a.4).
5. Verify nothing is saved, and downloads remain available until the link expires or the daily cap is reached (E6a.5).

**Expected Result:**
- Post-Condition (Exception Path E6a exit): No payee contact or W-9 record was created.

### TC-SaveSentW9-05: The account is at the plan limit and the Business Recipient upgrades

**Covers:** Exception Path E6b

**Preconditions:**
- Source use case Assumptions.
- The account is at the plan limit and the Business Recipient upgrades.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 offers an upgrade (E6b.2).
3. Business Recipient: Chooses to upgrade (E6b.3).
4. Verify the use case continues at Basic Path #6 after the upgrade completes (E6b.5).

**Expected Result:**
- Post-Condition (Exception Path E6b exit): The selected business and share are saved with the pending upgrade, no payee contact or W-9 record exists yet, and the use case continues at Basic Path #6 after the upgrade completes.

---

## Limit Unsolicited Sends

**Source:** [Use Case: Limit Unsolicited Sends](use-cases.md#use-case-limit-unsolicited-sends)

### TC-LimitSends-01: Successful: Limit Unsolicited Sends

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Approves a send (Basic Path #1).

**Expected Result:**
- Post-Condition (Basic Path exit): The send is allowed and counted in the Payee's 24-hour total.

### TC-LimitSends-02: The daily cap is reached

**Covers:** Exception Path E2a

**Preconditions:**
- Source use case Assumptions.
- The daily cap is reached.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 tells the Payee when sending is available again (E2a.2).

**Expected Result:**
- Post-Condition (Exception Path E2a, E3, and E4 exit): No share record was created, no email was sent, and the daily total is unchanged.

### TC-LimitSends-03: Sending patterns look abusive

**Covers:** Exception Path E2b

**Preconditions:**
- Source use case Assumptions.
- Sending patterns look abusive.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 pauses sending for the Payee (E2b.2).
3. Verify inform9 tells the Payee that inform9 is reviewing an issue flagged on their account (E2b.3).

**Expected Result:**
- Post-Condition (Exception Path E2b exit): No share record was created, no email was sent, the Payee's sending is paused, the Payee was told an issue is under review, and a flag is recorded for the inform9 administrator.

### TC-LimitSends-04: The recipient has opted out

**Covers:** Exception Path E3

**Preconditions:**
- Source use case Assumptions.
- The recipient has opted out.

**Steps:**
1. Run Basic Path #1-2.
2. Verify inform9 tells the Payee that the recipient does not accept W-9s through inform9 (E3.2).
3. Verify inform9 offers to let the Payee download their own W-9 to send another way (E3.3).

**Expected Result:**
- Post-Condition (Exception Path E2a, E3, and E4 exit): No share record was created, no email was sent, and the daily total is unchanged.

### TC-LimitSends-05: The Payee already sent to this recipient recently

**Covers:** Exception Path E4

**Preconditions:**
- Source use case Assumptions.
- The Payee already sent to this recipient recently.

**Steps:**
1. Run Basic Path #1-3.
2. Verify inform9 shows the earlier send and its status to the Payee (E4.2).

**Expected Result:**
- Post-Condition (Exception Path E2a, E3, and E4 exit): No share record was created, no email was sent, and the daily total is unchanged.

---

## Opt Out of Payee-Sent W-9s

**Source:** [Use Case: Opt Out of Payee-Sent W-9s](use-cases.md#use-case-opt-out-of-payee-sent-w-9s)

### TC-OptOut-01: Successful: Opt Out of Payee-Sent W-9s

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Recipient: Opens the opt-out link (Basic Path #1).
2. Verify inform9 shows the options: stop sends from this Payee, stop all payee-sent W-9s to this address, or report the send as unwanted or misdirected (Basic Path #2).
3. Business Recipient: Selects an option (Basic Path #3).
4. Business Recipient: Confirms the choice (Basic Path #4).
5. Verify inform9 shows the Business Recipient a confirmation (Basic Path #8).

**Expected Result:**
- Post-Condition (Basic Path exit): An opt-out record exists for the chosen scope, the share link is inactive, and the share status is Not accepted. Later sends in that scope are blocked by Limit Unsolicited Sends.

### TC-OptOut-02: The Business Recipient already opted out

**Covers:** Alternate Path A1

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Verify inform9 shows a confirmation that the opt-out is already in place (A1.2).

**Expected Result:**
- Post-Condition (Alternate Path A1 exit): The existing opt-out record is unchanged.

### TC-OptOut-03: The link is not recognized

**Covers:** Exception Path E1

**Preconditions:**
- Source use case Assumptions.
- The link is not recognized.

**Steps:**
1. Verify inform9 asks the Business Recipient for the email address to opt out (E1.2).
2. Business Recipient: Enters the email address (E1.3).
3. Verify inform9 requests a one-time code for that email address (E1.4).
4. Verify the Email Service delivers the one-time code (E1.5).
5. Business Recipient: Enters the code (E1.6).
6. Verify inform9 shows the Business Recipient a confirmation (E1.9).

**Expected Result:**
- Post-Condition (Exception Path E1 exit): An opt-out record exists for all payee-sent W-9s to the verified email address.

---

## Send W-9 Reminders

**Source:** [Use Case: Send W-9 Reminders](use-cases.md#use-case-send-w-9-reminders)

### TC-Reminders-01: Successful: Send W-9 Reminders

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Verify the Email Service delivers the reminder email to the Payee (Basic Path #7).

**Expected Result:**
- Post-Condition (Basic Path exit): One reminder email was delivered to the Payee, the reminder count increased by one, and the next reminder is scheduled at the configured interval.

### TC-Reminders-02: The Payee already received a reminder email today

**Covers:** Alternate Path A5

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-4.
2. Verify the reminder is processed again when it is due (A5.3).

**Expected Result:**
- Post-Condition (Alternate Path A5 exit): No email was sent today and the reminder is scheduled for the next day.

### TC-Reminders-03: The Payee has open requests from more than one business that are due

**Covers:** Alternate Path A6

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 creates one reminder email that lists each due request and its business, and includes the link, a Decline option, and an "I am not the right person" option (A6.1).
3. Verify the use case continues at Basic Path #7 (A6.2).

**Expected Result:**
- Post-Condition (Alternate Path A6 exit): One reminder email lists each due request and its business, and the use case continues at Basic Path #7.

### TC-Reminders-04: The Payee selects Decline in the email

**Covers:** Alternate Path A7a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-6.
2. Payee: Selects Decline in the reminder email (A7a.1).
3. Verify the Payee continues at Payee Declines Request (A7a.2).

**Expected Result:**
- Post-Condition (Alternate Path A7a exit): The Payee continues at Payee Declines Request.

### TC-Reminders-05: The Payee selects "I am not the right person"

**Covers:** Alternate Path A7b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-6.
2. Payee: Selects "I am not the right person." (A7b.1).
3. Verify the Payee continues at Payee Declines Request, Alternate Path A2 (A7b.2).

**Expected Result:**
- Post-Condition (Alternate Path A7b exit): The Payee continues at Payee Declines Request, Alternate Path A2.

### TC-Reminders-06: The request is no longer open

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- The request is no longer open.

**Steps:**
1. Run Basic Path #1.

**Expected Result:**
- Post-Condition (Exception Path E2, E4, and E7 exit): No reminders are scheduled for the request.

### TC-Reminders-07: The reminder cap has been reached

**Covers:** Exception Path E3

**Preconditions:**
- Source use case Assumptions.
- The reminder cap has been reached.

**Steps:**
1. Run Basic Path #1-2.
2. Verify the Email Service delivers a notice to the Business Owner that the request is still open and that reminders have ended (E3.4).
3. Verify the Business Owner can continue at Follow Up on Incomplete Request (E3.5).

**Expected Result:**
- Post-Condition (Exception Path E3 exit): The request status is Sent with the note Reminders ended, no reminders are scheduled, and the Business Owner was notified.

### TC-Reminders-08: The Payee's address bounced earlier or the Payee stopped reminders

**Covers:** Exception Path E4

**Preconditions:**
- Source use case Assumptions.
- The Payee's address bounced earlier or the Payee stopped reminders.

**Steps:**
1. Run Basic Path #1-3.
2. Verify the Email Service delivers a notice to the Business Owner that reminders stopped and why (E4.3).

**Expected Result:**
- Post-Condition (Exception Path E2, E4, and E7 exit): No reminders are scheduled for the request.

### TC-Reminders-09: The email bounces

**Covers:** Exception Path E7

**Preconditions:**
- Source use case Assumptions.
- The email bounces.

**Steps:**
1. Run Basic Path #1-6.
2. Verify the Email Service reports that the email bounced (E7.1).
3. Verify the Email Service delivers a notice to the Business Owner (E7.4).

**Expected Result:**
- Post-Condition (Exception Path E2, E4, and E7 exit): No reminders are scheduled for the request.

### TC-Reminders-10: The Payee selects Stop reminders

**Covers:** Alternate Path A7c

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-6.
2. Payee: Selects Stop reminders in the reminder email (A7c.1).
3. Verify the Email Service delivers a notice to the Business Owner of each affected request that the Payee stopped reminders (A7c.4).

**Expected Result:**
- Post-Condition (Alternate Path A7c exit): A reminder stop record exists for the email address, no reminders are scheduled for any open request to that address, and the Business Owner of each affected request was notified.

---

## Set Reminder Schedule

**Source:** [Use Case: Set Reminder Schedule](use-cases.md#use-case-set-reminder-schedule)

### TC-ReminderSchedule-01: Successful: Set Reminder Schedule

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens the reminder settings for a business (Basic Path #1).
2. Verify inform9 shows the current interval, cap, and whether reminders are on (Basic Path #2).
3. Business Owner: Enters the number of days between reminders (Basic Path #3).
4. Business Owner: Enters the maximum number of reminders (Basic Path #4).
5. Business Owner: Selects Save (Basic Path #5).
6. Verify inform9 confirms that the new schedule applies to future requests (Basic Path #8).

**Expected Result:**
- Post-Condition (Basic Path exit): The business has the saved interval and cap. Open requests are unchanged. Future requests for the business use the new schedule.

### TC-ReminderSchedule-02: The Business Owner turns reminders off

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1.
2. Business Owner: Selects Turn off reminders (A2.1).
3. Verify inform9 confirms the change (A2.3).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): Reminders are off for the business and future requests schedule none.

### TC-ReminderSchedule-03: The Business Owner applies the schedule to open requests

**Covers:** Alternate Path A8

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-7.
2. Business Owner: Selects Apply to open requests (A8.1).

**Expected Result:**
- Post-Condition (Alternate Path A8 exit): Each open request has a recalculated next reminder date.

### TC-ReminderSchedule-04: The interval or cap is outside the allowed limits

**Covers:** Exception Path E6a

**Preconditions:**
- Source use case Assumptions.
- The interval or cap is outside the allowed limits.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 shows the allowed ranges (E6a.2).
3. Verify the use case continues at Basic Path #3 (E6a.3).

**Expected Result:**
- Post-Condition (Exception Path E6a and E6b exit): The saved schedule is unchanged.

### TC-ReminderSchedule-05: The plan does not allow changes

**Covers:** Exception Path E6b

**Preconditions:**
- Source use case Assumptions.
- The plan does not allow changes.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 explains that the default schedule applies on the free plan (E6b.2).
3. Verify inform9 offers an upgrade. See Upgrade After Free Limit (E6b.3).

**Expected Result:**
- Post-Condition (Exception Path E6a and E6b exit): The saved schedule is unchanged.

---

## Configure Platform Settings

**Source:** [Use Case: Configure Platform Settings](use-cases.md#use-case-configure-platform-settings)

### TC-PlatformSettings-01: Successful: Configure Platform Settings

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Administrator: Opens Settings (Basic Path #1).
2. Verify inform9 shows the setting groups (Basic Path #2).
3. Administrator: Selects a group (Basic Path #3).
4. Verify inform9 shows each setting with its current value, default, and allowed range (Basic Path #4).
5. Administrator: Enters one or more new values (Basic Path #5).
6. Administrator: Selects Save (Basic Path #6).
7. Verify inform9 confirms the change and names the values that apply only to items created afterward (Basic Path #10).

**Expected Result:**
- Post-Condition (Basic Path exit): Each saved value equals the entered value. The audit log holds the Administrator, the old values, the new values, and the time. Items created before the change keep the values they were created with, where the setting applies only to later items.

### TC-PlatformSettings-02: The Administrator restores a default

**Covers:** Alternate Path A5a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-4.
2. Administrator: Selects Restore default for a setting (A5a.1).
3. Verify inform9 fills in the default value (A5a.2).

**Expected Result:**
- Post-Condition (Alternate Path A5a exit): The entry holds the default, and the use case continues at Basic Path #6.

### TC-PlatformSettings-03: The Administrator enters a provider key

**Covers:** Alternate Path A5b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-4.
2. Administrator: Enters a key in the write-only field (A5b.1).
3. Verify inform9 shows only the last four characters (A5b.4).

**Expected Result:**
- Post-Condition (Alternate Path A5b exit): The key is stored encrypted, only its last four characters are shown, and the audit log has no key value.

### TC-PlatformSettings-04: The Administrator sends a test email

**Covers:** Alternate Path A6a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Selects Send test email and enters an address (A6a.1).
3. Verify the Email Service delivers the test message (A6a.3).
4. Verify inform9 shows the result (A6a.4).

**Expected Result:**
- Post-Condition (Alternate Path A6a and A6b exits): One test message was sent, or one key check was made. Nothing else changed.

### TC-PlatformSettings-05: The Administrator tests the payment connection

**Covers:** Alternate Path A6b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Selects Test payment connection (A6b.1).
3. Verify inform9 shows the result (A6b.4).

**Expected Result:**
- Post-Condition (Alternate Path A6a and A6b exits): One test message was sent, or one key check was made. Nothing else changed.

### TC-PlatformSettings-06: The Administrator edits an email message

**Covers:** Alternate Path A6c

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Opens Email messages and selects a message (A6c.1).
3. Administrator: Edits the text and selects Save (A6c.3).
4. Verify inform9 saves the text as a new version (A6c.5).

**Expected Result:**
- Post-Condition (Alternate Path A6c exit): The message has a new version with the edited text, and the change is in the audit log.

### TC-PlatformSettings-07: The Administrator cancels

**Covers:** Alternate Path A6d

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Selects Cancel (A6d.1).
3. Verify inform9 discards the entries (A6d.2).

**Expected Result:**
- Post-Condition (Alternate Path A6d exit): The saved settings are unchanged.

### TC-PlatformSettings-08: A value is outside its allowed range

**Covers:** Exception Path E7

**Preconditions:**
- Source use case Assumptions.
- A value is outside its allowed range.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 shows the allowed range next to the value (E7.2).
3. Verify the use case continues at Basic Path #5 (E7.3).

**Expected Result:**
- Post-Condition (Exception Path E7 exit): The saved settings are unchanged, and the use case continues at Basic Path #5.

### TC-PlatformSettings-09: The values cannot be saved

**Covers:** Exception Path E8

**Preconditions:**
- Source use case Assumptions.
- The values cannot be saved.

**Steps:**
1. Run Basic Path #1-7.
2. Verify inform9 shows an error and keeps the entries on screen (E8.2).
3. Verify the use case continues at Basic Path #6 (E8.3).

**Expected Result:**
- Post-Condition (Exception Path E8 exit): No value was saved, the entries remain on screen, and the use case continues at Basic Path #6.

### TC-PlatformSettings-10: The test email fails

**Covers:** Exception Path E6a

**Preconditions:**
- Source use case Assumptions.
- The Email Service reports an error.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Selects Send test email (A6a.1).
3. Verify inform9 shows the error without showing the key (E6a.2).

**Expected Result:**
- Post-Condition (Exception Path E6a exit): No setting changed, and the use case continues at Basic Path #5.

---

## Export Payee Data

**Source:** [Use Case: Export Payee Data](use-cases.md#use-case-export-payee-data)

### TC-ExportData-01: Successful: Export Payee Data

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens Export (Basic Path #1).
2. Verify inform9 shows the businesses, the file formats, and the taxpayer ID options (Basic Path #2).
3. Business Owner: Selects one business or all businesses (Basic Path #3).
4. Business Owner: Selects a CSV format (Basic Path #4).
5. Verify inform9 shows that the taxpayer ID will be masked to the last four digits (Basic Path #5).
6. Business Owner: Selects Export (Basic Path #6).
7. Verify inform9 delivers the file for download (Basic Path #10).

**Expected Result:**
- Post-Condition (Basic Path exit): The Business Owner received a CSV with one row per payee that has a completed W-9. The taxpayer ID is masked. The export is logged. No payee or W-9 record changed.

### TC-ExportData-02: The Business Owner selects the ZIP of W-9 PDFs

**Covers:** Alternate Path A4

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-3.
2. Business Owner: Selects ZIP of W-9 PDFs (A4.1).
3. Verify inform9 explains that the PDFs show the full taxpayer ID and asks the Business Owner to re-enter their password (A4.2).
4. Business Owner: Re-enters their password (A4.3).
5. Verify inform9 delivers the file for download (A4.8).

**Expected Result:**
- Post-Condition (Alternate Path A4 exit): The Business Owner received a ZIP with the latest signed W-9 for each payee. The export is logged.

### TC-ExportData-03: The Business Owner chooses the full taxpayer ID

**Covers:** Alternate Path A5

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-4.
2. Business Owner: Chooses to include the full taxpayer ID (A5.1).
3. Verify inform9 warns that the file will hold unencrypted taxpayer IDs and asks the Business Owner to re-enter their password (A5.2).
4. Business Owner: Re-enters their password (A5.3).
5. Verify the use case continues at Basic Path #6 (A5.6).

**Expected Result:**
- Post-Condition (Alternate Path A5 exit): Use case continues in the Basic Path. The CSV then holds the full taxpayer ID, and the export log records the full option.

### TC-ExportData-04: No selected payee has a completed W-9

**Covers:** Exception Path E8

**Preconditions:**
- Source use case Assumptions.
- No selected payee has a completed W-9.

**Steps:**
1. Run Basic Path #1-7.
2. Verify inform9 shows a message that nothing is available to export (E8.2).
3. Verify the use case continues at Basic Path #3 (E8.3).

**Expected Result:**
- Post-Condition (Exception Path E5 and E8 exit): No file was delivered and nothing is logged.

### TC-ExportData-05: The password is wrong

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- The password is wrong.

**Steps:**
1. Run Basic Path #1-4.
2. Business Owner: Chooses to include the full taxpayer ID (A5.1).
3. Verify inform9 warns that the file will hold unencrypted taxpayer IDs and asks the Business Owner to re-enter their password (A5.2).
4. Business Owner: Re-enters their password (A5.3).
5. Verify inform9 shows an error and keeps the taxpayer ID option at masked (E5.2).
6. Verify the use case continues at Basic Path #5 (E5.3).

**Expected Result:**
- Post-Condition (Exception Path E5 and E8 exit): No file was delivered and nothing is logged.

### TC-ExportData-06: The file cannot be built

**Covers:** Exception Path E9

**Preconditions:**
- Source use case Assumptions.
- The file cannot be built.

**Steps:**
1. Run Basic Path #1-8.
2. Verify inform9 shows an error and offers to try again (E9.2).
3. Verify the use case continues at Basic Path #6 (E9.4).

**Expected Result:**
- Post-Condition (Exception Path E9 exit): No file was delivered, no successful export is logged, an alert was raised for the inform9 administrator, and the use case continues at Basic Path #6.

---

## Manage Communication Preferences

**Source:** [Use Case: Manage Communication Preferences](use-cases.md#use-case-manage-communication-preferences)

### TC-Preferences-01: Successful: Manage Communication Preferences

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens Communication Preferences (Basic Path #1).
2. Verify inform9 shows the current update preference and a list of emails that always apply (Basic Path #2).
3. Business Owner: Changes the update preference (Basic Path #3).
4. Business Owner: Selects Save (Basic Path #4).
5. Verify inform9 confirms the change (Basic Path #6).

**Expected Result:**
- Post-Condition (Basic Path exit): The account holds the new update preference with the date and time of the change. Request, reminder, notice, and receipt emails are unchanged.

### TC-Preferences-02: A Payee changes the preference

**Covers:** Alternate Path A1a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Opens Communication Preferences (A1a.1).
2. Verify inform9 shows the current update preference and a list of emails that always apply (A1a.2).
3. Payee: Changes the update preference (A1a.3).
4. Payee: Selects Save (A1a.4).
5. Verify inform9 confirms the change (A1a.6).

**Expected Result:**
- Post-Condition (Alternate Path A1a exit): The account holds the new update preference with the date and time of the change.

### TC-Preferences-03: The account holder unsubscribes from an update email

**Covers:** Alternate Path A1b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens the unsubscribe link in an update email (A1b.1).
2. Verify inform9 shows a confirmation that no more update emails will be sent (A1b.4).

**Expected Result:**
- Post-Condition (Alternate Path A1b exit): The account holds an unchecked update preference with the date and time of the change, and no update emails are sent to it.

### TC-Preferences-04: The preference cannot be saved

**Covers:** Exception Path E5

**Preconditions:**
- Source use case Assumptions.
- The preference cannot be saved.

**Steps:**
1. Run Basic Path #1-4.
2. Verify inform9 shows an error and keeps the earlier preference (E5.2).
3. Verify the use case continues at Basic Path #3 (E5.3).

**Expected Result:**
- Post-Condition (Exception Path E5 exit): The earlier preference is unchanged, and the use case continues at Basic Path #3.

---

---

## Cancel Request

**Source:** [Use Case: Cancel Request](use-cases.md#use-case-cancel-request)

### TC-CancelRequest-01: Successful: Cancel Request

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens the payee list for a business (Basic Path #1).
2. Business Owner: Selects a payee with an open request (Basic Path #2).
3. Business Owner: Selects Cancel Request (Basic Path #3).
4. Verify inform9 explains that the link stops working, reminders stop, and the payee is not told (Basic Path #4).
5. Business Owner: Confirms the cancellation (Basic Path #5).
6. Verify inform9 shows the payee as Not requested (Basic Path #10).

**Expected Result:**
- Post-Condition (Basic Path exit): The request status is Canceled, the link is inactive, no reminders are scheduled, and the payee shows as Not requested. No email was sent to the Payee. The payee still counts toward the plan limit.

### TC-CancelRequest-02: The Business Owner changes their mind

**Covers:** Alternate Path A5

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-4.
2. Business Owner: Closes the confirmation without canceling (A5.1).
3. Verify the request stays open (A5.2).

**Expected Result:**
- Post-Condition (Alternate Path A5 exit): The request status is unchanged.

### TC-CancelRequest-03: The request is no longer open

**Covers:** Exception Path E6

**Preconditions:**
- Source use case Assumptions.
- The Payee completed, declined, or bounced the request after the Business Owner opened the list.

**Steps:**
1. Run Basic Path #1-5.
2. Verify inform9 shows the current status of the request (E6.2).
3. Verify inform9 cancels nothing (E6.3).

**Expected Result:**
- Post-Condition (Exception Path E6 exit): The request is unchanged and nothing was canceled.

---

## Edit or Archive Payee

**Source:** [Use Case: Edit or Archive Payee](use-cases.md#use-case-edit-or-archive-payee)

### TC-EditPayee-01: Successful: Edit or Archive Payee

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens the payee list for a business (Basic Path #1).
2. Business Owner: Selects a payee (Basic Path #2).
3. Business Owner: Selects Edit Payee (Basic Path #3).
4. Business Owner: Changes the name, the email address, or the linked businesses (Basic Path #5).
5. Business Owner: Selects Save (Basic Path #6).
6. Verify inform9 shows the updated payee in the payee list (Basic Path #9).

**Expected Result:**
- Post-Condition (Basic Path exit): The payee contact holds the entered name, email address, and linked businesses. The payee count is unchanged. Completed W-9s and their earlier versions are unchanged.

### TC-EditPayee-02: The Business Owner restores an archived payee

**Covers:** Alternate Path A1

**Preconditions:**
- Source use case Assumptions.
- An archived payee exists and the account is under the plan limit.

**Steps:**
1. Business Owner: Filters the payee list to archived payees and selects Restore for a payee (A1.1).
2. Verify inform9 returns the payee to the active list with the status it had before it was archived (A1.3).

**Expected Result:**
- Post-Condition (Alternate Path A1 exit): The payee is active and counts toward the plan limit.

### TC-EditPayee-03: The Business Owner archives the payee

**Covers:** Alternate Path A3

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-3.
2. Business Owner: Selects Archive Payee (A3.1).
3. Verify inform9 explains that open requests will be canceled, completed W-9s stay available, and the payee stops counting toward the plan limit (A3.2).
4. Business Owner: Confirms (A3.3).
5. Verify inform9 cancels each open request for the payee (A3.4).

**Expected Result:**
- Post-Condition (Alternate Path A3 exit): The payee status is Archived, each open request is Canceled with its link inactive and no reminders scheduled, the payee is not in the active payee count, and completed W-9s remain available to download.

### TC-EditPayee-04: The email address changed and the payee has an open request

**Covers:** Alternate Path A8

**Preconditions:**
- Source use case Assumptions.
- The payee has an open request.
- The Business Owner changed the email address in Basic Path #5.

**Steps:**
1. Run Basic Path #1-8.
2. Verify inform9 offers to resend the request to the new email address (A8.2).
3. Business Owner: Accepts (A8.3).
4. Verify the Business Owner continues at Follow Up on Incomplete Request (A8.4).

**Expected Result:**
- Post-Condition (Alternate Path A8 exit): The payee holds the new email address and the Business Owner continues at Follow Up on Incomplete Request.

### TC-EditPayee-05: The account is at the plan limit

**Covers:** Exception Path E1

**Preconditions:**
- Source use case Assumptions.
- An archived payee exists.
- Restoring the payee would exceed the plan limit.

**Steps:**
1. Business Owner: Filters the payee list to archived payees and selects Restore for a payee (A1.1).
2. Verify inform9 explains the limit (E1.2).
3. Verify inform9 offers an upgrade (E1.3).

**Expected Result:**
- Post-Condition (Exception Path E1 exit): The payee remains archived and the payee count is unchanged.

### TC-EditPayee-06: An entry is missing or invalid

**Covers:** Exception Path E7a

**Preconditions:**
- Source use case Assumptions.
- An entry is missing or invalid.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 highlights the fields to correct (E7a.2).
3. Verify the use case continues at Basic Path #5 (E7a.3).

**Expected Result:**
- Post-Condition (Exception Path E7a and E7b exits): No change was saved, and the use case continues at Basic Path #5.

### TC-EditPayee-07: Another payee in the account has the same email address

**Covers:** Exception Path E7b

**Preconditions:**
- Source use case Assumptions.
- Another payee in the account has the same email address.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 shows the other payee and explains that each email address needs one payee (E7b.2).
3. Verify the use case continues at Basic Path #5 (E7b.3).

**Expected Result:**
- Post-Condition (Exception Path E7a and E7b exits): No change was saved, and the use case continues at Basic Path #5.

---

## Edit Business

**Source:** [Use Case: Edit Business](use-cases.md#use-case-edit-business)

### TC-EditBusiness-01: Successful: Edit Business

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Opens the business list (Basic Path #1).
2. Business Owner: Selects a business (Basic Path #2).
3. Business Owner: Selects Edit Business (Basic Path #3).
4. Business Owner: Changes one or more of the fields (Basic Path #5).
5. Business Owner: Selects Save (Basic Path #6).
6. Verify inform9 confirms that the changes apply to forms shown to payees from now on (Basic Path #9).

**Expected Result:**
- Post-Condition (Basic Path exit): The business record holds the new name, address, and notification email. W-9s already signed keep the requester name and address they were signed with. A payee who opens an open request link later sees the new name and address.

### TC-EditBusiness-02: A required field is empty

**Covers:** Exception Path E7a

**Preconditions:**
- Source use case Assumptions.
- A required field is empty.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 highlights the missing fields (E7a.2).
3. Verify the use case continues at Basic Path #5 (E7a.3).

**Expected Result:**
- Post-Condition (Exception Path E7a and E7b exits): The business record is unchanged, and the use case continues at Basic Path #5.

### TC-EditBusiness-03: Another business in the account has the same name

**Covers:** Exception Path E7b

**Preconditions:**
- Source use case Assumptions.
- Another business in the account has the same name.

**Steps:**
1. Run Basic Path #1-6.
2. Verify inform9 shows a message that each business needs its own distinct legal name (E7b.2).
3. Verify the use case continues at Basic Path #5 (E7b.3).

**Expected Result:**
- Post-Condition (Exception Path E7a and E7b exits): The business record is unchanged, and the use case continues at Basic Path #5.

---

## Review Abuse Flags

**Source:** [Use Case: Review Abuse Flags](use-cases.md#use-case-review-abuse-flags)

### TC-ReviewAbuse-01: Successful: Review Abuse Flags

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Administrator: Opens the list of flags (Basic Path #1).
2. Administrator: Selects a flag (Basic Path #3).
3. Administrator: Reviews the details (Basic Path #5).
4. Administrator: Selects Lift pause and enters a note (Basic Path #6).
5. Verify the Email Service delivers a notice to the Payee that sending is available again (Basic Path #10).

**Expected Result:**
- Post-Condition (Basic Path exit): Sending is available for the Payee, the flag is Reviewed, the decision is in the audit log, and the Payee was notified.

### TC-ReviewAbuse-02: The Administrator keeps the pause

**Covers:** Alternate Path A6a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Selects Keep pause and enters a note (A6a.1).
3. Verify inform9 records the Administrator, the decision, the note, and the time in the audit log (A6a.4).

**Expected Result:**
- Post-Condition (Alternate Path A6a exit): Sending stays paused, the flag is Reviewed, and the decision is in the audit log.

### TC-ReviewAbuse-03: The Administrator blocks the Payee from sending

**Covers:** Alternate Path A6b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-5.
2. Administrator: Selects Block sending and enters a note (A6b.1).
3. Verify the Email Service delivers a notice to the Payee that sending is blocked (A6b.5).

**Expected Result:**
- Post-Condition (Alternate Path A6b exit): The Payee is blocked from sending, the flag is Reviewed, the decision is in the audit log, and the Payee was notified.

### TC-ReviewAbuse-04: No flags are open

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- No flags are open.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 shows a message that nothing needs review (E2.2).

**Expected Result:**
- Post-Condition (Exception Path E2 exit): Nothing changed.

---

## Sign Out

**Source:** [Use Case: Sign Out](use-cases.md#use-case-sign-out)

### TC-SignOut-01: Successful: Sign Out

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Business Owner: Selects Sign out (Basic Path #1).
2. Verify inform9 shows the sign-in page (Basic Path #4).

**Expected Result:**
- Post-Condition (Basic Path exit): The session is ended and cannot be used again. The password confirmation saved for downloads is discarded.

### TC-SignOut-02: A Payee signs out

**Covers:** Alternate Path A1a

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Selects Sign out (A1a.1).
2. Verify inform9 shows the sign-in page (A1a.3).

**Expected Result:**
- Post-Condition (Alternate Path A1a exit): The session is ended, and the password confirmation is discarded.

### TC-SignOut-03: The session times out

**Covers:** Alternate Path A1b

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Leave the session without activity for [IDLE_MINUTES] minutes.
2. Verify inform9 shows the sign-in page with a message that the session ended (A1b.3).

**Expected Result:**
- Post-Condition (Alternate Path A1b exit): The session is ended, and the password confirmation is discarded.

---

## View Sent W-9s

**Source:** [Use Case: View Sent W-9s](use-cases.md#use-case-view-sent-w-9s)

### TC-ViewShares-01: Successful: View Sent W-9s

**Covers:** Basic Path

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Payee: Opens Sent W-9s (Basic Path #1).
2. Verify inform9 shows each send with the recipient email address, the date sent, and a status (Basic Path #2).
3. Payee: Selects a send (Basic Path #3).
4. Verify inform9 shows the recipient email address, the business name entered, the date sent, the link expiry date, the W-9 version sent, and the date of each status change (Basic Path #4).

**Expected Result:**
- Post-Condition (Basic Path exit): No records changed. The Payee saw only sends made from their own account.

### TC-ViewShares-02: The Payee filters by status

**Covers:** Alternate Path A2

**Preconditions:**
- Source use case Assumptions.

**Steps:**
1. Run Basic Path #1-2.
2. Payee: Selects a status filter (A2.1).
3. Verify inform9 refreshes the list for the current view (A2.3).

**Expected Result:**
- Post-Condition (Alternate Path A2 exit): The selected status filter is saved as the current view, and the list shows that view.

### TC-ViewShares-03: The Payee sends the W-9 again

**Covers:** Alternate Path A4

**Preconditions:**
- Source use case Assumptions.
- A send has status Delivery failed, or its link expired.

**Steps:**
1. Run Basic Path #1-4.
2. Payee: Selects Send again (A4.1).
3. Verify inform9 starts Payee Sends W-9 to Business with the business name and recipient email address filled in (A4.2).

**Expected Result:**
- Post-Condition (Alternate Path A4 exit): No records changed, and the Payee continues at Payee Sends W-9 to Business.

### TC-ViewShares-04: The Payee has no sends

**Covers:** Exception Path E2

**Preconditions:**
- Source use case Assumptions.
- The Payee has no sends.

**Steps:**
1. Run Basic Path #1.
2. Verify inform9 shows a message and offers Send W-9 (E2.2).

**Expected Result:**
- Post-Condition (Exception Path E2 exit): No records changed.
