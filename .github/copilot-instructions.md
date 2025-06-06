This is a Rails app.

## General

- Use `bin/rails` to run Rails commands
- Don't run `bin/rails test:system` because it timeouts in the Copilot Environment - use `bin/rails test` instead
- Check CONTRIBUTING.md for development commands and application overview

## Before any commit

- Make sure tests pass (`bin/rails test`)
- Make sure there are no linter offences (`bin/rubocop -f github`)
- Make sure there are no security vulnerabilities (`bin/brakeman --no-pager`)
