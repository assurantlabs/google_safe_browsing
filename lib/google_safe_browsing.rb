require 'net/http'
require 'open-uri'
require 'active_record'

require 'google_safe_browsing/google_safe_browsing_railtie' if defined?(Rails)

require File.dirname(__FILE__) + '/google_safe_browsing/api_v2'
require File.dirname(__FILE__) + '/google_safe_browsing/binary_helper'
require File.dirname(__FILE__) + '/google_safe_browsing/canonicalize'
require File.dirname(__FILE__) + '/google_safe_browsing/chunk_helper'
require File.dirname(__FILE__) + '/google_safe_browsing/hash_helper'
require File.dirname(__FILE__) + '/google_safe_browsing/http_helper'
require File.dirname(__FILE__) + '/google_safe_browsing/response_helper'
require File.dirname(__FILE__) + '/google_safe_browsing/top_level_domain'

require File.dirname(__FILE__) + '/google_safe_browsing/add_shavar'
require File.dirname(__FILE__) + '/google_safe_browsing/sub_shavar'
require File.dirname(__FILE__) + '/google_safe_browsing/full_hash'

require File.dirname(__FILE__) + '/google_safe_browsing/rescheduler'

module GoogleSafeBrowsing
  class Config
    attr_accessor :client, :app_ver, :p_ver, :host, :current_lists, :api_key

    def initialize
      @client         = 'api'
      @app_ver        = VERSION
      @p_ver          = '2.2'
      @host           = 'http://safebrowsing.clients.google.com/safebrowsing'
      @current_lists  = [ 'googpub-phish-shavar', 'goog-malware-shavar' ]
    end
  end

  def self.config
    @@config ||= Config.new
  end

  def self.configure
    yield self.config
  end

  def self.kick_off
    Resque.enqueue(Rescheduler)
  end


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
