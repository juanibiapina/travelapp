# GitHub Copilot Development Environment

This directory contains configuration files for customizing the development environment when using GitHub Copilot.

## Files

- `setup.sh` - Setup script that automatically configures the development environment
- `README.md` - This documentation file

## What the setup does

The setup script automatically:

1. **Installs rbenv** if not already available (Ruby version manager)
2. **Installs Ruby 3.4.2** as specified in `.ruby-version`
3. **Installs bundler** for managing Ruby dependencies
4. **Runs the existing `bin/setup` script** which:
   - Installs all gem dependencies via `bundle install`
   - Prepares the database
   - Clears logs and temporary files

## Manual Setup

If you prefer to set up the environment manually, you can run:

```bash
./.github/copilot/setup.sh
```

Or follow the individual steps:

```bash
# Install Ruby 3.4.2 (using rbenv, rvm, or your preferred method)
rbenv install 3.4.2
rbenv local 3.4.2

# Install bundler
gem install bundler

# Run the Rails setup script
./bin/setup
```

## Starting the Development Server

After setup is complete, start the development server with:

```bash
bin/dev
```

This will start the Rails server on the default port (usually http://localhost:3000).