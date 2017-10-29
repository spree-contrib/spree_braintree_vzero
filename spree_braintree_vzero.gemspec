# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_braintree_vzero/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_braintree_vzero'
  s.version     = SpreeBraintreeVzero.version
  s.summary     = 'Spree Braintree v.zero'
  s.description = 'Braintree v.zero extension for Spree Commerce'
  s.required_ruby_version = '>= 2.0.0'

  s.author    = 'Spark Solutions'
  s.email     = 'we@sparksolutions.co'
  s.homepage  = 'http://sparksolutions.co'
  s.license   = 'BSD-3'

  # s.files       = `git ls-files`.split("\n")
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 3.1.0', '< 4.0'
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_frontend', spree_version
  s.add_dependency 'spree_extension'

  s.add_dependency 'braintree', '>= 2.40.0'
  s.add_dependency 'whenever'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock', '~> 2.3' # https://github.com/bblimke/webmock/issues/683
  s.add_development_dependency 'therubyracer'
  s.add_development_dependency 'codeclimate-test-reporter'
end
