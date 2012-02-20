$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "google_safe_browsing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "google_safe_browsing"
  s.version     = GoogleSafeBrowsing::VERSION
  s.authors     = ["Chris Marshall"]
  s.email       = ["chris@chrismar035.com"]
  s.homepage    = "https://github.com/chrismar035/google_safe_browsing"
  s.summary     = "Integrates Google Safe Browsing API v2 into Rails 3 apps"
  s.description = "This gem provides an implementation of the Google Safe Browsing API directly for your Rails 3 applicaiont."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.0"

  s.add_development_dependency "sqlite3"
end
