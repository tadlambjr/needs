Generate an app whose purpose is for churches to make known needs to the congregation and for members to volunteer to fill those needs. The app should be built with Rails 8 (using Rails 8 authentication) and should use TailwindCSS for styling. It should also use Turbo for navigation and Stimulus for interactivity. ActiveStorage should be used for file storage and ActiveJob for background jobs. Propshaft should be used for asset compilation and Kamal for deployment.

- has a dark and light theme
- has a responsive layout
- runs on port 3007

The user interface should be simple and intuitive. The app should have a clean, modern design with a focus on accessibility and ease of use. The app should be easy to navigate and should have a consistent look and feel throughout.

## User Roles & Permissions

**Member (default role):**
- Can view all published needs (only admin-created and approved member-initiated needs)
- Can sign up for needs and cancel their own signups (up to 24 hours before start time)
- Can create member-initiated needs (e.g., "I need help moving") - these are NOT visible to other members until approved by an admin
- Can view and update their own profile
- Can view their volunteer history
- Can mark checklist items complete for needs they're assigned to

**Admin:**
- All member permissions, plus:
- Can create, edit, and delete any need
- Can create and manage categories
- Can create and modify checklists
- Can approve/reject member-initiated needs
- Can manually assign volunteers to needs
- Can view all volunteer signups and participation reports
- Can manage user accounts (activate/deactivate)
- Can configure organization settings

## Need Lifecycle & States

Needs progress through the following states:
1. **Draft** - Admin is creating the need OR member-initiated need awaiting approval (not visible to other members)
2. **Published** - Need is approved and visible to all members, accepting volunteers
3. **Full** - Maximum volunteers reached (visible but no signup button)
4. **In Progress** - Need start date/time has arrived
5. **Completed** - Need marked complete by admin or volunteer
6. **Cancelled** - Need was cancelled before completion
7. **Rejected** - Member-initiated need was rejected by admin (only visible to creator)

## Core Features

### Authentication & User Management
1. Users can create an account with email, password, name, and phone number
2. Email verification required before first login
3. Password reset via email
4. Users can update profile: name, email, phone
5. Users can set notification preferences (email, SMS, in-app)

### Need Management
6. Admins can create needs with: title, description, category, date range, time slot, location, volunteer capacity (1-20), checklist (optional)
7. Members can create member-initiated needs (require admin approval before becoming visible to other members)
   - Member-initiated needs start in 'draft' status
   - Only the creator and admins can see draft member-initiated needs
   - Admins receive notification when a member creates a need
   - Once approved, the need moves to 'published' status and becomes visible to all members
8. Needs can be one-time or recurring (daily, weekly, monthly)
9. Needs can span multiple days or be for a specific time slot
10. Needs can have a volunteer capacity limit (e.g., "Need 3 volunteers")
11. **Multi-day needs with individual day signups (Meal Trains):**
    - For needs spanning multiple days (e.g., meals for a family with a new baby), volunteers can sign up for individual days within the date range
    - Each day within the range can have its own volunteer capacity (typically 1 meal per day)
    - Calendar and need detail page show which days are filled vs available
    - Common use cases: meals for new parents, families going through trials, post-surgery recovery
    - Volunteers specify which specific date(s) they're signing up for
12. Needs can be edited by admins (with notification to signed-up volunteers if significant changes)
13. Needs can be cancelled by admins (with automatic notification to volunteers)
14. Needs can be marked complete by the volunteer or admin

### Volunteer Signup & Management
15. Users can sign up for needs if capacity available
16. Users can cancel their signup up to 24 hours before start time
17. Users receive confirmation when they sign up
18. Waitlist functionality: users can join waitlist if need is full
19. Admins can manually add/remove volunteers from any need
20. Users can see conflict warnings if they're already committed to another need at the same time

### Home Screen & Dashboard
21. **Not logged in:** Basic information about the app, login/signup buttons
22. **Logged in:** 
    - Upcoming needs the user is signed up for (next 7 days)
    - Rolling 6-week calendar view of all published needs
    - Quick filters: My Needs, All Needs, By Category
    - "Create Need" button (visible based on permissions)
    - Notification bell icon with unread count

### Calendar & Scheduling
23. Calendar shows needs color-coded by category
24. Calendar shows needs the user is signed up for with a distinct indicator
25. Users can click on calendar dates to see all needs for that day
26. Time slots: Morning (6am-12pm), Afternoon (12pm-6pm), Evening (6pm-10pm), or specific time
27. Recurring needs automatically create instances based on schedule

### Categories
28. Default categories: Cleaning, Lawn Care, Yard Work, Transportation, Meals, Childcare, Prayer Support, Technical Help, Other
29. Admins can create, edit, and archive categories
30. Each category has a name, description, icon, and color
31. Categories can be marked as "Admin Only" or "Member Can Create"

### Checklists
32. Admins can create reusable checklists (e.g., "Church Cleaning Checklist")
33. Checklists contain multiple items with descriptions
34. Checklists can be assigned to needs
35. When a volunteer starts a need with a checklist, they can check off items
36. Large click targets (minimum 44x44px) for checklist items on mobile
37. Checklist progress is saved in real-time
38. Checklist completion percentage shown
39. Completed checklists are stored with timestamp and volunteer name

### Notifications
40. Email notifications for:
    - New need published in categories user follows
    - Reminder 24 hours before scheduled need
    - Someone cancels from a need you're managing
    - Your member-initiated need is approved/rejected
    - Need you're signed up for is modified or cancelled
41. In-app notifications with badge count
42. Users can configure notification preferences per notification type

### Search & Filtering
43. Search needs by keyword (title, description)
44. Filter by: category, date range, status, needs with openings
45. Sort by: date, newest first, most urgent (soonest with fewest volunteers)

### Reporting & Analytics (Admin)
46. Volunteer leaderboard (most active volunteers by month/year)
47. Need fulfillment rate (% of needs that got filled)
48. Unfilled needs report
49. Category popularity report
50. Export reports to CSV

### Settings
51. **User Settings:** notification preferences, theme (dark/light), timezone, language (future)
52. **Admin Settings:** default volunteer capacity, cancellation policy hours, auto-approve member needs, email templates, organization name and logo

## Pages & Navigation

1. **Home/Dashboard** - Main landing page (different view for logged in vs not logged in)
2. **Login** - Email/password authentication
3. **Signup** - New user registration with email verification
4. **Password Reset** - Forgot password flow
5. **Needs Index** - Browse/search all needs with filters
6. **Need Detail** - View single need with signup button, volunteer list, checklist
7. **Create/Edit Need** - Form for creating or editing needs
8. **My Needs** - Needs the user has signed up for
9. **Calendar View** - 6-week rolling calendar of all needs
10. **Profile** - View/edit user profile
11. **Settings** - User preferences and notification settings
12. **Checklists** - Admin page to manage reusable checklists
13. **Categories** - Admin page to manage categories
14. **Admin Dashboard** - Reports, analytics, and admin tools
15. **User Management** - Admin page to manage user accounts
16. **Notifications** - View all in-app notifications

## Data Models

### User
- email (string, unique, required)
- encrypted_password (string, required)
- name (string, required)
- phone (string, optional)
- bio (text, optional)
- role (enum: member, admin; default: member)
- email_verified (boolean, default: false)
- active (boolean, default: true)
- timezone (string, default: 'America/New_York')
- theme_preference (enum: light, dark, system; default: system)
- has_many :needs (as creator)
- has_many :need_signups
- has_many :notifications
- has_many :notification_preferences
- timestamps

### Need
- title (string, required)
- description (text, required)
- category_id (foreign_key, required)
- creator_id (foreign_key to User, required)
- status (enum: draft, published, full, in_progress, completed, cancelled; default: draft)
- need_type (enum: admin_created, member_initiated)
- start_date (date, required)
- end_date (date, required)
- time_slot (enum: morning, afternoon, evening, specific_time, all_day)
- specific_time (time, optional)
- location (string, optional)
- volunteer_capacity (integer, default: 1, range: 1-20)
- allow_individual_day_signup (boolean, default: false) # true for meal trains
- is_recurring (boolean, default: false)
- recurrence_pattern (string, optional) # 'daily', 'weekly', 'monthly'
- recurrence_end_date (date, optional)
- parent_need_id (foreign_key to Need, optional) # for recurring instances
- approved_at (datetime, optional)
- approved_by_id (foreign_key to User, optional)
- completed_at (datetime, optional)
- completed_by_id (foreign_key to User, optional)
- checklist_id (foreign_key, optional)
- belongs_to :category
- belongs_to :creator, class_name: 'User'
- belongs_to :checklist, optional: true
- has_many :need_signups
- has_many :volunteers, through: :need_signups, source: :user
- timestamps

### Category
- name (string, required, unique)
- description (text, optional)
- icon (string, optional) # icon name from icon library
- color (string, optional) # hex color code
- member_can_create (boolean, default: false)
- active (boolean, default: true)
- display_order (integer, default: 0)
- has_many :needs
- timestamps

### Checklist
- name (string, required)
- description (text, optional)
- created_by_id (foreign_key to User, required)
- active (boolean, default: true)
- has_many :checklist_items, dependent: :destroy
- has_many :needs
- belongs_to :created_by, class_name: 'User'
- timestamps

### ChecklistItem
- checklist_id (foreign_key, required)
- description (text, required)
- display_order (integer, default: 0)
- belongs_to :checklist
- has_many :checklist_completions
- timestamps

### NeedSignup
- need_id (foreign_key, required)
- user_id (foreign_key, required)
- status (enum: signed_up, waitlist, cancelled, completed)
- signed_up_at (datetime, required)
- cancelled_at (datetime, optional)
- cancellation_reason (text, optional)
- completed_at (datetime, optional)
- specific_date (date, optional) # for multi-day needs with individual day signups (meal trains)
- belongs_to :need
- belongs_to :user
- has_many :checklist_completions
- timestamps
- unique index on [need_id, user_id, specific_date] for active signups (allows same user to sign up for multiple days)

### ChecklistCompletion
- need_signup_id (foreign_key, required)
- checklist_item_id (foreign_key, required)
- completed (boolean, default: false)
- completed_at (datetime, optional)
- notes (text, optional)
- belongs_to :need_signup
- belongs_to :checklist_item
- timestamps

### Notification
- user_id (foreign_key, required)
- notification_type (enum: new_need, reminder, signup_confirmation, cancellation, need_modified, approval_status)
- title (string, required)
- message (text, required)
- related_type (string, optional) # polymorphic
- related_id (integer, optional) # polymorphic
- read (boolean, default: false)
- read_at (datetime, optional)
- belongs_to :user
- timestamps

### NotificationPreference
- user_id (foreign_key, required)
- notification_type (enum: new_need, reminder, signup_confirmation, cancellation, need_modified, approval_status)
- email_enabled (boolean, default: true)
- sms_enabled (boolean, default: false)
- in_app_enabled (boolean, default: true)
- belongs_to :user
- timestamps
- unique index on [user_id, notification_type]

## Business Rules & Validations

1. **Need Creation:**
   - Title: 5-100 characters
   - Description: 10-1000 characters
   - Start date must be in the future (except for admins)
   - End date must be >= start date
   - Specific time required if time_slot is 'specific_time'
   - Member-initiated needs start in 'draft' status and are NOT visible to other members
   - Only admins and the creator can view draft member-initiated needs
   - Admin approval required to move member-initiated needs to 'published' status
   - Admins can reject member-initiated needs (moves to 'rejected' status, only visible to creator)

2. **Volunteer Signup:**
   - Cannot sign up for past needs
   - Cannot sign up if need is at capacity (unless joining waitlist)
   - Cannot sign up for same need twice (unless it's a multi-day need with individual day signups)
   - Cannot cancel within 24 hours of start time (except admins can override)
   - For multi-day needs with individual day signups (meal trains):
     * User must select specific date(s) when signing up
     * User can sign up for multiple dates within the same need
     * Each date has its own capacity limit
     * Cannot sign up for a specific date that's already at capacity
     * Cancellation applies to specific date(s) selected

3. **Recurring Needs:**
   - Generate instances up to 6 months in advance
   - Each instance is a separate Need record with parent_need_id set
   - Editing parent need only affects future instances

4. **Notifications:**
   - Reminders sent 24 hours before need start time
   - Batch email notifications sent every 15 minutes (not real-time)
   - In-app notifications are real-time via Turbo Streams

5. **User Accounts:**
   - Email must be unique
   - Password minimum 8 characters
   - Email verification required before accessing most features
   - Inactive users cannot login but data is retained

## Future Enhancements (Out of Scope for V1)

- Automated need creation based on schedules

