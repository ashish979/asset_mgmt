set :branch, "Rails4"
set :rails_env, 'staging'
set :deploy_to, "/var/www/#{application}_#{ rails_env }"
role :web, "176.58.108.178"       
role :app, "176.58.108.178"                          
role :db,  "176.58.108.178", :primary => true 
