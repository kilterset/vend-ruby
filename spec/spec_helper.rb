$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
require 'pry'
Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'cgi'
require 'vend'

RSpec.configure do |config|
  config.mock_with(:rspec) { |c| c.syntax = [:should, :expect] }
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end

def get_mock_response(file)
  File.read(File.join(File.dirname(__FILE__), 'mock_responses/', file))
end
