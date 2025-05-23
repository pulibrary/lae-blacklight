set :application, 'lae-blackight'
set :repo_url, 'https://github.com/pulibrary/lae-blacklight.git'

# Default branch is :main
set :branch, ENV['BRANCH'] || 'main'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/lae'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

shared_path = "#{:deploy_to}/shared"

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, [])

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'log')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

desc "Write the current version to public/version.txt"
task :write_version do
  on roles(:app), in: :sequence do
    within repo_path do
      execute :tail, "-n1 ../revisions.log > #{release_path}/public/version.txt"
    end
  end
end
after 'deploy:log_revision', 'write_version'

# Force passenger to use touch tmp/restart.txt instead of
# passenger-config restart-app which requires sudo access
set :passenger_restart_with_touch, true

namespace :application do
  # You can/ should apply this command to a single host
  # cap --hosts=lae-staging1.princeton.edu staging application:remove_from_nginx
  desc "Marks the server(s) to be removed from the loadbalancer"
  task :remove_from_nginx do
    count = 0
    on roles(:app) do
      count += 1
    end
    if count > (roles(:app).length / 2)
      raise "You must run this command on no more than half the servers utilizing the --hosts= switch"
    end
    on roles(:app) do
      within release_path do
        execute :touch, "public/remove-from-nginx"
      end
    end
  end

  # You can/ should apply this command to a single host
  # cap --hosts=lae-staging1.princeton.edu staging application:serve_from_nginx
  desc "Marks the server(s) to be added back to the loadbalancer"
  task :serve_from_nginx do
    on roles(:app) do
      within release_path do
        execute :rm, "-f public/remove-from-nginx"
      end
    end
  end
end

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :sneakers do
  task :restart do
    on roles(:worker) do
      execute :sudo, :service, "lae-sneakers", :restart
    end
  end
end

namespace :solr do
  desc "Opens Solr Console"
  task :console do
    primary_app = primary(:app)
    solr_host = fetch(:stage, "production").to_s == "production" ? "lib-solr-prod7" : "lib-solr-staging4d"
    port = rand(9000..9999)
    puts "Opening Solr Console on port #{port}"
    Net::SSH.start(solr_host, primary_app.user) do |session|
      session.forward.local(port, "localhost", 8983)
      puts "Press Ctrl+C to end Console connection"
      `open http://localhost:#{port}`
      session.loop(0.1) { true }
    end
  end
end

after 'deploy:reverted', 'sneakers:restart'
after 'deploy:published', 'sneakers:restart'
