require 'spec_helper'

describe Vend::Base do
  class Vend::Resource::Foo < Vend::Base #:nodoc
  end

  let(:client) { mock(:client) }
  let(:attribute_hash) { {:key => "value"} }
  let(:mock_response) { 
      {
        "foos"=>[
            {"id"=>"1","bar"=>"baz"},
            {"id"=>"2","flar"=>"flum"}
        ]
      }
  }

  subject { Vend::Resource::Foo.new(client, :attrs => attribute_hash) }

  it "creates an instance of Foo" do
    subject.should be_instance_of(Vend::Resource::Foo)
  end

  it "assigns the client" do
    subject.client.should == client
  end

  it "assigns the attributes" do
    subject.attrs.should == attribute_hash
  end

  describe '.build' do
    it "builds a Foo" do
      Vend::Resource::Foo.build(client, :attrs => attribute_hash).should
        be_instance_of(Vend::Resource::Foo)
    end
  end

  describe '.initialize_singular' do

    it "initializes a singular resource from parsed JSON results" do
      resource = Vend::Resource::Foo.initialize_singular(client,mock_response)
      resource.should be_a Vend::Resource::Foo
      resource.bar.should == "baz"
    end

  end

  describe '.initialize_collection' do

    subject { Vend::Resource::Foo }

    let(:array)               { mock("array") }
    let(:endpoint)            { mock("endpoint") }
    let(:args)                { mock("args") }
    let(:resource_collection) { mock("resource_collection", :to_a => array) }

    before do
      Vend::ResourceCollection.should_receive(:new).with(
        client, subject, endpoint, args
      ) { resource_collection }
    end

    it "creates a ResourceCollection instance" do
      subject.initialize_collection(client, endpoint, args).should == array
    end

  end

  describe '.endpoint_name' do

    it "returns the endpoint name" do
      Vend::Resource::Foo.endpoint_name.should == 'foo'
    end

  end

  describe '.collection_name' do

    it "returns the collection name" do
      Vend::Resource::Foo.collection_name.should == 'foos'
    end

  end

  describe '.find' do

    it "finds a Foo by id" do
      mock_response = {"foos"=>[{"id"=>"1","bar"=>"baz"}]}
      client.should_receive(:request).with('foos', :id => "1") { mock_response }
      foo = Vend::Resource::Foo.find(client, "1")
      foo.should be_instance_of(Vend::Resource::Foo)
      foo.bar.should == "baz"
    end

  end

  describe '.all' do

    subject { Vend::Resource::Foo }

    let(:collection_name)     { mock("collection_name") }
    let(:resource_collection) { mock("resource_collection") }

    before do
      subject.stub(:collection_name => collection_name)
    end

    it "calls initialize_collection with the collection_name" do
      subject.should_receive(:initialize_collection).with(
        client, collection_name
      ) { resource_collection }
      subject.all(client).should == resource_collection
    end

  end

  describe '.since' do

    subject { Vend::Resource::Foo }

    let(:collection_name)     { mock("collection_name") }
    let(:resource_collection) { mock("resource_collection") }
    let(:since)               { mock("since") }

    before do
      subject.stub(:collection_name => collection_name)
    end

    it "calls initialize_collection with collection_name and :since arg" do
      subject.should_receive(:initialize_collection).with(
        client, collection_name, :since => since
      ) { resource_collection }
      subject.since(client, since).should == resource_collection
    end

  end

  describe '.outlet_id' do

    subject { Vend::Resource::Foo }

    let(:collection_name)     { mock("collection_name") }
    let(:resource_collection) { mock("resource_collection") }
    let(:outlet_id)           { mock("outlet_id") }

    before do
      subject.stub(:collection_name => collection_name)
    end

    it "calls initialize_collection with collection_name and :outlet_id arg" do
      subject.should_receive(:initialize_collection).with(
        client, collection_name, :outlet_id => outlet_id
      ) { resource_collection }
      subject.outlet_id(client, outlet_id).should == resource_collection
    end

  end

  describe ".search" do

    subject { Vend::Resource::Foo }

    let(:collection_name)     { mock("collection_name") }
    let(:resource_collection) { mock("resource_collection") }
    let(:field)               { "field" }
    let(:query)               { "query" }

    before do
      subject.stub(:collection_name => collection_name)
    end

    it "calls initialize_collection with collection_name and :outlet_id arg" do
      subject.should_receive(:initialize_collection).with(
        client, collection_name, :url_params => { field.to_sym => query }
      ) { resource_collection }
      subject.search(client, field, query).should == resource_collection
    end

  end

  describe ".build_from_json" do

    subject { Vend::Resource::Foo }

    let(:json)              { {"foos" => attributes_array} }
    let(:attributes_one)    { mock("attributes_one") }
    let(:attributes_two)    { mock("attributes_two") }
    let(:attributes_array)  { [attributes_one, attributes_two] }
    let(:instance_one)      { mock("instance_one") }
    let(:instance_two)      { mock("instance_two") }

    specify do
      subject.stub(:build).with(client, attributes_one) { instance_one }
      subject.stub(:build).with(client, attributes_two) { instance_two }
      subject.build_from_json(client, json).should == [
        instance_one, instance_two
      ]
    end

  end

  describe "dynamic instance methods" do
    let(:attrs) { { "one" => "foo", "two" => "bar", "object_id" => "fail" } }
    subject { Vend::Resource::Foo.new(client, :attrs => attrs) }

    it "responds to top level attributes" do
      subject.should respond_to(:one)
      subject.should respond_to(:two)
      subject.should respond_to(:object_id)

      subject.one.should == "foo"
      subject.two.should == "bar"
      subject.object_id.should_not == "fail"
      subject.attrs['object_id'].should == "fail"
    end
  end

  describe "delete!" do

    context "when id is present" do
      subject { Vend::Resource::Foo.new(client, :attrs => {'id' => 1}) }

      it "deletes the object" do
        client.should_receive(:request).with('foos', :method => :delete, :id => 1)
        subject.delete!
      end
    end

    context "when id is absent" do
      subject { Vend::Resource::Foo.new(client, :attrs => {:foo => 'bar'}) }

      it "raises Vend::Resource::IllegalAction" do
        client.should_not_receive(:request)
        expect {
          subject.delete!
        }.to raise_error(Vend::Resource::IllegalAction, "Vend::Resource::Foo has no unique ID")
      end
    end

  end

  describe 'delete' do

    it "returns false when no id is present" do
      objekt = Vend::Resource::Foo.new(client, :attrs => {:foo => 'bar'})
      client.should_not_receive(:request)
      objekt.delete.should be_false
    end

  end

  describe ".paginates?" do

    subject { Vend::Resource::Foo }

    it "defaults to false" do
      subject.paginates?.should be_false
    end

  end
end
