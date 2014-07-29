$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "credits_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "credits_api"
  s.version     = CreditsApi::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CreditsApi."
  s.description = "TODO: Description of CreditsApi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.4"
  s.add_dependency "pg"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
end
