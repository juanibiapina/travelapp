# Contributing to Travel App

Thank you for your interest in contributing to the Travel App! This document provides all the information you need to get started with development.

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

# Run system tests (needs a browser)
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

The Travel App has a simple but effective data model:

**User**
- Handles authentication via Devise with email/password and Google OAuth
- Can have multiple trips
- Includes provider/uid fields for OAuth integration

**Trip**
- Belongs to a user
- Has a name field
- Can contain multiple links
- Represents a travel plan or itinerary

**Link**
- Belongs to a trip
- Stores URLs related to the trip (hotels, flights, activities, etc.)
- Validates URL format to ensure proper HTTP/HTTPS URLs

### Key Features

**Authentication & Authorization**
- User registration and login with email/password
- Google OAuth integration for easy sign-in
- Pundit policies for authorization (users can only access their own trips and links)

**Trip Management**
- Create, view, edit, and delete trips
- Each trip is scoped to the authenticated user
- Clean, responsive interface for trip management

**Link Organization**
- Add links to trips for organizing travel-related URLs
- Nested resource structure (trips have many links)
- URL validation to ensure valid web addresses

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
- Requires user authentication
- Uses Pundit for authorization

**LinksController**
- Nested CRUD operations under trips
- Requires user authentication
- Ensures users can only access links for their own trips

### Development Workflow

Before making any changes:
1. Ensure all tests pass (`bin/rails test`)
2. Run the linter (`bin/rubocop -f github`)
3. Run security scan (`bin/brakeman --no-pager`)

All development commands use the `bin/` prefix for consistency and to ensure the correct versions of tools are used.

### Database Schema

The application uses three main tables:
- `users` - User accounts with Devise fields and OAuth integration
- `trips` - Travel plans belonging to users
- `links` - URLs associated with trips

Foreign key relationships ensure data integrity, and dependent destroys clean up associated records when parent records are deleted.