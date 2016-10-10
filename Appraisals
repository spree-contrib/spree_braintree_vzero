appraise 'spree-3-1' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.1.0'
  gem 'test_after_commit'
end

appraise 'spree-3-1-spree-auth-devise' do
  gem 'spree', '~> 3.1.0'
  gem 'spree_auth_devise', '~> 3.1.0'
  gem 'test_after_commit'
end

appraise 'spree-master' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', github: 'spree/spree', branch: 'master'
end

appraise 'spree-master-spree-auth-devise' do
  gem 'spree', github: 'spree/spree', branch: 'master'
  gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: 'master'
end
