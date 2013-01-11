set :output, "log/cron.log"

job_type :runner,  "cd :path && bundle exec rails runner -e :environment ':task' :output"

# Daily backup
every 1.day, :at => '4:00 am' do
  rake "backups:create:remote:daily"
end

# Weekly backup
every :friday, :at => '4:30 am' do
  rake "backups:create:remote:weekly"
end
