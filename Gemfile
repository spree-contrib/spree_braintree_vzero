source 'https://rubygems.org'

gem 'spree', github: 'spree/spree', branch: '2-3-stable'

unless ENV['WITHOUT_SPREE_AUTH_DEVISE'] == 'true'
  gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-3-stable'
end

gem 'pg'
# Rails >= 4.1.14 requires mysql2 >= 0.3.13, < 0.4
gem 'mysql2', '~> 0.3.21'
gem 'webmock', '~> 1.24.6'

gemspec
