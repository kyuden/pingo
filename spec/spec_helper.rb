$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pingo'
require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'support/env_macros'

RSpec.configure do |c|
  c.include ENVMacros
  c.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name) { example.call }
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassette_library'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end
