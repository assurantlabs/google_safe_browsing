require 'net/http'
require 'open-uri'
require 'active_record'

require 'google_safe_browsing/google_safe_browsing_railtie' if defined?(Rails)

require  'google_safe_browsing/version'

require  'google_safe_browsing/api_v2'
require  'google_safe_browsing/binary_helper'
require  'google_safe_browsing/canonicalize'
require  'google_safe_browsing/chunk_helper'
require  'google_safe_browsing/chunk_list'
require  'google_safe_browsing/hash_helper'
require  'google_safe_browsing/http_helper'
require  'google_safe_browsing/invalid_mac_validation'
require  'google_safe_browsing/key_helper'
require  'google_safe_browsing/response_helper'
require  'google_safe_browsing/top_level_domain'

require  'google_safe_browsing/shavar'
require  'google_safe_browsing/add_shavar'
require  'google_safe_browsing/sub_shavar'
require  'google_safe_browsing/full_hash'

require  'google_safe_browsing/rescheduler'

module GoogleSafeBrowsing
  # Handles the configuration values for the module
  class Config
    attr_accessor :client, :app_ver, :p_ver, :host, :current_lists, :api_key

    def initialize
      @client = 'api'
      @app_ver = VERSION
      @p_ver = '3.0'
      @host = 'https://safebrowsing.google.com/safebrowsing'
      @current_lists = ['googpub-phish-shavar', 'goog-malware-shavar']
    end
  end

  class << self
    attr_accessor :logger

    def logger
      @logger ||= Logger.new
    end

    # Returns of initializes the Module configuration
    def config
      @@config ||= Config.new
    end

    # Allows for setting config values via a block
    def configure
      yield config
    end

    # Adds the Rescheduler job to Resque
    def kick_off
      Resque.enqueue(Rescheduler)
    end

    # Converts the official Google list name into the name to return
    #
    # @param (String) list the 'official' list name
    # @return (String) the friendly list name
    def friendly_list_name(list)
      case list
      when 'goog-malware-shavar'
        'malware'
      when 'googpub-phish-shavar'
        'phishing'
      else
        nil
      end
    end
  end
end
