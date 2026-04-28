# DeployHQ API library and CLI client

> **DEPRECATED:** The CLI in this gem is deprecated and will be removed in a future release.
> Please use the new [DeployHQ CLI](https://github.com/deployhq/deployhq-cli) instead,
> which offers more features, fewer dependencies, and first-class support for AI-assisted workflows.
>
> The Ruby API library (`Deploy::Resource`, etc.) remains available for programmatic use.

## Installation

You'll need Ruby installed on your system. We've tested on `2.7.8` and later.

```
gem install deployhq
```

## Configuration

The CLI client will always look for the details of the current project in a
file called Deployfile in the current directory. This file should contain your
account URL, project permalink, username and API key, in JSON format. See
Deployfile.example for a reference Deployfile.

It is recommended each member of your team has their own Deployfile, since the
username and API key are user specific.

## Usage

### CLI (deprecated)

The CLI bundled in this gem is deprecated. Please use the
[new DeployHQ CLI](https://github.com/deployhq/deployhq-cli) instead.

### Ruby API

The `Deploy::Resource` API library remains available for programmatic access
to the DeployHQ platform. See the source under `lib/deploy/` for available
resources (Project, Deployment, Server, ServerGroup, etc.).

## Development

CLI improvements and new features should be directed to the
[deployhq-cli](https://github.com/deployhq/deployhq-cli) repository.
This gem will continue to receive maintenance updates for the Ruby API library.

## Release

This project uses [Google's release-please](https://github.com/googleapis/release-please) action which automates CHANGELOG generation, the creation of GitHub releases, and version bumps.

**Commit messages are important!**

`release-please` assumes that you are following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
This means that your commit messages should be structured in a way that release-please can determine the type of change that has been made.
Please refer to the ["How should I write my commits"](https://github.com/googleapis/release-please?tab=readme-ov-file#how-should-i-write-my-commits) documentation.
