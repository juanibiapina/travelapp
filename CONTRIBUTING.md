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
- Can contain multiple links
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

**Link**
- Belongs to a trip
- Stores URLs related to the trip (hotels, flights, activities, etc.)
- Validates URL format to ensure proper HTTP/HTTPS URLs

**TripEvent**
- Belongs to a trip
- Represents events that happen during a trip (accommodations, train rides, activities, etc.)
- Has required fields: title, start_date, end_date
- Validates that end_date is greater than or equal to start_date
- Enables chronological organization of trip activities

**Place**
- Belongs to a trip
- Represents locations that can be plotted on a map
- Has required field: name
- Simple structure for storing location information

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

**Link Organization**
- Add links to trips for organizing travel-related URLs
- Nested resource structure (trips have many links)
- URL validation to ensure valid web addresses

**Place Management**
- Add places to trips for organizing locations
- Each place has a name field
- Nested resource structure (trips have many places)
- Full CRUD operations with proper authorization

**Event Management**
- Add events to trips for organizing time-based activities
- Each event has a title, start date, and end date
- Chronological ordering and duration calculation
- Nested resource structure (trips have many trip events)
- Full CRUD operations with proper authorization

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

**LinksController**
- Nested CRUD operations under trips
- Requires user authentication
- Ensures users can only access links for trips they belong to

**PlacesController**
- Nested CRUD operations under trips for managing places
- Requires user authentication
- Uses Pundit for role-based authorization
- Ensures users can only access places for trips they belong to

**TripEventsController**
- Nested CRUD operations under trips for managing trip events
- Requires user authentication
- Uses Pundit for role-based authorization
- Ensures users can only access events for trips they belong to

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
- `links` - URLs associated with trips
- `places` - Named locations associated with trips
- `trip_events` - Time-based events and activities associated with trips

Foreign key relationships ensure data integrity, and dependent destroys clean up associated records when parent records are deleted.

## Installing the `pg` gem

To install the `pg` gem on macOS, install libpq:
```sh
brew install libpq
```

And then install the `pg` gem:

``` sh
gem install pg -- --with-pg-config=/opt/homebrew/opt/libpq/bin/pg_config
```
