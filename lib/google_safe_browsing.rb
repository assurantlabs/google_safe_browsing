require 'net/http'
require 'open-uri'
require 'active_record'

require 'google_safe_browsing/google_safe_browsing_railtie' if defined?(Rails)

require File.dirname(__FILE__) + '/google_safe_browsing/api_v2'
require File.dirname(__FILE__) + '/google_safe_browsing/canonicalize'
require File.dirname(__FILE__) + '/google_safe_browsing/add_shavar'
require File.dirname(__FILE__) + '/google_safe_browsing/sub_shavar'
require File.dirname(__FILE__) + '/google_safe_browsing/full_hash'
require File.dirname(__FILE__) + '/google_safe_browsing/top_level_domain'
require File.dirname(__FILE__) + '/google_safe_browsing/http_helper'
require File.dirname(__FILE__) + '/google_safe_browsing/binary_helper'

module GoogleSafeBrowsing
  CLIENT  = 'api'
  API_KEY = 'ABQIAAAAyLR3IaNHXuIIDgTUlo9YORTqV6MDxWSrNbRxMC53QkjhMk0eYw'
  APP_VER = VERSION
  P_VER   = '2.2'
  HOST    = 'http://safebrowsing.clients.google.com/safebrowsing'
  PARAMS  = { :client => CLIENT, :apikey => API_KEY, :appver => APP_VER, 
    :pver => P_VER }
  CURRENT_LISTS = [ 'googpub-phish-shavar', 'goog-malware-shavar' ]
end
