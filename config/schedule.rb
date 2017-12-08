set :output, {:error => 'log/cron_error.log', :standard => 'log/cron_standard.log'}

if @environment == 'production'
  every 1.day, :at => '10:00 pm', :roles => [:db] do
    runner 'DB2Fog.new.backup'
  end

  every 1.day, :roles => [:db] do
    runner 'DB2Fog.new.clean'
  end
end
