$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "google_safe_browsing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "google_safe_browsing"
  s.version     = GoogleSafeBrowsing::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of GoogleSafeBrowsing."
  s.description = "TODO: Description of GoogleSafeBrowsing."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.1.3"
  s.add_dependency 'ruby-ip', "~> 0.9.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
