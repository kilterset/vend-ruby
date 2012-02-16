require 'spec_helper'

describe Vend::Resource::Tax do

  let(:username)  {"foo"}
  let(:password)  {"bar"}
  let(:store)     {"baz"}

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  let(:expected_attributes) do
    {
      'id'        => '53b3501c-887c-102d-8a4b-a9cf13f17faa',
      'default'   => 1,
      'rate'      => 0.15
    }
  end

  let(:expected_collection_length) { 1 }

  it_should_behave_like "a resource with a collection GET endpoint"
end
