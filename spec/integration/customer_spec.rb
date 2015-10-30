require 'spec_helper'

describe Vend::Resource::Customer do
  let(:expected_attributes) do
    {
      'id'              => '6cbfbc20-3d5f-11e0-8697-4040f540b50a',
      'customer_code'   => 'WALKIN',
      'name'            => ''
    }
  end

  let(:client) do
    Vend::Client.new('foo', 'bar', 'baz')
  end

  let(:expected_collection_length) { 1 }

  specify :find_by_email do
    expect(client.Customer).to respond_to(:find_by_email)
  end

  specify :find_by_name do
    expect(client.Customer).to respond_to(:find_by_name)
  end

  it "returns a collection of customers from a search" do
    stub_request(:get, "https://bar:baz@foo.vendhq.com/api/customers?email=foo@example.com")
      .to_return(status: 200, body: get_mock_response('customers.find_by_email.json'))

    collection = client.Customer.find_by_email('foo@example.com')
    expect(collection.first).to be_a Vend::Resource::Customer
    expect(collection.first.email).to eq 'foo@example.com'
  end

  it_behaves_like "a resource with a collection GET endpoint"
end
