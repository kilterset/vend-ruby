require 'spec_helper'

describe Vend::Resource::RegisterSale do
  let(:expected_attributes) do
    {
      'id'              => '98ce3dbf-e862-c811-fa93-10f6db3a8f66',
      'register_id'   => '6cbe2342-3d5f-11e0-8697-4040f540b50a',
      'market_id'            => '1'
    }
  end

  let(:client) do
    Vend::Client.new('foo', 'bar', 'baz')
  end

  let(:id) { '2e658bce-9627-bc27-d77d-6c9ba2e8216e' }

  let(:expected_collection_length) { 1 }

  it_behaves_like "a resource with a singular GET endpoint"
  it_behaves_like "a resource with a collection GET endpoint" do
    let(:append_to_url) { '?page_size=200' }
  end

  it "register_sales are findable by state" do
    expect(client.RegisterSale).to respond_to(:find_by_state)

    stub_request(:get, "https://bar:baz@foo.vendhq.com/api/register_sales?status[]=OPEN&status[]=CLOSED")
      .to_return(status: 200, body: get_mock_response('register_sales.find_by_state.json'))

    collection = client.RegisterSale.find_by_state([:OPEN, :CLOSED])
    expect(collection.first).to be_a Vend::Resource::RegisterSale
    expect(collection.first.id).to eq "8dd57077-c158-f7db-d582-6785f43c9d72"
    expect(collection.first.register_sale_products.count).to eq 2
  end
end
