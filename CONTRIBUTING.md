# Contributing to Travel App

Thank you for your interest in contributing to the Travel App! This document provides all the information you need to get started with development.

**Important**: Please keep this document up to date as the project evolves. Changes to development processes, new dependencies, or architectural updates should be reflected here.

## Development Setup

1. Run setup script
   ```bash
   bin/setup --skip-server
   ```

## Running Tests

To run the test suite locally:

```bash
# Run all unit and integration tests
bin/rails test

# Run system tests
bin/rails test:system
```

## Linter

To run rubocop use:

```bash
bin/rubocop -f github
```

## Security Scan

To run brakeman for security vulnerability scanning:

```bash
bin/brakeman --no-pager
```

## Application Overview

### Models and Data Structure

**User**
- Handles authentication via Devise with email/password and Google OAuth
- Includes provider/uid fields for OAuth integration

**Trip**
- Belongs to a user (as owner)
- Has a name field
- Supports multiple members through trip memberships
- Can have shareable invite links for joining
- Represents a travel plan or itinerary

**TripMembership**
- Join table connecting users to trips
- Tracks user roles (owner/member) within trips
- Ensures one membership per user per trip
- Enables multi-user trip collaboration
- Includes optional starting place for each member (where they are at trip start)

**Invite**
- Belongs to a trip and created by a user
- Contains secure tokens for sharing trip access
- Can be activated/deactivated and optionally expire
- Enables easy trip sharing without email invitations

**TripEvent**
- Belongs to a trip
- Represents events that happen during a trip (accommodations, train rides, activities, etc.)
- Has required fields: title, start_date, end_date
- Validates that end_date is greater than or equal to start_date
- Enables chronological organization of trip activities

**Place**
- Belongs to a trip
- Represents locations that can be plotted on a map
- Has required fields: name, start_date, end_date
- Validates that end_date is greater than or equal to start_date
- Validates that start and end dates are within the trip's date range
- Cannot be deleted if referenced by transports (origin or destination)
- Can have multiple accommodations associated with it

**Accommodation**
- Belongs to a place (and indirectly to a trip through the place)
- Represents places to stay during a trip (hotels, apartments, hostels, etc.)
- Has required fields: title, start_date, end_date, place_id
- Validates that end_date is greater than or equal to start_date
- Validates that start and end dates are within the trip's date range
- Enables tracking of where travelers will stay during their trip

**Transport**
- Belongs to a trip
- Represents transportation between two places during a trip
- Has required fields: name, start_date, end_date, origin_place, destination_place
- Validates that end_date is greater than or equal to start_date
- Validates that start and end dates are within the trip's date range
- Validates that both origin and destination places belong to the same trip
- Can be taken by one or more users through a many-to-many relationship
- Enables tracking of transportation logistics between locations

### Key Features

**Authentication & Authorization**
- User registration and login with email/password
- Google OAuth integration for easy sign-in
- Role-based authorization with Pundit policies
- Trip ownership and membership management
- Secure invite token handling for trip sharing

**Trip Management**
- Create, view, edit, and delete trips
- Multi-user trip collaboration with role-based access (owners and members)
- Generate shareable invite links for easy trip joining
- Revoke invite links to control access
- Clean, responsive interface for trip management
- Set starting places for trip members to track where they begin their journey

**Invite Link System**
- Trip owners can generate secure invite links from the trip page
- Links use cryptographically secure tokens for safety
- Users can join trips by clicking invite links (authentication required)
- Automatic redirection flow for unauthenticated users
- Support for link revocation and optional expiration

**Place Management**
- Add places to trips for organizing locations
- Each place has a name field
- Nested resource structure (trips have many places)
- Full CRUD operations with proper authorization

**Accommodation Management**
- Add accommodations to places for tracking where to stay during trips
- Each accommodation has title, start date, end date, and belongs to a place
- Full CRUD operations with proper authorization
- Date validation ensures accommodation dates are within trip date range
- Dedicated tab in trip navigation for easy access
- Support for various accommodation types (hotels, apartments, hostels, etc.)

**Transport Management**
- Add transports to trips for organizing transportation between places
- Each transport has name, start date, end date, origin place, and destination place
- Support for tracking which users are taking each transport
- Nested resource structure (trips have many transports)
- Full CRUD operations with proper authorization
- Transportation logistics tracking with date and route validation

**User Interface**
- Responsive design with Tailwind CSS
- Modern browser support with progressive enhancement
- Clean, intuitive navigation

**Technical Features**
- Rails 8.0 application
- SQLite database with Active Record
- Importmap for JavaScript management
- Tailwind CSS for styling
- Devise for authentication
- Pundit for authorization
- PWA capabilities (partially implemented)
- Sentry integration for error monitoring and performance tracking

### Controllers

**ApplicationController**
- Base controller with Pundit authorization
- Modern browser requirement
- Handles authorization errors gracefully

**TripsController**
- Standard CRUD operations for trips
- Trip membership management
- Requires user authentication
- Uses Pundit for role-based authorization

**InvitesController**
- Generates and manages invite links for trips
- Handles invite acceptance with authentication flow
- Supports invite revocation by trip owners
- Manages session-based invite token storage

**PlacesController**
- Nested CRUD operations under trips for managing places
- Requires user authentication
- Uses Pundit for role-based authorization
- Ensures users can only access places for trips they belong to

**TransportsController**
- Nested CRUD operations under trips for managing transports
- Requires user authentication
- Uses Pundit for role-based authorization
- Ensures users can only access transports for trips they belong to
- Supports user assignment for who is taking each transport

### Development Workflow

Before committing changes:
1. Ensure all tests pass (`bin/rails test`)
2. Ensure system tests pass (`bin/rails test:system`)
3. Run the linter (`bin/rubocop -f github`)
4. Run security scan (`bin/brakeman --no-pager`)

All development commands use the `bin/` prefix for consistency and to ensure the correct versions of tools are used.

### Database Schema

The application uses seven main tables:
- `users` - User accounts with Devise fields and OAuth integration
- `trips` - Travel plans with multi-user support
- `trip_memberships` - Join table linking users to trips with roles and optional starting places
- `invites` - Secure invite tokens for trip sharing
- `places` - Named locations associated with trips
- `trip_events` - Time-based events and activities associated with trips
- `transports` - Transportation between places during trips
- `transport_users` - Join table linking users to transports for tracking who is taking each transport

Foreign key relationships ensure data integrity, and dependent destroys clean up associated records when parent records are deleted.

### Environment Variables

The application requires the following environment variables for full functionality:

**Required for production:**
- `SENTRY_DSN` - Sentry Data Source Name for error reporting and performance monitoring

**Required for Google OAuth:**
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret

Note: Sentry is only enabled in production and staging environments by default.

## Installing the `pg` gem

To install the `pg` gem on macOS, install libpq:
```sh
brew install libpq
```

And then install the `pg` gem:

``` sh
gem install pg -- --with-pg-config=/opt/homebrew/opt/libpq/bin/pg_config
```
