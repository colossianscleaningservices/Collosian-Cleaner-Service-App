# Required APIs

Backend API specification for the CCS platform (auth, client, cleaner, common).

---

## 1. Auth

- **Login** — POST: Email + password → token + user (role, name, etc.)
- **Register** — POST: Sign up (name, email, password, role_id, optional NI number for cleaner)
- **Logout** — POST: Invalidate token / logout session
- **Forgot password** — POST: Request reset (e.g. send email with token/link)
- **Reset password** — POST: Set new password (token + new_password + password_confirmation)
- **Me / current user** — GET: Return current authenticated user profile and role

---

## 2. User / Profile (shared or role-specific)

- **Change password** — POST/PUT: Current password + new password
- **Get profile** — GET: Current user profile (client or cleaner)
- **Update profile (client)** — PUT/PATCH: Update client profile (e.g. name, phone, postal code)
- **Update profile (cleaner)** — PUT/PATCH: Update cleaner profile (e.g. name, phone, postal code,
  delete-account flag)
- **Save device details** — POST/PUT: Save device details (platform, app version, debug or not, IP,
  timezone, OneSignal player id)
- **Delete account** — DELETE: Optional; delete cleaner account

---

## 3. Assessment (cleaner)

- **Fetch assessment categories** — GET: List assessment categories
- **Fetch cleaner assessment category forms** — GET: Get assessment forms for a cleaner (by category
  or all)
- **Save assessment forms** — POST/PUT: Submit/save assessment form responses
- **Save gov code** — POST/PUT: Save government code (e.g. verification code, compliance code)

---

## 4. Client – Properties

- **List properties** — GET: Client's properties
- **Get property** — GET: Single property by id
- **Create property** — POST: Add property (address, postal code, type, etc.)
- **Update property** — PUT/PATCH: Edit property
- **Delete property** — DELETE: Remove property

---

## 5. Client – Jobs

- **List jobs (client)** — GET: Client's jobs; support filters/dates as needed
- **Get job detail** — GET: Single job by id
- **Create job** — POST: Create job (property, date, time, options, notes)
- **Update job** — PUT/PATCH: Edit job
- **Schedule job** — PUT/PATCH: Set/update schedule (start_date, start_time, end_date, end_time,
  recurrence)
- **Cancel job** — PUT/PATCH or POST: Cancel job
- **Delete job** — DELETE: Delete job
- **Submit review** — POST: Add review for a job/cleaner (visit feedback, rating, message)

---

## 6. Client – Preferred staff

- **List preferred staff** — GET: Client's preferred cleaners
- **Add preferred staff** — POST: Add cleaner to client's preferred list
- **Remove preferred staff** — DELETE: Remove cleaner from client's preferred list

---

## 7. Cleaner – Jobs & Availability

- **List jobs (cleaner)** — GET: Cleaner's assigned/available jobs
- **Get job detail (cleaner)** — GET: Single job for cleaner
- **Accept job** — POST/PUT: Cleaner accepts job
- **Decline job** — POST/PUT: Cleaner declines job
- **List availability** — GET: Cleaner's weekly schedule + blocked days
- **Update availability** — PUT/PATCH: Save weekly schedule and blocked days

---

## 8. Cleaner – Documents & References

- **List support documents** — GET: Cleaner's documents (type, number, expiry, file)
- **Upload/add document** — POST: Add document (type, number, expiry, file)
- **Update document** — PUT/PATCH: Edit document
- **Delete document** — DELETE: Remove document
- **List references** — GET: Cleaner's references
- **Add reference** — POST: Add reference (name, phone, email, company, relationship)
- **Update reference** — PUT/PATCH: Edit reference
- **Delete reference** — DELETE: Remove reference

---

## 9. Cleaner – Other

- **Payout computation / earnings** — GET: Cleaner earnings/payout summary
- **Action-needed count** — GET: Optional; count of items needing action
- **Profile completion status** — GET: Optional; whether profile is complete
- **List reviews (cleaner)** — GET: Reviews received by cleaner

---

## 10. Common – Notifications, Chat, Support, Training

- **List notifications** — GET: Notifications for current user (client or cleaner)
- **Mark notification read** — PUT/PATCH: Mark one or many as read
- **List chat threads** — GET: Optional; list of conversations
- **List messages** — GET: Messages for a conversation/thread
- **Send message** — POST: Send text (and optionally image)
- **Delete message(s)** — DELETE: Delete own message(s)
- **Contact us / support** — POST: Submit contact form (name, email, message)
- **Help/FAQ content** — GET: Optional; static or dynamic help/support content
- **List training resources** — GET: Videos, flyers, links

---

## Summary

| Section                          | Count   |
|----------------------------------|---------|
| Auth                             | 6       |
| User / Profile                   | 6       |
| Assessment (cleaner)             | 4       |
| Client – Properties              | 5       |
| Client – Jobs                    | 8       |
| Client – Preferred staff         | 3       |
| Cleaner – Jobs & Availability    | 6       |
| Cleaner – Documents & References | 8       |
| Cleaner – Other                  | 4       |
| Common                           | 9       |
| **Total**                        | **~56** |

---

*This document may change based on requirements.*
