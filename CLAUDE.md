# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DeployHQ Ruby API library and CLI client. Provides programmatic access to the DeployHQ deployment platform and a command-line tool for triggering deployments.

## Development Commands

### Setup
```bash
bundle install
```

### Linting and testing
```bash
# Run all checks (linting + tests)
bundle exec rake

# Run only linting
bundle exec rubocop

# Run only tests
bundle exec rake test

# Run a specific test file
bundle exec ruby -Ilib:test test/configuration_test.rb
```

### Building the gem
```bash
gem build deployhq.gemspec
```

### Testing CLI locally
```bash
ruby -Ilib bin/deployhq <command>
```

## Architecture

### Core Components

**Deploy Module** (`lib/deploy.rb`): Main entry point that provides configuration management via `Deploy.configure` and `Deploy.configuration`. Configuration can be loaded from files using `Deploy.configuration_file=`.

**Resource System**: Base class pattern where `Deploy::Resource` provides ActiveRecord-like interface for API objects:
- `find(:all)` and `find(id)` for retrieval
- `save`, `create`, `update` for persistence
- `destroy` for deletion
- Child resources (Project, Deployment, Server, ServerGroup, DeploymentStep, DeploymentStepLog) inherit this behavior

**Request Layer** (`lib/deploy/request.rb`): HTTP client using Net::HTTP with basic auth. Handles JSON serialization/deserialization and translates HTTP status codes to appropriate exceptions or boolean success states.

**CLI** (`lib/deploy/cli.rb`): OptionParser-based command-line interface with three main commands:
- `configure`: Interactive setup wizard for creating Deployfile
- `servers`: Lists servers and server groups
- `deploy`: Interactive deployment workflow with real-time progress via WebSocket

**Configuration** (`lib/deploy/configuration.rb`): Loads from JSON Deployfile containing:
- `account`: DeployHQ account URL (e.g., https://account.deployhq.com)
- `username`: User email or username
- `api_key`: API key from user profile
- `project`: Default project permalink
- `websocket_hostname`: Optional WebSocket endpoint (defaults to wss://websocket.deployhq.com)

### Resource Relationships

Projects contain Servers and ServerGroups. Deployments belong to Projects and have DeploymentSteps. DeploymentSteps have DeploymentStepLogs. All child resources use the `:project` param to construct proper API paths like `projects/:permalink/deployments/:id`.

### WebSocket Integration

`Deploy::CLI::WebSocketClient` connects to deployment progress streams. `Deploy::CLI::DeploymentProgressOutput` consumes WebSocket messages and renders deployment progress to terminal in real-time.

## Release Process

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated releases via [release-please](https://github.com/googleapis/release-please).

**Commit Message Format**:
- `feat:` or `feature:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `chore:` - Maintenance tasks

On merge to master, release-please analyzes commits and creates a release PR. When merged, it:
1. Updates CHANGELOG.md
2. Bumps version in lib/deploy/version.rb
3. Creates GitHub release
4. Publishes gem to RubyGems

## Configuration File

Each developer needs a `Deployfile` in their working directory (not committed). Use `deployhq configure` to generate interactively, or create manually following `Deployfile.example`.