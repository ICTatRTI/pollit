# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

require 'bundler/capistrano'
require 'rvm/capistrano'
set :rvm_ruby_string, '2.0.0'

set :application, "pollit"
set :repository,  "https://github.com/instedd/pollit"
set :scm, :git
set :deploy_via, :remote_cache
set :user, 'ubuntu'
set :group, 'ubuntu'
default_environment['TERM'] = ENV['TERM']

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc 'Exports version identifier'
  task :export_version, :roles => :app do
    branch = fetch(:branch).gsub(/\Arelease-/, '') rescue nil
    if branch
      run "echo #{branch} > #{release_path}/VERSION"
    else
      run "echo `git describe --tags --exact-match` > #{release_path}/VERSION; true"
    end
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs, :roles => :app do
    %W(nuntium database guisso hub).each do |file|
      run "ln -nfs #{shared_path}/#{file}.yml #{release_path}/config/"
    end
  end
end

namespace :foreman do
  desc 'Export the Procfile to Ubuntu upstart scripts'
  task :export, :roles => :app do
    run "echo -e \"PATH=$PATH\\nGEM_HOME=$GEM_HOME\\nGEM_PATH=$GEM_PATH\\nRAILS_ENV=production\" >  #{current_path}/.env"
    run "cd #{current_path} && rvmsudo bundle exec foreman export upstart /etc/init -l #{shared_path}/log -f #{current_path}/Procfile -a #{application} -u #{user} --concurrency=\"delayed=1,hub=1\""
  end

  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "sudo start #{application} || sudo restart #{application}"
  end
end

before "deploy:start", "deploy:migrate"
before "deploy:restart", "deploy:migrate"
before "deploy:assets:precompile", "deploy:symlink_configs"
before "deploy:assets:precompile", "deploy:export_version"

after "deploy:update", "foreman:export"    # Export foreman scripts
after "deploy:restart", "foreman:restart"   # Restart application scripts
