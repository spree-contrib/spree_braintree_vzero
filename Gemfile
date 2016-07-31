source 'https://rubygems.org'
gem 'spree', github: 'spree/spree', branch: 'master'

# Provides basic authentication functionality for testing parts of your engine
unless ENV['WITHOUT_SPREE_AUTH_DEVISE'] == 'true'
  gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: 'master'
end

gem 'pg'
gem 'mysql2'
gem 'webmock', '~> 1.24.6'

gem 'test_after_commit', group: :test

gemspec
