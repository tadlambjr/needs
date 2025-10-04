# Church Needs App

A Rails 8 application for churches to manage needs and volunteer sign-ups within their congregation.

## Features

### User Roles
- **Members**: Can view needs, sign up as volunteers, and create member-initiated needs (requires admin approval)
- **Admins**: Can create/edit/delete needs, approve member-initiated needs, manage categories and users

### Core Functionality
- **Need Management**: Create, edit, and manage needs with categories, dates, times, locations, and volunteer capacity
- **Volunteer Signups**: Members can sign up for needs with automatic capacity tracking
- **Meal Trains**: Multi-day needs where volunteers can sign up for individual days
- **Admin Approval Workflow**: Member-initiated needs require admin approval before becoming visible
- **Categories**: Organized needs by type (Cleaning, Meals, Transportation, etc.)
- **Checklists**: Reusable task lists that can be attached to needs
- **Notifications**: In-app notification system (expandable to email/SMS)
- **Dark/Light Theme**: User preference for theme (system, light, or dark)

## Tech Stack

- **Rails 8.0** with Rails 8 authentication
- **Ruby 3.2+**
- **SQLite** (development/test)
- **TailwindCSS** for styling
- **Turbo** for SPA-like navigation
- **Stimulus** for JavaScript interactivity
- **Propshaft** for asset pipeline
- **Kamal** for deployment

## Getting Started

### Prerequisites

- Ruby 3.2 or higher
- Node.js (for JavaScript dependencies)
- SQLite3

### Installation

1. **Clone the repository**
   ```bash
   cd /Users/tadlambjr/devl/needs
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create db:migrate db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the application**
   - Open your browser to `http://localhost:3007`

### Default Login Credentials

After running `db:seed`, you can login with:

- **Admin Account**
  - Email: `admin@church.org`
  - Password: `password123`

- **Member Account**
  - Email: `john@example.com`
  - Password: `password123`

## Application Structure

### Models

- **User**: Authentication and user management with roles (member/admin)
- **Need**: Core need entity with status tracking and volunteer management
- **Category**: Organize needs by type
- **NeedSignup**: Tracks volunteer signups for needs
- **Checklist**: Reusable task lists
- **ChecklistItem**: Individual tasks within a checklist
- **ChecklistCompletion**: Tracks completion of checklist items
- **Notification**: In-app notification system
- **NotificationPreference**: User preferences for notifications

### Key Business Rules

1. **Need Lifecycle**
   - Draft → Published → Full → In Progress → Completed
   - Member-initiated needs start as Draft and require admin approval
   - Admin-created needs can be published immediately

2. **Volunteer Signups**
   - Cannot sign up for past needs
   - Cannot sign up if need is at capacity
   - Can cancel up to 24 hours before start time
   - For meal trains: can sign up for multiple individual days

3. **Permissions**
   - Members can only edit their own draft needs
   - Admins can edit any need
   - Only admins can approve/reject member-initiated needs

## Usage Examples

### Creating a Need (Admin)

1. Navigate to "Create Need" button
2. Fill in the form:
   - Title and description
   - Select category
   - Choose dates and time
   - Set volunteer capacity
   - Optionally enable meal train mode
   - Optionally attach a checklist
3. Click "Create Need"
4. Need is immediately published and visible to all members

### Creating a Need (Member)

1. Same process as admin
2. Need is created in "Draft" status
3. Admins receive notification
4. Admin must approve before need becomes visible to other members

### Signing Up for a Need

1. Browse available needs on home page or "All Needs" page
2. Click on a need to view details
3. Click "Sign Up to Volunteer" button
4. Receive confirmation notification

### Signing Up for a Meal Train

1. View a need with "Sign up for individual days" enabled
2. See calendar of available days
3. Click "Sign Up" on specific date(s)
4. Can sign up for multiple days

### Approving Member-Initiated Needs (Admin Only)

1. Navigate to "Pending Approval" in navigation
2. Review member-submitted needs
3. Click "Approve & Publish" or "Reject"
4. Creator receives notification of decision

## Development

### Running Tests

```bash
rails test
```

### Code Style

This project follows the Rails Omakase Ruby styling guidelines.

```bash
rubocop
```

### Database Schema

To view the current schema:

```bash
cat db/schema.rb
```

To create a new migration:

```bash
rails generate migration MigrationName
```

## Deployment

This application is configured for deployment with Kamal.

```bash
kamal setup
kamal deploy
```

## Future Enhancements

- Email and SMS notifications
- Recurring needs automation
- Mobile app (React Native or Flutter)
- Calendar integration (Google Calendar, iCal)
- Photo attachments for needs
- Volunteer hour tracking and reports
- Advanced search and filtering
- Export reports to PDF/Excel

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

This project is proprietary and confidential.
