module GoogleSafeBrowsing
  class GoogleSafeBrowsingRailtie < Rails::Railtie
    config.google_safe_browsing = ActiveSupport::OrderedOptions.new

    rake_tasks do
      load File.expand_path('../../tasks/google_safe_browsing_tasks.rake', __FILE__)
    end

    generators do
      require File.expand_path('../../generators/install_generator', __FILE__)
    end

    initializer 'google_safe_browsing.set_api_key' do |app|
      GoogleSafeBrowsing.configure do |config|
        config.api_key = app.config.google_safe_browsing[:api_key]
      end
    end

    initializer 'Rails logger' do
      GoogleSafeBrowsing.logger = Rails.logger
    end
  end
end
