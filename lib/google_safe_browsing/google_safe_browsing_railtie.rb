module GoogleSafeBrowsing
  class GoogleSafeBrowsingRailtie < Rails::Railtie
    generators do
      require File.expand_path('../../generators/install_generator', __FILE__)
    end
  end
end
