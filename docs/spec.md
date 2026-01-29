Product Spec (High-Level)
Product: Cleaning Services Operations Platform
Purpose: Centralize job scheduling, staff/cleaner management, customer management, compliance, communications, reviews, and payouts.
Core Outcomes
Manage jobs from request → scheduling → completion
Maintain cleaner/staff profiles and compliance
Communicate with clients/staff via SMS/newsletters/notifications
Track reviews and performance
Calculate and mark payouts
Modules & Features
1) Dashboard & Calendar (Timesheet)
Calendar views: month/week/list
Job filter by client/cleaner/property/status
Quick add job
Jobs overview and status
2) Jobs
Job list with detailed columns
Search jobs
Add job
3) Scheduled Jobs
Search by property or client
Update billing type/time/cleaner
Pause/Resume recurring schedules
4) Customers
Search customers
View list with contact data
Update email
Status management
5) Cleaners
Search cleaners
Filter active/inactive
Update email & NI number
Approval status indicator
6) Requested Jobs
Search requested jobs
Filter by allocation status
View requested job queue
7) Cleaner Character References
Search by cleaner
View reference details
Pagination
8) SMS
Recipient selection
Phone number input
Message composition
Send action
9) Assistants
Add assistant
Search assistants
Assistant listing
10) Newsletters
Select newsletter template
Edit title + save
Assign to customers or staff/cleaners
Select all + send
11) Work Eligibility & Permit
Search + filters
Document list with expiry status
View document details
12) Training & Resources
Add training/resource
Search by title/description
Filter by audience and media type
View/Open, Edit, Delete
13) Reviews
Search reviews by cleaner name
Review listing
14) Work Hours & Pay (Payout)
Date filter + apply
Staff payout summary
Billing type filter
Mark as paid
Work entries list + search
15) Job Summary
Search customers
Summary per customer (jobs, hours, amount)
Drill down to show jobs
16) Notifications
Notifications module (list not visible in snapshot)
17) Profile
Edit profile fields
Enable reminders (email/SMS)
Change password
Delete account
Update profile
Roles
Super Admin / Admin
Staff / Cleaner
Client (Customer)
Assistant
> Note: Only Admin portal was reviewed. Staff/Client portals were not logged in during this session.
Permissions Matrix (Proposed)
Module	Super Admin	Admin	Staff/Cleaner	Client	Assistant
Dashboard/Calendar	Full	Full	View own	View own	View own
Jobs	Full	Full	View assigned	View own	View assigned
Scheduled Jobs	Full	Full	View	View	View
Customers	Full	Manage	View own	View own	—
Cleaners	Full	Manage	View own	—	—
Requested Jobs	Full	Manage	View own	Submit	Submit
References	Full	View	View own	—	—
SMS	Full	Full	Limited	—	—
Assistants	Full	Manage	—	—	View own
Newsletters	Full	Manage	View	View	View
Work Eligibility	Full	Manage	View own	—	—
Training & Resources	Full	Manage	View	View	View
Reviews	Full	View	View own	View own	—
Work Hours & Pay	Full	Manage	View own	—	—
Job Summary	Full	Full	View own	View own	View own
Notifications	Full	Full	View	View	View
Profile	Full	Full	Full	Full	Full
Role‑Specific Functionality
Super Admin / Admin
Full operations control
Job creation, scheduling, and reassignment
Cleaner/staff management
Compliance verification
Communications (SMS, newsletters)
Reviews oversight
Payout processing
Staff / Cleaner
View assigned jobs/schedules
View training resources
View compliance status
View reviews and payout summary
Client
View own jobs/schedules
Submit requests
Receive communications
Assistant
View assigned tasks or delegated jobs
Limited visibility to own profile
Product Plan (Phases)
Phase 1 — Core Operations
Jobs, scheduling, customers, cleaners
Dashboard/calendar views
Requested jobs
Phase 2 — Compliance & Quality
Work eligibility & permits
Character references
Reviews
Phase 3 — Communications
SMS
Newsletters
Notifications
Phase 4 — Finance & Insights
Payout computation
Work entries details
Job summary reporting


Recommended next steps
Create detailed user stories per module
Design data models/ERD
Define API endpoints and contracts
Create UI mockups/wireframes
Document business rules (payout calculations, job allocation)
Define integration requirements (SMS, email, payments)
Should I expand any section or address specific aspects of the spec?