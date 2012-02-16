require 'spec_helper'

describe Vend::Resource::User do

  let(:username)  {"foo"}
  let(:password)  {"bar"}
  let(:store)     {"baz"}

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  let(:expected_attributes) do
    {
      'id'        => '6ce4286c-3d5f-11e0-8697-4040f540b50a',
      'username'  => 'user@example.com',
      'name'      => 'A cashier'
    }
  end

  let(:expected_collection_length) { 2 }

  it_should_behave_like "a resource with a collection GET endpoint"
end
