LAE Blacklight
==============

Public UI for the LAE Project.

[![CircleCI](https://circleci.com/gh/pulibrary/lae-blacklight.svg?style=svg)](https://circleci.com/gh/pulibrary/lae-blacklight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/lae-blacklight/badge.png)](https://coveralls.io/r/pulibrary/lae-blacklight)
[![Dependency Status](https://gemnasium.com/pulibrary/lae-blacklight.svg)](https://gemnasium.com/pulibrary/lae-blacklight)

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

#### Gem Dependencies

While invoking `bundler install`, the following may be encountered:

```bash
Installing therubyracer 0.12.3 with native extensions
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    current directory:
/ruby/2.6.5/lib/ruby/gems/2.6.0/gems/therubyracer-0.12.3/ext/v8
/ruby/2.6.5/bin/ruby -I
/ruby/2.6.5/lib/ruby/2.6.0 -r ./siteconf20210517-40265-18a3ouc.rb extconf.rb --with-v8-dir\=/usr/local/opt/v8
checking for -lpthread... yes
checking for -lobjc... yes
checking for v8.h... no
*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.
```

This is an issue related to the C header dependencies for the `libv8` and `therubyracer` Gems. One approach which may resolve this is the following:

```bash
brew install v8@3.15
bundle config build.libv8 --with-system-v8
bundle config build.therubyracer --with-v8-dir=$(brew --prefix v8@3.15)
bundle install
```

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
