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

  specify { client.Customer.should respond_to(:find_by_email) }
  specify { client.Customer.should respond_to(:find_by_name) }

  it "returns a collection of customers from a search" do
    stub_request(:get, "https://bar:baz@foo.vendhq.com/api/customers?email=foo@example.com").
      to_return(:status => 200, :body => get_mock_response('customers.find_by_email.json'))

    collection = client.Customer.find_by_email('foo@example.com')
    collection.first.should be_a Vend::Resource::Customer
    collection.first.email.should == 'foo@example.com'
  end

  it_should_behave_like "a resource with a collection GET endpoint"

end
