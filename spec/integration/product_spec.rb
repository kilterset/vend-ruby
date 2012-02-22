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
end
