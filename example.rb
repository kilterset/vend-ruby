require './lib/vend'
STORE = 'gregdeveloper'
USERNAME = 'greg.signal@trineo.co.nz'
PASSWORD = 'this is a very strong password'
client = Vend::Client.new(STORE, USERNAME, PASSWORD)

class Vend::Resource::Product < Vend::Base
end

response = client.request('products')
puts response

Vend::Resource::Product.all(client).each do |product|
  puts "Product Name: #{product.name}"
  puts "Inventory: #{product.inventory}"
end
