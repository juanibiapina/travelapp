# Travel App

A Rails application for organizing and managing travel plans.

## Setup

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
