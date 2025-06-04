# README

## Setup Instructions

After cloning this Rails template, you should customize the project title:

1. Open `app/views/layouts/application.html.erb`
2. Change the title from `"TODO: Rails template"` to your desired project name
3. This will update the browser tab title for your application

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

## Deployment

This application is configured for automatic deployment to fly.io when code is merged to the main branch.

### Setup

1. Create a fly.io app: `fly apps create travelapp`
2. Add the `FLY_API_TOKEN` secret to your GitHub repository:
   - Get your token: `fly auth token`
   - Add it to GitHub: Settings → Secrets → Actions → New repository secret
   - Name: `FLY_API_TOKEN`
   - Value: Your fly.io auth token

### Deployment Process

- When a PR is merged to main, the CI workflow runs automatically
- After CI passes successfully, the deploy workflow triggers automatically
- The app is deployed using the configuration in `fly.toml`
- Database migrations run automatically during deployment

* ...
