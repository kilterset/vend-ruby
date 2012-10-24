require './lib/vend'
require 'log4r'

STORE = ARGV[0]
USERNAME = ARGV[1]
PASSWORD = ARGV[2]

unless STORE and USERNAME and PASSWORD
  $stderr.puts "Usage: example.rb store username password"
  exit 1
end

client = Vend::Client.new(STORE, USERNAME, PASSWORD)

logger = Log4r::Logger.new 'vend'
logger.outputters = Log4r::Outputter.stdout
client.http_client.logger = client.logger = logger

# puts client.request('products', :method => :put, :body => '{"foo":"bar"}')

# puts "###### Products ######"
# client.Product.all.each do |product|
#   puts product.name
# end
#
# puts "###### Customers ######"
# client.Customer.all.each do |customer|
#   puts "#{customer.name} (#{customer.customer_code})"
# end
#
# puts "###### Creating a Customer ######"
# response = client.request('customers', :method => :post, :body => '{"customer_code":"foo"}')
# puts response
#
# puts "###### Finding a Customer by name ######"
# response = client.Customer.find_by_name('Foo')
# puts response.inspect
#
# puts "###### Finding a Customer by email ######"
# response = client.Customer.find_by_email('foo@example.com')
# puts response.inspect
#
# puts "###### Outlets ######"
# client.Outlet.all.each do |outlet|
#   puts outlet.name
# end
#
# puts "###### Payment Types ######"
# client.PaymentType.all.each do |payment_type|
#   puts payment_type.name
# end
