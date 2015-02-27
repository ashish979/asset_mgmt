namespace :db2fog_backup do
  desc "taking backup of db"
  task :db_backup => :environment do
    DB2Fog.new.backup
  end
end