require 'rails/railtie'
module SpreeBraintreeVzero
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/spree_braintree_vzero.rake"
    end
  end
end