LAE Blacklight
==============

Public UI for the LAE Project.

[![CircleCI](https://circleci.com/gh/pulibrary/lae-blacklight.svg?style=svg)](https://circleci.com/gh/pulibrary/lae-blacklight)

Development Configuration
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

Deploying with Capistrano
------------------
Default branch for deployment is `main`. You can specify a branch using the BRANCH environment variable.

```
$ BRANCH=my_branch cap staging deploy # deploys my_branch to staging
$ cap staging deploy # deploys main branch to staging
```

Auto-update from [Figgy](https://github.com/pulibrary/figgy) (formerly Plum)
------------------

Figgy announces events to a durable RabbitMQ fanout exchange. In order to use them, do the
following:

1. Configure the `events` settings in `config/config.yml`
2. Run `WORKERS=PlumEventHandler rake sneakers:run`

This will subscribe to the figgy events and update the LAE records when they're
created, updated, or deleted.

Indexing from Figgy
--------
### Creating a new index
1. Create a new collection via the solr admin panel
1. ssh to an lae box and start a tmux session because the index takes 2-2.5 hours. run `rake lae:reindex`

### Updating an existing index
If there's been any sort of interruption in the rabbitmq exchange, once it's
restored you'll probably need to reindex on production. During the downtime
things may have been deleted from figgy, so the preferred reindex process is to  write a fresh index and then swap over to it.

1. Create a new collection via the solr admin panel
1. Turn off sneakers workers on prod machines. This keeps us from missing updates that happen while we're building the new index.
1. ssh to an lae box and start a tmux session because the index takes 2-2.5 hours. run `rake lae:reindex_alternate SOLR_URL=[solr_url_with_new_collection]`
1. Once it's done, go to the solr admin panel and confirm that the index has the number of documents you expect. You have to submit an edismax query.
1. On the solr admin panel, swap the lae-prod alias to point to the new collection.
1. start sneakers workers again.
