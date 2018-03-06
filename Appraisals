appraise 'spree-3-1' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.1.0'
  gem 'test_after_commit'
  gem "rails_test_params_backport", group: :test
  gem "rails", "~> 4.2.10"
end

appraise 'spree-3-1-spree-auth-devise' do
  gem 'spree', '~> 3.1.0'
  gem 'spree_auth_devise', '~> 3.1.0'
  gem 'test_after_commit'
  gem "rails_test_params_backport", group: :test
  gem "rails", "~> 4.2.10"
end

appraise 'spree-3-2' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.2.0'
end

appraise 'spree-3-2-spree-auth-devise' do
  gem 'spree', '~> 3.2.0'
  gem 'spree_auth_devise', '~> 3.2.0'
end

appraise 'spree-3-3' do
  ENV['WITHOUT_SPREE_AUTH_DEVISE'] = 'true'

  gem 'spree', '~> 3.3.0'
end

appraise 'spree-3-3-spree-auth-devise' do
  gem 'spree', '~> 3.3.0'
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
