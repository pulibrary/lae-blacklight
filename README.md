LAE Blacklight
==============

Public UI for the LAE Project.

[![CircleCI](https://circleci.com/gh/pulibrary/lae-blacklight.svg?style=svg)](https://circleci.com/gh/pulibrary/lae-blacklight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/lae-blacklight/badge.png)](https://coveralls.io/r/pulibrary/lae-blacklight)

Application Configuration
------------------
### Postgres

MacOS with Homebrew:

```bash
$ brew update
$ brew install postgresql
$ brew services start postgresql
```

### Database Setup
```bash
$ rake db:create
$ rake db:migrate
```

### Run
```bash
$ rake server
```

This will start Solr, index some sample data, and run the application.

### Reloading sample data
Clear your solr index with:
```bash
$ rake lae:drop_index
```

Then index sample data with:
```bash
$ rake lae:index_fixtures
```
Note: This will take about an hour to finish indexing all data, but data will show up in your index after
500 records have been indexed.

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


Auto-update from [Plum](https://github.com/pulibrary/plum)
------------------

Plum announces events to a durable RabbitMQ fanout exchange. In order to use them, do the
following:

1. Configure the `events` settings in `config/config.yml`
2. Run `WORKERS=PlumEventHandler rake sneakers:run`

This will subscribe to the plum events and update the LAE records when they're
created, updated, or deleted.
