source 'https://rubygems.org'

gem 'spree', '~> 3.1.0.rc1'

# Provides basic authentication functionality for testing parts of your engine
unless ENV['WITHOUT_SPREE_AUTH_DEVISE'] == 'true'
  gem 'spree_auth_devise', '~> 3.1.0.rc1'
end

gem 'pg'
gem 'mysql2'
gem 'webmock', '~> 1.24.6'

gem 'test_after_commit', group: :test

gemspec
