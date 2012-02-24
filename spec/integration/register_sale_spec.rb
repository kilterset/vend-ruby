require 'spec_helper'

describe Vend::Resource::RegisterSale do

  let(:expected_attributes) do
    {
      'id'              => '98ce3dbf-e862-c811-fa93-10f6db3a8f66',
      'register_id'   => '6cbe2342-3d5f-11e0-8697-4040f540b50a',
      'market_id'            => '1'
    }
  end

  let(:id) { '2e658bce-9627-bc27-d77d-6c9ba2e8216e' }

  let(:expected_collection_length) { 1 }

  it_should_behave_like "a resource with a singular GET endpoint"
  it_should_behave_like "a resource with a collection GET endpoint"
end
