require 'spec_helper'

describe Vend::Resource::Supplier do
  let(:expected_attributes) do
    {
      'id' => '9fc84329-2d20-11e2-8057-080027706aa2',
      'name'   => 'Brewer Supplies Ltd.'
    }
  end

  let(:expected_collection_length) { 1 }

  it_behaves_like "a resource with a collection GET endpoint"
end
