set :application, "demo"
set :repo_url, "git@github.com:at-uytran/chat-express.git"
set :branch, "master"
set :use_sudo, false
set :keep_releases, 5
set :forever_file, "forever.json"
set :app_name, "app"
set :stage, "production"
set :applicationdir, "/var/www/chat-express"
set :deploy_to, "/var/www/chat-express"

server "54.173.15.218", user: "uytv2", roles: %w{web app db}

namespace :deploy do
  after :updated, :install_node_modules
  after :publishing, :restart   
  after "deploy:symlink:release", "deploy:symlink_node_folders"
  after "deploy:cleanup", "deploy:node_additional_setup"

  def app_status
    within current_path do
      ps = JSON.parse(capture "forever list | grep #{fetch(:app_name)} | wc -l")
      if ps == 1
        return "running"
      else
        return "inactive"
      end
    end
  end

  desc "START the server"
  task :start do
    on roles(:app) do
      execute "cd #{fetch(:applicationdir)}/current/ && node_modules/.bin/forever start --sourceDir #{current_path} config/#{fetch(:forever_file)}"
    end
  end

  desc "STOP the server"
  task :stop do
    on roles(:app) do
      execute "cd #{fetch(:applicationdir)}/current/ && node_modules/.bin/forever stop #{fetch(:app_name)}"
    end
  end

  desc "START the server"
  task :restart do
    on roles(:app) do
      case app_status
      when "running"
        execute "cd #{fetch(:applicationdir)}/current/ && node_modules/.bin/forever restart #{fetch(:app_name)}"
      when "inactive"
        execute "cd #{fetch(:applicationdir)}/current/ && node_modules/.bin/forever start --sourceDir #{current_path} config/#{fetch(:forever_file)}"
      end
    end
  end

  task :symlink_node_folders do
    on roles(:app) do
      execute "ln -s #{fetch(:applicationdir)}/shared/node_modules #{fetch(:applicationdir)}/current/node_modules"
    end
  end

  task :node_additional_setup do
    on roles(:app) do
      execute "mkdir -p #{fetch(:applicationdir)}/shared/node_modules"
    end
  end

  desc "Install node modules"
  task :install_node_modules do
    on roles(:app) do
      within release_path do
        execute :npm, "install", "-s"
      end
    end
  end

  task :npm_install do
    on roles(:app) do
      execute "cd #{current_path}/ && npm install"
    end
  end

  task :npm_update do
    on roles(:app) do
      execute "cd #{current_path}/ && npm update"
    end
  end

  task :tail do
    on roles(:app) do
      execute "cd #{current_path}/ && npm update"
    end
  end
end
