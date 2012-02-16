require 'spec_helper'

describe Vend::Resource::Customer do

  let(:expected_attributes) do
    {
      'id'              => '6cbfbc20-3d5f-11e0-8697-4040f540b50a',
      'customer_code'   => 'WALKIN',
      'name'            => ''
    }
  end

  let(:expected_collection_length) { 1 }

  it_should_behave_like "a resource with a collection GET endpoint"
end
