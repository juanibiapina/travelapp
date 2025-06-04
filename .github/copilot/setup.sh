#!/bin/bash
set -e

echo "🤖 Setting up development environment for GitHub Copilot..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install rbenv if not available
if ! command_exists rbenv; then
    echo "📦 Installing rbenv..."
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# Ensure PATH includes rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)" 2>/dev/null || true

# Get the required Ruby version from .ruby-version
RUBY_VERSION=$(cat .ruby-version | sed 's/^ruby-//')
echo "🔧 Required Ruby version: $RUBY_VERSION"

# Install Ruby if not available or wrong version
if ! rbenv versions --bare | grep -q "^$RUBY_VERSION$"; then
    echo "📦 Installing Ruby $RUBY_VERSION..."
    rbenv install "$RUBY_VERSION"
fi

# Set the Ruby version for this project
rbenv local "$RUBY_VERSION"

# Ensure we're using the correct Ruby version
eval "$(rbenv init -)"
rbenv shell "$RUBY_VERSION"

# Install bundler if not available
if ! command_exists bundle; then
    echo "📦 Installing bundler..."
    gem install bundler
fi

# Run the existing setup script
echo "🚀 Running project setup..."
chmod +x bin/setup
./bin/setup --skip-server

echo "✅ Development environment setup complete!"
echo "💡 You can now run 'bin/dev' to start the development server"