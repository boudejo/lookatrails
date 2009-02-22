#############################################################
#	APPLICATION
#############################################################

set :application, "LookAtRails"
# set :deploy_to, "/var/www/#{application}"

#############################################################
#	SETTINGS
#############################################################

default_run_options[:pty] = true
set :use_sudo, false

#############################################################
#	SERVERS
#############################################################

role :app, "www.lookatrails.be"
role :web, "www.lookatrails.be"
role :db,  "www.lookatrails.be", :primary => true

#############################################################
#	SCM
#############################################################

set :scm, :subversion

set :repository,    "https://butsjoh@thinkweb.springloops.com:443/source/pis/trunk"
set :svn,           "/usr/local/bin/svn"
set :scm_username,  "boudejo"
set :scm_password,  "nonetw@!"
set :checkout,      "export"
#set :ssh_options, { :forward_agent => true }

#############################################################
#	PASSENGER
#############################################################

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

#############################################################
#	CUSTOM TASK
#############################################################

namespace :thinkweb do
  task :run_deployment, :roles => :app do
    #run "cd #{release_path} && rake minifier:minify" if rails_env == :production
  end
end

after :deploy, "thinkweb:run_deployment"