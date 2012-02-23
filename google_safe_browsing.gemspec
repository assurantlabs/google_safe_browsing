$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "google_safe_browsing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "google_safe_browsing"
  s.version     = GoogleSafeBrowsing::VERSION
  s.authors     = 'Chris Marshall'
  s.email       = 'chris@chrismar035.com'
  s.homepage    = "https://github.com/chrismar035/google_safe_browsing"
  s.summary     = "Rails 3 plugin for Google's Safe Browsing API v2"
  s.description = "Rails 3 plugin using Google's Safe Browsing API for url lookup against Malware and Phishing " +
    "blacklists. Implementation includes storing and updating locally stored shavar lists and url lookup methods."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency 'ruby-ip', "~> 0.9.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "generator_spec"
end
