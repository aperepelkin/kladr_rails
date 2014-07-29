$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kladr/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kladr"
  s.version     = Kladr::VERSION
  s.authors     = ["andrew"]
  s.email       = ["andrew@perepelkin.org"]
  s.homepage    = "http://ailabs.ru"
  s.summary     = "Implementation of KLADR"
  s.description = "Implementation of KLADR"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.8"

  s.add_development_dependency "sqlite3"
end
