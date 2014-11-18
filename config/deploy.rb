# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'simple_rails'
set :repo_url, 'https://github.com/kevgathuku/simple-rails.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/apps/simple_rails'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/.env}

# skip migration if files in db/migrate not modified
set :conditionally_migrate, true

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :dotenv do
  desc "SCP transfer dotenv configuration to the shared folder"
  task :setup do
    on roles(:app) do
      upload! "config/.env", "#{shared_path}/.env", via: :scp
    end
  end

  desc "Symlink .env to the release path"
  task :symlink do
    on roles(:app) do
      execute "ln -sf #{shared_path}/.env #{release_path}/config/.env"
    end
  end
end
after "deploy:started", "dotenv:setup"
after 'deploy:updating', 'dotenv:symlink'