namespace :google_safe_browsing do
  desc "Performs an Update"
  task :update => :environment do
    GoogleSafeBrowsing::APIv2.update
  end

  desc "Enqueues an Update via Rescheduler, which will reschedule another Update the appropriate number of seconds in the future"
  task :update_and_reschedule => :environment do
    GoogleSafeBrowsing.kick_off
  end
end
