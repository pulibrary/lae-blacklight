# frozen_string_literal: true
if Rails.env.development? || Rails.env.test?
  namespace :servers do
    desc "Start solr and postgres servers using lando."
    task start: :environment do
      system("lando start")
      system('rake servers:seed')
      system('rake servers:seed RAILS_ENV=test')
    end

    task seed: :environment do
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['lae:index_fixtures'].invoke
    end

    desc "Stop lando solr and postgres servers."
    task stop: :environment do
      system("lando stop")
    end
  end
end
