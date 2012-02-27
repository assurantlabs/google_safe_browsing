module GoogleSafeBrowsing
  class Rescheduler
    @queue = :google_safe_browsing

    def self.perform
      puts "Running Update"
      delay = APIv2.update
      puts "Scheduling new update in #{delay} seconds"
      Resque.enqueue_in(delay.seconds, Rescheduler)
      puts "Update scheduled"
    end

  end
end
