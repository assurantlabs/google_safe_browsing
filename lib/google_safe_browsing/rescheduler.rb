module GoogleSafeBrowsing
  class Rescheduler
    @queue = :google_safe_browsing

    def self.perform
      GoogleSafeBrowsing.logger.info "Running Update"
      delay = APIv2.update
      GoogleSafeBrowsing.logger.info "Scheduling new update in #{delay} seconds"
      Resque.enqueue_in(delay.seconds, Rescheduler)
      GoogleSafeBrowsing.logger.info "Update scheduled"
    end

  end
end
