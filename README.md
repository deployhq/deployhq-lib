# DeployHQ API library and CLI client

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

### CLI client

The CLI client is still experimental and requires some work. Currently it has
the ability to list all of the servers on a project, and make a new deployment
to the most recent revison of a repository.

#### List servers
```
$ deployhq servers
Ungrouped Servers
              Name : localhost
              Type : SSH/SFTP
              Path : /home/dan/testing/deploytest
            Branch : master
  Current Revision : 70039facbbfb014e4e57ff0bea2c7f6ec5e48e0a
          Hostname : localhost:22
```

#### Make a deployment
```
$ deployhq deploy
1. localhost (branch: master) (currently: 70039facbbfb014e4e57ff0bea2c7f6ec5e48e0a)
2. List Server Details
Please choose a server or group to deploy to:
1
Waiting for deployment capacity......
  Running pre-deployment checks...
  Checking access to repository
  Checking start and revisions are valid
  Checking connection to server localhost
  Beginning deployment from 70039facbbfb014e4e57ff0bea2c7f6ec5e48e0a to 70039facbbfb014e4e57ff0bea2c7f6ec5e48e0a
  Deployment started by Dan Wentworth
  Calculating changes required for deployment
[ localhost ] Connecting to server at localhost:22
[ localhost ] Connected to SFTP/SSH server at localhost:22
[ localhost ] 0 file(s) are no longer required and will be removed
[ localhost ] 0 file(s) have been changed and will be uploaded
[ localhost ] 0 config file(s) need to be uploaded
[ localhost ] Disconnected from SFTP/SSH server
  Deployment complete!
  Delivered notification to git-http-test-2 in test-repositories project.
```

## Development

The CLI client in particular is a bit experimental, and not yet finished. Any
pull-requests to improve it would be greatly welcomed.

## Release

This project uses [Google's release-please](https://github.com/googleapis/release-please) action which automates CHANGELOG generation, the creation of GitHub releases, and version bumps.

**Commit messages are important!**

`release-please` assumes that you are following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
This means that your commit messages should be structured in a way that release-please can determine the type of change that has been made.
Please refer to the ["How should I write my commits"](https://github.com/googleapis/release-please?tab=readme-ov-file#how-should-i-write-my-commits) documentation.
