require 'net/http'
require 'open-uri'
require 'active_record'

require 'google_safe_browsing/google_safe_browsing_railtie' if defined?(Rails)

require  'google_safe_browsing/version'

require  'google_safe_browsing/api_v2'
require  'google_safe_browsing/binary_helper'
require  'google_safe_browsing/canonicalize'
require  'google_safe_browsing/chunk_helper'
require  'google_safe_browsing/hash_helper'
require  'google_safe_browsing/http_helper'
require  'google_safe_browsing/response_helper'
require  'google_safe_browsing/top_level_domain'

require  'google_safe_browsing/add_shavar'
require  'google_safe_browsing/sub_shavar'
require  'google_safe_browsing/full_hash'

require  'google_safe_browsing/rescheduler'

module GoogleSafeBrowsing

  # Handles the configuration values for the module
  class Config
    attr_accessor :client, :app_ver, :p_ver, :host, :current_lists, :api_key,
      :mac_required, :client_key, :wrapped_key, :rekey_host

    def initialize
      @client         = 'api'
      @app_ver        = VERSION
      @p_ver          = '2.2'
      @host           = 'http://safebrowsing.clients.google.com/safebrowsing'
      @rekey_host    = 'https://sb-ssl.google.com/safebrowsing'
      @current_lists  = [ 'googpub-phish-shavar', 'goog-malware-shavar' ]
      @mac_required   = true
    end

    def have_keys?
      @mac_required && @client_key.present? && @wrapped_key.present?
    end
  end

  # Returns of initializes the Module configuration
  def self.config
    @@config ||= Config.new
  end

  # Allows for setting config values via a block
  def self.configure
    yield self.config
  end

  # Adds the Rescheduler job to Resque
  def self.kick_off
    Resque.enqueue(Rescheduler)
  end


  # Converts the official Google list name into the name to return
  #
  # @param (String) list the 'official' list name
  # @return (String) the friendly list name
  def self.friendly_list_name(list)
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
