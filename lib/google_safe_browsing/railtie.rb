module GoogleSafeBrowsing
  class Railtie < Rails::Railtie
    generators do
      require File.expand_path('../generators/chunk_generator', __FILE__)
      require File.expand_path('../generators/shavar_generator', __FILE__)
    end
  end
end
