appraise 'spree-3-5' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.5.0'
end

appraise 'spree-3-5-spree-auth-devise' do
  gem 'spree', '~> 3.5.0'
  gem 'spree_auth_devise', '~> 3.3.0'
end

appraise 'spree-3-7' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.7.1'
end

appraise 'spree-3-7-spree-auth-devise' do
  gem 'spree', '~> 3.7.1'
  gem 'spree_auth_devise', '~> 3.3.0'
end

appraise 'spree-4-0' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 4.0.0'
end

appraise 'spree-4-0-spree-auth-devise' do
  gem 'spree', '~> 4.0.0'
  gem 'spree_auth_devise', '~> 4.0.0'
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
