require 'bundler/setup'
require 'api_struct'
require 'vcr'
require 'webmock/rspec'
require 'ffaker'

Dir[File.expand_path('spec/support/**/*.rb')].each { |file| require file }

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/cassettes'
  config.default_cassette_options = { record: :new_episodes }
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.order = :random
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
