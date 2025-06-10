# Contributing to Rails Template

Thank you for your interest in contributing to the Rails Template! This document provides all the information you need to get started with development.

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

**Account**
- Handles authentication via Devise with email/password and Google OAuth
- Includes provider/uid fields for OAuth integration
- Associated with a User for profile information

**User**
- Stores user profile information (name, picture)
- Associated with an Account for authentication

### Key Features

**User Authentication**
- Devise-based authentication with email/password
- Google OAuth integration for social login
- Account and User separation for flexible authentication

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
- Pundit for authorization (basic setup)
- PWA capabilities (partially implemented)

### Controllers

**ApplicationController**
- Base controller with Pundit integration
- Account-based authentication helpers

**HomeController**
- Landing page controller

**Account Controllers**
- Devise-generated controllers for authentication
- OAuth callback handling

### Development Workflow

Before committing changes:
1. Ensure all tests pass (`bin/rails test`)
2. Ensure system tests pass (`bin/rails test:system`)
3. Run the linter (`bin/rubocop -f github`)
4. Run security scan (`bin/brakeman --no-pager`)

All development commands use the `bin/` prefix for consistency and to ensure the correct versions of tools are used.

### Database Schema

The application uses two main tables:
- `accounts` - Authentication credentials with Devise fields and OAuth integration
- `users` - User profile information (name, picture) linked to accounts

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
