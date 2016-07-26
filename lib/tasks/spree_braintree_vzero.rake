namespace :spree_braintree_vzero do
  desc 'Updates states for BraintreeCheckouts and associated Orders with Payments'
  task update_states: :environment do
    puts Spree::BraintreeCheckout.update_states
  end
end
