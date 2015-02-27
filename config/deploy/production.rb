set :branch, "Rails4_production"
set :rails_env, 'production'
set :deploy_to, "/var/www/#{application}_#{ rails_env }"
set :ssh_options, { :forward_agent => true, :port => 13813 }
role :web, "37.139.19.126"       
role :app, "37.139.19.126"                          
role :db,  "37.139.19.126", :primary => true 

before "deploy:migrate", "deploy:db_backup"