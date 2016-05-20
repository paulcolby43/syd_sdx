# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"
set :environment, 'development'

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :reboot do
  # CentOS VM
  job_type :application, "cd /usr/local/Ruby/syd_qbo_dev && :task :output"
#  
  # Mac Mini
#  job_type :application, "cd /Users/syd/RubyProjects/syd_sdx_dev && :task :output"
  
  application "bundle exec unicorn -l 8081 -E development"
#  command "redis-server" # Start redis
  application "bundle exec sidekiq"
end
#
## Clear out public/uploads/tmp directory
#every 1.day, :at => '4:30 am' do
#  runner "CarrierWave.clean_cached_files!"
#end
#
## Check SYD licensing via Jpegger service call
#every 1.day, :at => '4:30 am' do
#  runner "License.dog_license_check"
#end

# Clear out public/uploads/tmp directory
every 1.day, :at => '4:30 am' do
  runner "CarrierWave.clean_cached_files!"
  runner "ImageFile.delete_files"
  runner "ShipmentFile.delete_files"
  runner "CustPicFile.delete_files"
  
  ### Remove Temporary Leads Online and BWI XML Files Older than One Day ###
  #command "find /usr/local/Ruby/syd_qbo_dev/public/leads_online/* -mtime +1 -exec rm {} \;" 
  #command "find /usr/local/Ruby/syd_qbo_dev/public/bwi/* -mtime +1 -exec rm {} \;"
end