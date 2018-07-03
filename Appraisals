appraise 'spree-3-2' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.2.0'
end

appraise 'spree-3-2-spree-auth-devise' do
  gem 'spree', '~> 3.2.0'
  gem 'spree_auth_devise', '~> 3.2.0'
end

appraise 'spree-3-5' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.5.0'
end

appraise 'spree-3-5-spree-auth-devise' do
  gem 'spree', '~> 3.5.0'
  gem 'spree_auth_devise', '~> 3.3.0'
end

appraise 'spree-3-6' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.6.1'
end

appraise 'spree-3-6-spree-auth-devise' do
  gem 'spree', '~> 3.6.1'
  gem 'spree_auth_devise', '~> 3.3.0'
end

appraise 'spree-master' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', github: 'spree/spree', branch: 'master'
  gem 'rails-controller-testing'
end

appraise 'spree-master-spree-auth-devise' do
  gem 'spree', github: 'spree/spree', branch: 'master'
  gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: 'master'
  gem 'rails-controller-testing'
end
