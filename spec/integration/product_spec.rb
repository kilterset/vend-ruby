require 'spec_helper'

describe Vend::Resource::Product do

  let(:expected_attributes) do
    {
      'id'      => '6cc53042-3d5f-11e0-8697-4040f540b50a',
      'handle'  => 'tshirt',
      'supply_price' => 2.00,
      'name'    => 'T-shirt (Demo)'
    }
  end

  let(:expected_collection_length) { 2 }

  it_should_behave_like "a resource with a collection GET endpoint"
  #it_should_behave_like "a resource with a DELETE endpoint"

  describe "pagination" do

    let(:username)  {"foo"}
    let(:password)  {"bar"}
    let(:store)     {"baz"}

    let(:client) do
      Vend::Client.new(store, username, password)
    end

    before do
      stub_request( :get,
        "https://#{username}:#{password}@#{store}.vendhq.com/api/products"
      ).to_return(
        :status => 200, :body => get_mock_response('products/page/1.json')
      )
      stub_request( :get,
        "https://#{username}:#{password}@#{store}.vendhq.com/api/products/page/2"
      ).to_return(
        :status => 200, :body => get_mock_response('products/page/2.json')
      )
    end

    it "returns paginated results" do
      client.Product.all.count.should == 4
    end

    it "returns the first result" do
      collection = client.Product.all
    end
  end

  describe "chaining" do
    let(:username)  {"foo"}
    let(:password)  {"bar"}
    let(:store)     {"baz"}

    let(:timestamp) { Time.new(2012,7,5,11,12,13) }

    let(:client) do
      Vend::Client.new(store, username, password)
    end

    before do
      stub_request( :get,
        "https://#{username}:#{password}@#{store}.vendhq.com/api/products/active/1/since/2012-07-05+11:12:13"
      ).to_return(
        :status => 200, :body => get_mock_response('products.active.since.json')
      )
    end

    it "allows scope chaining" do
      client.Product.active(1).since(timestamp).count.should == 3
    end


  end
end
