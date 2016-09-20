namespace :notifications do
  task :send => :environment do
    NotifyGuardian.notify_all
  end
end