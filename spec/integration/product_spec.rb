require 'spec_helper'

describe Vend::Resource::Product do

  let(:expected_attributes) do
    {
      'id'      => '6cc53042-3d5f-11e0-8697-4040f540b50a',
      'handle'  => 'tshirt',
      'name'    => 'T-shirt (Demo)'
    }
  end

  let(:expected_collection_length) { 2 }

  it_should_behave_like "a resource with a collection GET endpoint"
  it_should_behave_like "a resource with a DELETE endpoint"

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
      client.Product.all.length.should == 4
    end
  end
end
