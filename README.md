LAE Blacklight
==============

Public UI for the LAE Project.

[![Build Status](https://travis-ci.org/pulibrary/lae-blacklight.png?branch=master)](https://travis-ci.org/pulibrary/lae-blacklight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/lae-blacklight/badge.png)](https://coveralls.io/r/pulibrary/lae-blacklight)
[![Dependency Status](https://gemnasium.com/pulibrary/lae-blacklight.svg)](https://gemnasium.com/pulibrary/lae-blacklight)

Application Configuration
------------------
### MySQL Installation

MacOS with Homebrew:

```bash
$ brew update
$ brew install mysql
$ brew services start mysql
```

### Copy Configuration Files

```bash
$ cp config/database.yml.tmpl config/database.yml
$ cp config/blacklight.yml.tmpl config/blacklight.yml
$ cp config/secrets.yml.tmpl config/secrets.yml
```

### Database Configuration
```bash
$ rake db:create
$ rake db:migrate
```

### Run
```bash
$ rake server
```

Deploying with Capistrano
------------------
Default branch for deployment is `master`. You can specify a branch using the BRANCH environment variable.

```
$ BRANCH=my_branch cap staging deploy # deploys my_branch to staging
$ cap staging deploy # deploys master branch to staging
```

Testing
------------------
### Run Tests

```bash
$ rake ci
```

### Run Tests Separately

```bash
$ rake server:test
```

Then, in another terminal window:

```bash
$ rake spec
```

To run a specific test:

```bash
$ rake spec SPEC=path/to/your_spec.rb:linenumber
```
