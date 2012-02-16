require 'spec_helper'

describe Vend::Resource::Register do

  let(:expected_attributes) do
    {
      'id'              => '6cbe2342-3d5f-11e0-8697-4040f540b50a',
      'receipt_header'  => '<h1>Trineo Dev Account<h1>',
      'name'            => 'Main Register'
    }
  end

  let(:expected_collection_length) { 1 }

  it_should_behave_like "a resource with a collection GET endpoint"
end
