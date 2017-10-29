FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_braintree_vzero/factories'

  Dir[Dir.pwd + '/spec/factories/**/*'].each do |factory|
    require File.expand_path(factory)
  end
end
