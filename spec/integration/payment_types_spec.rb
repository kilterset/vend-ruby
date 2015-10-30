require 'spec_helper'

describe Vend::Resource::PaymentType do

  let(:expected_attributes) do
    {
      'id'              => '6cde3ba0-3d5f-11e0-8697-4040f540b50a',
      'name'            => 'Cash'
    }
  end

  let(:expected_collection_length) { 1 }

  it_behaves_like "a resource with a collection GET endpoint"
end
