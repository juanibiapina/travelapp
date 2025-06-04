# Travel App

A Rails application for organizing and managing travel plans.

## Requirements

* Ruby 3.4.2
* Rails 8.0+
* SQLite3

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Set up the database:
   ```bash
   bin/rails db:setup
   ```

## Running Tests

To run the test suite locally:

```bash
# Run all unit and integration tests
bin/rails test

# Run tests and reset database first
bin/rails test:db
```
