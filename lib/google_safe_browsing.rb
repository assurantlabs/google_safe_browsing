require 'net/http'
require 'open-uri'
#require File.dirname(__FILE__) + '/google_safe_browsing/version.rb'

require 'google_safe_browsing/railtie' if defined?(Rails)

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
