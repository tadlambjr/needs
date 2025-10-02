Generate an app whose purpose is for churches to make known needs to the congregation and for members to volunteer to fill those needs. The app should be built with Rails 8 (using Rails 8 authentication) and should use TailwindCSS for styling. It should also use Turbo for navigation and Stimulus for interactivity. ActiveStorage should be used for file storage and ActiveJob for background jobs. Propshaft should be used for asset compilation and Kamal for deployment.

- has a dark and light theme
- has a responsive layout
- runs on port 3007

The app should have the following features:
1. A user can create an account and login
2. A user can be an admin or a member
3. Some types of needs are created by admins and some are created by members
4. A user can view all needs
5. A user can view all needs they have volunteered for
6. The home screen should have basic information about the app when not logged in
7. The home screen should have a list of needs when logged in and a rolling 6-week calendar of needs
8. The home screen should have a button to create a need in categories the users has permission to create when logged in
9. The user can sign up for needs and cancel their sign up for needs
10. The user can view their profile and update their profile
11. The user can view the settings page and update their settings
12. Some of the common needs are weekly cleaning, mowing the lawn, and yard work
13. For cleaning there will be a checklist that can be modified by admins
14. when the volunteer starts cleaning the checklist will be available to them and they can check items off as they complete them
15. There should be a large click target for checking off items on the checklist
16. Needs can span a week or be for a single day

The app should have the following pages:
1. Home
2. Login
3. Signup
4. Dashboard
5. Needs
6. Profile
7. Settings
8. Checklists
9. Admin

The app should have the following models:
1. User
2. Need
3. Admin
4. Category
5. Checklist
6. ChecklistItem
7. NeedSignup

