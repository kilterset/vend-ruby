require './lib/vend'
STORE = 'gregdeveloper'
USERNAME = 'greg.signal@trineo.co.nz'
PASSWORD = 'this is a very strong password'
client = Vend::Client.new(STORE, USERNAME, PASSWORD)

puts client.request('customers')
