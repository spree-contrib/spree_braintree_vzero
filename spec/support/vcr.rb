require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.default_cassette_options = { match_requests_on: [:method, :host], record: :once }
  config.ignore_hosts 'codeclimate.com'
end
