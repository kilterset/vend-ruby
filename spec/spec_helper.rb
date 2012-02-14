$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
Dir["./spec/support/**/*.rb"].each {|f| require f}

require 'vend'

RSpec.configure do |config|

end

def get_mock_response(file)
  File.read(File.join(File.dirname(__FILE__), 'mock_responses/', file))
end
