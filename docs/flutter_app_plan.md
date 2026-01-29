# CCS Flutter App — Comprehensive Plan

This document captures the complete feature set, modules, use-cases, workflows, and business rules for the Flutter mobile application. It is derived from the SRS and aligned with confirmed decisions.

---

## 1. Platform Scope

| User Type | Platform |
|-----------|----------|
| Admin / Super Admin | Web Portal (Laravel) — NOT in mobile app |
| Client (Customer) | Mobile App (iOS & Android) |
| Cleaner (Staff) | Mobile App (iOS & Android) |

**Key Decision:** Single mobile app with role selection at onboarding. Admin functionality is web-only.

---

## 2. Architecture Overview

- **Backend:** Laravel (REST API, v1 versioning)
- **Mobile App:** Flutter (single app, role-based UI)
- **Authentication:** JWT tokens in headers
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **File Storage:** Ionos (server-level, not app-managed)
- **Real-time Sync:** All data centralized; actions reflect instantly across roles

---

## 3. Role-Based App Experience

### 3.1 Role Selection Flow
- On first launch or registration, user selects: **"I am a Client"** or **"I am a Cleaner"**
- Based on selection:
  - Relevant onboarding flow is shown
  - Only role-specific features are enabled
- Backend enforces role permissions on every API request
- A user can never access features outside their assigned role

### 3.2 Client Role Features
After login as Client, the app displays:
- Client dashboard
- Property management
- Job creation and calendar
- Job tracking and notifications
- Preferred staff selection
- Profile management

### 3.3 Cleaner Role Features
After login as Cleaner, the app displays:
- Cleaner dashboard
- Job assignments and acceptance
- Check-in / check-out
- Availability management
- Work hours and payment view
- Training, documents, references, and reviews

---

## 4. Authentication & Onboarding

### 4.1 Client Registration
**Flow:**
1. User selects "I am a Client"
2. Registration form displayed

**Form Fields:**
- First Name* (required)
- Last Name* (required)
- Email* (required, unique)
- Gender (optional)
- Date of Birth (optional)
- Phone Number* (required, validated)
- Address* (required)
- City* (required)
- Postal Code* (required)
- Company Name (optional)
- Password* (required, min 8 chars, alphanumeric + special)

**Validations:**
- Email must be unique
- Phone number format validated
- Password meets security standards

**Post-Registration:**
- Account created
- Redirect to Dashboard
- Optional welcome email sent

---

### 4.2 Cleaner Registration (Multi-Step Onboarding)

**Step 1: Assessment**
- Mandatory for every new cleaner
- Content: basic cleaning knowledge, safety awareness, service expectations
- Configuration: question count, pass threshold, retry cooldown — all backend dynamic
- Pass → proceed to Step 2
- Fail → cannot proceed; retry allowed after cooldown (backend configured)

**Step 2: Government Verification**
- Redirect to official government verification site
- Cleaner fills required personal/legal details (ID, passport, work permit)
- Government system generates a verification code
- App shows "Verification Pending" status

**Step 3: Verification Code Submission**
- Cleaner returns to app after government verification
- Enters government-issued verification code
- System validates code against backend/API
- Success → proceed to full registration
- Failure → retry option; admin notified if repeated failures

**Step 4: Full Registration Form**

**Personal Information:**
- First Name* | Last Name* | Email* | Phone Number*
- Address* | City* | Postal Code*
- Date of Birth* | National Insurance Number* (format: AA123456C)

**Next of Kin Details:**
- Full Name* | Relationship* (dropdown) | Contact Number*

**Work Information:**
- Preferred Start Date*
- Do you drive? (Yes/No)
- Local Areas Willing to Work (multi-select)
- Do you have children? (Yes/No)
- Cleaning Services Capability (checklist):
  - Kitchen Area tasks
  - Bathroom/Toilet tasks
  - Bedroom/Living Room tasks
  - Ironing Services

**Banking Details:**
- Bank Name* | Account Holder Name* | Account Number* | Sort Code*

**Account & Security:**
- Gender (dropdown)
- Password*
- Verification Code (pre-validated from Step 3)

**Step 5: OTP Verification**
- OTP sent to registered mobile number
- Cleaner enters OTP in app
- Success → proceed to first login
- Failure → retry allowed; 60 second cooldown between retries
- Expired OTP → request new (60 second cooldown)

**Post-Registration:**
- Cleaner automatically logged in
- Redirect to Cleaner Dashboard

---

### 4.3 Login Flow
1. Email + Password entry
2. API call → JWT returned
3. Store JWT in secure storage
4. Get user role from API response
5. Route to role-specific dashboard

---

### 4.4 First Login Experience

**Client First Login:**
- Welcome popup displayed
- Quick action steps:
  1. Complete Profile (verify email if pending)
  2. Create Property
  3. Create Jobs

**Cleaner First Login:**
- Welcome popup displayed
- Quick action steps:
  1. Complete Profile
  2. Add Available Slots
  3. Upload Documents
  4. View Calendar

**Popup Behavior:**
- Shown only once, until all required setup steps are completed
- "Remind Me Later" option available
- System continues to show reminders until setup finished

---

## 5. Client Modules & Features

### 5.1 Profile Management

**Profile Photo:**
- Required
- Upload/change photo
- Max 5 MB (JPG, PNG)

**Editable Fields:**
- First Name, Last Name, Phone Number
- Address, City, Postal Code
- Date of Birth, Gender, Company Name
- Enable reminders via Email/SMS (toggle)
- Change Password

**Read-Only:**
- Email (message: "To update your email, contact support@...")

**Profile Completion:**
- Progress indicator (e.g., 75%)
- Required fields highlighted until completed

**Account Actions:**
- Delete My Account (confirmation required)

---

### 5.2 Property Management

**Purpose:** Store properties where cleaning services are needed. At least one property required before booking jobs.

**Property List:**
- Displays all client properties
- Columns: Property Name, Business Type, Address, City, Postal Code, Property Type
- Actions: Edit, Delete

**Add Property Form:**
- Property Name* (required)
- Business Type* (Residential / Commercial)
- Address* | City* | Postal Code*
- Type of Property* (Office, Flat, House, etc.)
- Do you have a Hoover? (Yes/No)
- Do you have a Washing Machine? (Yes/No)
- Cleaning Products Provided? (Yes/No)
- Do you have a Dryer? (Yes/No)
- Staff Preference (Male / Female / No Preference)
- Access to Property (Client Will Open / Provide Keys / Other)
- Do you have animals? (Yes/No)
- Additional Details (bedrooms, bathrooms, living rooms, etc.)

**Business Rules:**
- Property type determines payment routing (residential vs commercial)
- Property details auto-fill during job creation

---

### 5.3 Job Creation

**Purpose:** Client initiates the core workflow by creating a job.

**Form Fields:**
- Select Property*
- Payment Method (Residential / Commercial)
- Job Start Date* | Start Time* | End Time*
- Number of Cleaners Required*
- Cleaning Type (Office, Standard, Deep Clean, etc.)
- Additional Instructions (max 100 characters)
- Equipment toggles: Hoover, Washing Machine, Cleaning Products, Dryer
- Staff Preference (Male / Female / No Preference)
- Access to Property (Client Will Open / Will Get Keys)

**Validations:**
- Start time < end time
- Required fields must be filled
- Cleaners needed > 0

**Post-Creation:**
- Job status = Pending
- Job appears in client calendar
- Job appears in admin dashboard
- Client receives confirmation email
- Only available & active cleaners receive job notification emails

**Recurring Jobs:**
- Recurrence pattern (weekly, monthly, one-time)
- Start date and optional end date
- RRULE generated internally

---

### 5.4 Jobs List & Management

**Jobs List Columns:**
- Cleaning Type | Date | Start Time | End Time
- Property | Status | Access to Property
- Equipment provided (Hoover, Washing Machine, Products, Dryer)
- Staff Preference | Additional Details
- Assigned Cleaner(s) | RRule/Repeat
- Job Type | Number of Cleaners

**Job Statuses:**
- Pending → Approved → In Process → Finished
- Cancelled

**Job Actions:**
- Edit Job (allowed up to 24 hours before start)
- Delete Job (confirmation required)
- View Job Detail

**Filtering:**
- By property, cleaner, status, or date

---

### 5.5 Calendar View

**Purpose:** Display all jobs for the month in a calendar layout.

**Filters Available:**
- Cleaner Name
- Property Name
- Status (Pending / Approved / In Process / Finished)
- Date navigation (month/day)

**Calendar Entries:**
- Job summary: property name, cleaner name(s), scheduled time
- Click → opens Job Details View

---

### 5.6 Job Details View

**Displayed Information:**
- Job Scheduled (Yes/No)
- Repeat Frequency (Weekly / One-time)
- Job Start/End Date & Time
- Status
- Client name
- Property Label | Access to Property
- Full Address (Address, City, Postal Code)
- Property Type | Property Subtype
- Cleaning Type
- Animals on Property (Yes/No)
- Staff Preference
- Equipment Provided (Hoover, Washing Machine, Dryer, Products)
- Payment Source (Residential / Commercial)
- Number of Cleaners Needed
- Additional Instructions
- Assigned Cleaners (table: Cleaner Name, Status, Review)

**Multi-Day & Historical Jobs:**
- Calendar shows historical jobs with their status
- Jobs for same property across multiple days show repeated entries
- "+1 more" feature for days with multiple jobs

---

### 5.7 Job Summary

**Purpose:** Track job history, payments, and performance.

**Summary Table Columns:**
- Property | Start Date | End Date
- Worked Hours | Hourly Rate
- Payment Source (Residential / Commercial)
- Total Payout | Status (Paid / Unpaid / Pending)

**Features:**
- Sortable by date, property, or status
- Total Payout = Worked Hours × Hourly Rate
- Real-time updates if hours/rate/status changes
- Optional: export to CSV/PDF

---

### 5.8 Preferred Staff

**Purpose:** Select preferred cleaners for bookings and schedule jobs based on their availability.

**Features:**
- Mark multiple staff as preferred (no limit)
- Preferred staff appear at top when creating jobs
- View staff work shifts (daily start/end times, weekly schedule)
- Only future available slots shown; past/booked slots hidden
- Select time slot from available hours of preferred staff
- Availability status: Available / Partially Available / Fully Booked
- Dynamic updates: availability updates in real-time

**Booking Flow:**
1. Navigate to Preferred Staff page
2. Select a preferred staff member
3. System shows available time slots for selected date(s)
4. Select slot and create job
5. Job auto-assigned to that staff if available
6. Notifications triggered to staff and customer

---

### 5.9 Client Notifications

**Notification Types:**
- Job status changes (e.g., "Job at '51 College Cross' is now in progress")
- Cleaner actions (e.g., "Job approved by Cleaner")
- Job completion (e.g., "Job has been completed")

**Features:**
- Real-time push notifications
- Read/Unread status
- Sorting & filtering (by date, status)
- Notification history (paginated)
- Clickable → opens job details page

---

### 5.10 Review Submission

**Purpose:** Client submits reviews for cleaners after job completion.

**Trigger:**
- Enabled only after job is completed
- One review per job (no duplicates)

**Review Form Fields:**
- Cleaner Name (auto-filled)
- Job / Property Name (auto-filled)
- Rating (1–5 stars) — required
- Operational Checks (Yes/No):
  - Arrived on time
  - Wore uniform
  - Completed on time
  - Would rehire
- Comments (optional, free-text)

**Validations:**
- Rating is mandatory
- Job must be completed
- Review can be edited only within limited time window (optional)

---

### 5.11 Training & Resources (Client View)

**Features:**
- View available training materials
- Content: videos, PDFs, images, links
- Search by title or description
- Filter by media type
- Status tracking: Seen / Unseen

---

## 6. Cleaner Modules & Features

### 6.1 Profile Management

**Profile Sections:**

**Profile Photo:**
- Required
- Upload/change photo
- Max 5 MB (JPG, PNG)

**Personal Information:**
- First Name, Last Name, Phone Number
- Email (read-only; contact support to update)
- Address, City, Postal Code
- Date of Birth, Gender
- Enable reminders via Email/SMS (toggle)
- Change Password

**Immigration & Legal Details:**
- Immigration Status (dropdown)
- National Insurance Number OR Share Code (one required)
- NIN format: 2 letters + 6 digits + 1 letter (e.g., AB123456C)
- Are you a student? (Yes/No)

**Next of Kin Details:**
- Full Name* | Relationship* | Contact Number*

**Work Details:**
- Do you drive? (Yes/No)
- Local working areas (multi-select)
- Do you have children? (Yes/No)
- Employment Start Date

**Cleaning Services Capabilities:**
- Kitchen Area tasks (checklist)
- Bathroom/Toilet tasks (checklist)
- Bedroom/Living Room tasks (checklist)
- Ironing Services tasks (checklist)

**Bank Details:**
- Bank Name | Account Holder Name | Account Number | Sort Code
- Editable by cleaner; changes may require admin approval

**Account Actions:**
- Delete My Account (soft delete; historical records retained)

**Profile Completion:**
- Progress bar (e.g., 96% Complete)
- Missing mandatory info highlighted
- Clicking warning → redirects to required section
- Certain actions restricted until required fields completed

---

### 6.2 Availability Management

**Weekly Working Schedule:**
- Define availability for each day (Monday–Sunday)
- For each day: From time, To time
- Empty day = unavailable that day
- Jobs assigned only within defined time slots

**Block Hours / Days:**
- Temporarily mark unavailable without changing regular schedule
- Used for: personal leave, appointments, travel, emergencies
- Add Block form: Start Date, End Date, Start Time, End Time, Reason (optional)
- Can block: few hours on single day, multiple full days, date range with time windows
- Blocked periods override weekly availability

**Unavailable Days & Hours List:**
- Displays all upcoming blocked periods
- Shows: date range, time range, reason
- Cleaner can view, edit, or remove future blocks

**Business Rules:**
- No jobs assigned during blocked times
- If cleaner blocks time after job is assigned → admin notified → job flagged for reassignment

---

### 6.3 Document Upload & Verification

**Purpose:** Verify cleaner identity and legal work eligibility.

**Document Upload Form:**
- Document Type* (Passport, Visa, DBS, Proof of Address, Driver License, Other)
- Document Number*
- Expiry Date* (must be future date)
- File Upload* (PDF, JPG, PNG; max 5 MB)

**Validations:**
- All required fields completed
- Expiry date must be future
- File meets format/size constraints
- Duplicate document type rules enforced

**Uploaded Documents List:**
- Document name, number, expiry date, status (Valid/Expired/Pending)
- View file option

**Business Rules:**
- Cleaners with missing/expired/rejected mandatory documents cannot be assigned or accept jobs
- Expiry reminders sent to cleaner and admin
- Profile completion percentage reduced if documents missing
- Warning banners shown in dashboard

---

### 6.4 References Management

**Purpose:** Collect character/work references for verification.

**Add Reference Form:**
- First Name* | Last Name* | Email* | Phone Number*
- Company Name (optional)
- Relationship* (Employer, Supervisor, Colleague, Client, Family, Friend, Other)

**References List:**
- Displays all added references
- Status: Pending Review / Approved / Rejected

**Business Rules:**
- Reference data visible only to cleaner (own) and admin
- No public exposure

---

### 6.5 Dashboard & Calendar

**Default Landing Page:** Calendar screen after login.

**Calendar Purpose:**
- Immediate visibility of today's jobs, upcoming assignments, job status
- Ensure cleaners always know when and where they are working

**Calendar Features:**
- Default view: current month
- Jobs displayed on assigned dates
- Each job entry shows: Job/Property name, Time slot, Client name, Short address, Status badge (Approved/Pending)
- Filters: Property name, Job status
- Month navigation: swipe or arrows

**Job Interaction:**
- Tap any job → View full job details, location, instructions
- Perform allowed actions (accept, start, complete)

**Scheduling Logic:**
- Calendar respects cleaner's available working hours and blocked slots
- System prevents double booking and jobs outside declared availability

**Real-Time Updates:**
- Calendar updates when: new jobs assigned, status changes, jobs rescheduled/cancelled
- Recurring jobs appear as separate entries

---

### 6.6 My Jobs & Job Execution

**My Jobs Listing:**
- Chronological list of all assigned jobs
- Columns: Property name/address, Job date, Job status, Start/End time, Review status, Check-in/out times

**Filtering Options:**
- All Jobs (default)
- Upcoming Jobs
- Completed Jobs
- Pending Approval

**Job Detail Screen (Pre-Execution):**
- Client name | Property address, city, postal code
- Job date | Scheduled start/end time
- Property type (Residential/Commercial) | Property subtype
- Cleaning type | Animals on property (Yes/No)
- Staff preference | Equipment availability
- Access instructions | Additional notes
- Payment source

---

### 6.7 Check-In / Check-Out

**Check-In Rules:**
- Allowed only up to 15 minutes before scheduled start time
- Example: Job start 18:00 → Earliest check-in 17:45
- If early check-in attempted → system blocks → shows validation message
- Check-in button active only within allowed window

**Check-In Requirements:**
- Upload "Before Job" photos
- Confirm check-in action

**Check-In Data Captured:**
- Server-generated check-in timestamp
- Uploaded images (stored securely)
- Job status updated to "In Progress"

**Check-Out Rules:**
- Cannot check out before scheduled job end time
- Enabled only after end time passed AND check-in completed

**Check-Out Requirements:**
- Upload "After Job" photos
- Confirm job completion

**Check-Out Data Captured:**
- Server-generated check-out timestamp
- Uploaded completion images
- Job status updated to "Completed"

---

### 6.8 Worked Time & Overtime Tracking

**Automatic Calculation:**
- Scheduled duration = Scheduled End − Scheduled Start
- Actual worked duration = Check-Out Time − Check-In Time

**Extra Time Detection:**
- If actual worked time > scheduled time → extra minutes recorded as "Additional Worked Time"

**Stored Time Data:**
- Scheduled start & end time
- Actual check-in & check-out timestamps
- Total worked hours
- Extra time (if any)

---

### 6.9 Payout & Work Hours View

**Date Range Selection:**
- Cleaner selects From Date and To Date
- System fetches only completed jobs within period

**Rules:**
- Only jobs with successful check-in AND check-out counted
- Pending/cancelled jobs excluded
- Future jobs never included

**Work Entries Table Columns:**
- Paid For (Date Range) | Hours Worked
- Residential Rate | Commercial Rate
- Total Amount | Residential Earnings | Commercial Earnings
- Payment Status (Paid / Unpaid) | Paid Date (if paid)

**Earnings Summary (Auto-Calculated):**
- Total Residential Earnings
- Total Commercial Earnings
- Total Payout
- Read-only for cleaners; updated instantly on date range change

**Payment Status Flow:**
- Unpaid = default after job completion
- Paid = set by admin after payout processed
- Cleaner cannot mark jobs as paid
- Once marked Paid → status locked, paid date recorded, entry non-editable

---

### 6.10 Reviews View

**Cleaner Can View:**
- Only their own reviews
- Read-only (cannot edit or delete)

**Displayed Information:**
- Job/Property name
- Rating (1–5 stars)
- Customer comments
- Submission date

**No visibility of other cleaners' reviews.**

---

### 6.11 Training & Resources

**Features:**
- Access training materials (documents, images, videos, guides)
- Content centrally managed by admin

**Resource Display:**
- Total resources count
- Seen resources count
- Unseen resources count
- List of all available materials

**Status Tracking:**
- Unseen = default for new resources
- Seen = after cleaner opens/views
- Status stored per cleaner
- Counters update dynamically

**Search & Filter:**
- Search by title or description
- Filter by media type (Video, Document, Image, Other)

---

### 6.12 Cleaner Notifications

**Notification Types:**
- Job assignment (Residential / Commercial)
- Job reassignment or update
- Schedule changes (date, time, location)
- Check-in / check-out confirmations or issues
- Payout-related updates (calculated, approved, paid)
- System alerts or announcements from admin

**Notification Content:**
- Job name or location
- Customer name
- Message content
- Date & time

**Features:**
- Chronological listing (latest first)
- Status indicator: Unread / Read
- Unread → visually highlighted
- Real-time delivery (push + in-app)
- If offline → sync when back online
- Duplicate notifications allowed for repeated assignments

---

## 7. Shared Features (Both Roles)

### 7.1 Authentication
- JWT token-based authentication
- Token stored in secure storage
- Role checked on every API request
- Backend decides accessible data and allowed actions

### 7.2 Profile Completion Gating
- Certain actions restricted until profile complete
- Progress indicator visible
- Missing fields highlighted

### 7.3 Notifications
- Push notifications (FCM) — primary channel
- Email notifications — secondary channel
- Deep linking from notifications to relevant screens
- Read/Unread tracking
- Notification history

### 7.4 Password Management
- Change password requires: current password, new password, confirm password
- Password strength validation

### 7.5 Account Deletion
- Delete My Account option
- Confirmation modal with warning
- Soft delete (account deactivated; historical records retained)

---

## 8. End-to-End Workflow

### 8.1 Job Lifecycle

```
1. Client adds property (Residential / Commercial)
2. Client creates job + selects number of cleaners
3. System notifies eligible and available cleaners (email/push)
4. Cleaners show interest / apply
5. Admin reviews applications (web portal)
6. Admin assigns required cleaners
7. Cleaners accept job
8. Automated reminders sent (24h before, 3h before)
9. Cleaners check-in (with before photos)
10. Job status = In Progress
11. Cleaners check-out (with after photos)
12. Hours tracked automatically
13. Job status = Completed
14. Payment processed by admin
15. Feedback collected from client
16. Job audit-locked for records
```

### 8.2 Job Status Progression

```
Created → Pending → Approved → In Process → Finished
                                    ↓
                              Cancelled (any stage)
```

### 8.3 Cleaner Application Flow

```
1. Client creates job → status = Pending
2. System checks cleaner availability & eligibility
3. Only active, available cleaners receive notification
4. Notification includes: property, job date/time, duration, "Request to allocate" button
5. Cleaner clicks to show interest → Job marked as "Requested" in Admin Panel
6. Admin reviews applications
7. Admin assigns cleaner(s)
8. Cleaner receives assignment notification
9. Job appears in Cleaner's My Jobs dashboard
10. Cleaner accepts job → status = Accepted
11. Email sent to client and admin confirming acceptance
```

---

## 9. Business Rules & Validations

### 9.1 Job Rules
- Jobs editable by client up to 24 hours before start
- Cancellations trigger warnings and may restrict future bookings
- Once job completed → job becomes locked → no edits allowed
- Multiple cleaners can be assigned per job
- Number of cleaners assigned cannot exceed job requirement

### 9.2 Check-In/Out Rules
- Check-in allowed only 15 minutes before scheduled start
- Check-out allowed only after scheduled end time
- Future jobs locked until their date
- Only today's job accessible for check-in
- Supports overnight and midnight shifts

### 9.3 Cleaner Eligibility Rules
- Only active and eligible cleaners receive job notifications
- Cleaners with expired/missing/rejected documents cannot be assigned
- Cleaners cannot self-assign jobs (admin-controlled)
- System prevents assigning cleaners who are double-booked or unavailable

### 9.4 Payout Rules
- Hours calculated using actual check-in/out times
- Manual time entry not allowed
- Extra time automatically calculated and included
- Rates locked at job completion (no retroactive changes)
- Cleaner cannot mark jobs as paid (admin only)
- Once paid → status locked and immutable

### 9.5 Profile Completion Rules
- Cleaner cannot receive or accept jobs until:
  - Profile is completed
  - Availability is added
  - Mandatory documents are uploaded and valid

### 9.6 Availability Rules
- Jobs assigned only within defined time slots
- Cleaner cannot be assigned overlapping jobs
- Blocked periods override weekly availability
- If cleaner blocks time after job assigned → admin notified → job flagged

### 9.7 Document Rules
- Expiry date must be future date
- Expiry reminders sent automatically
- Expired documents flagged automatically
- Cleaners with expired documents cannot accept jobs

---

## 10. Notification Triggers

### 10.1 Client Notifications
- Job Created (confirmation)
- Job Assigned (cleaner assigned)
- Job Accepted (cleaner accepted)
- Job In Progress (cleaner checked in)
- Job Completed (cleaner checked out)
- Job Cancelled

### 10.2 Cleaner Notifications
- New Job Available (matching availability/eligibility)
- Job Assigned to You
- Job Reassigned or Updated
- Schedule Changed (date, time, location)
- Check-In/Check-Out Confirmation
- Payout Updates (calculated, approved, paid)
- Document Expiry Reminders
- System Alerts / Announcements

### 10.3 Reminder Notifications
- 24 hours before job
- 3 hours before job

---

## 11. Module Interactions

### 11.1 Property ↔ Job
- Job creation requires selecting a property
- Property details auto-fill into job
- Property type determines payment routing

### 11.2 Job ↔ Calendar
- All jobs appear in calendar view
- Calendar updates in real-time with job changes

### 11.3 Job ↔ Notifications
- Job lifecycle events trigger notifications
- Deep links from notifications open job details

### 11.4 Availability ↔ Job Assignment
- System checks cleaner availability before notification
- Blocked periods prevent job assignment

### 11.5 Documents ↔ Job Eligibility
- Missing/expired documents block job acceptance
- Expiry triggers reminders and warnings

### 11.6 Check-In/Out ↔ Payout
- Actual hours calculated from check-in/out timestamps
- Hours feed directly into payout computation

### 11.7 Job ↔ Reviews
- Reviews enabled only after job completed
- One review per job (no duplicates)

### 11.8 Preferred Staff ↔ Job Creation
- Preferred staff appear at top during job creation
- Availability visible before slot selection

---

## 12. Module Summary (Scope)

### Client Modules
1. Onboarding & Registration
2. Profile Management (with profile photo)
3. Property Management
4. Job Creation & Management
5. Calendar View
6. Job Summary
7. Preferred Staff (multiple allowed)
8. Review Submission
9. Notifications
10. Training & Resources

### Cleaner Modules
1. Onboarding (Assessment → Gov Verification → OTP)
2. Profile Management (with profile photo)
3. Availability Management
4. Document Upload & Verification (max 5 MB)
5. References Management
6. Dashboard & Calendar
7. My Jobs & Job Execution
8. Check-In / Check-Out
9. Payout & Work Hours View
10. Reviews View
11. Training & Resources
12. Notifications (Push + Email)

---

## 13. Out of Scope (Mobile App)

The following are handled in the **Admin Web Portal** and are NOT part of the Flutter app:
- Admin/Super Admin login and dashboard
- Job scheduling and assignment
- Cleaner/customer management
- Compliance verification
- SMS and newsletters
- Payout processing and mark as paid
- Invoicing
- Reports and audit logs
- Assistants management

---

## 14. Technical Notes

- **API:** REST API v1, JWT authentication
- **Notifications:** Push (FCM) + Email; deep linking required
- **Storage:** Ionos (server-level)
- **File Uploads:** Max 5 MB (profile photos, documents)
- **Offline:** Not required
- **Localization:** Not required (English only)
- **Biometric Auth:** Not required
- **App Store:** Compliance with iOS/Android policies required
- **Responsive UI:** Required for various screen sizes

---

## 15. Confirmed Decisions

| # | Question | Decision |
|---|----------|----------|
| 1 | Review submission | Mobile app only (client submits reviews in app) |
| 2 | Assistant role | Out of mobile scope (confirmed) |
| 3 | Document upload max size | 5 MB |
| 4 | OTP retry cooldown | 60 seconds |
| 5 | Assessment config | Backend dynamic (question count, pass threshold, retry cooldown) |
| 6 | Preferred staff | Yes, client can have multiple preferred staff |
| 7 | Notifications | Email + Push (primarily push) |
| 8 | Profile photo | Required for both Client and Cleaner |
| 9 | Multi-language | Not required at the moment |
| 10 | Biometric auth | Not required |

---

## 16. Document Version

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-21 | Initial comprehensive plan aligned with SRS |
