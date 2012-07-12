require 'spec_helper'

describe Vend::Base do
  class Vend::Resource::Foo < Vend::Base #:nodoc
    url_scope :bar
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

    let(:endpoint)            { mock("endpoint") }
    let(:args)                { mock("args") }
    let(:resource_collection) { mock("resource_collection") }

    before do
      Vend::ResourceCollection.should_receive(:new).with(
        client, subject, endpoint, args
      ) { resource_collection }
    end

    it "creates a ResourceCollection instance" do
      subject.initialize_collection(
        client, endpoint, args
      ).should == resource_collection
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

  describe '.singular_name' do

    it "returns the collection name plus the id" do
      Vend::Resource::Foo.singular_name("1").should == 'foos/1'
      Vend::Resource::Foo.singular_name(42).should == 'foos/42'
    end

  end

  describe "#singular_name" do

    let(:singular_name) { mock("singular_name")}
    let(:id)            { 42 }

    before do
      subject.stub(:id => id)
      described_class.stub(:singular_name).with(id) { singular_name }
    end

    its(:singular_name) { should == singular_name }

  end

  describe '.find' do

    let(:id) { 1 }
    let(:singular_name) { "foos/1" }

    before do
      Vend::Resource::Foo.stub(:singular_name).with(id) { singular_name }
    end

    it "finds a Foo by id" do
      mock_response = {"foos"=>[{"id"=>"1","bar"=>"baz"}]}
      client.should_receive(:request).with(singular_name) { mock_response }
      foo = Vend::Resource::Foo.find(client, id)
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

  describe '.url_scope' do

    subject { Vend::Resource::Foo }

    let(:collection_name)     { mock("collection_name") }
    let(:resource_collection) { mock("resource_collection") }
    let(:bar)                 { mock("bar") }

    before do
      subject.stub(:collection_name => collection_name)
    end

    it "calls initialize_collection with collection_name and :bar arg" do
      subject.should_receive(:initialize_collection).with(
        client, collection_name
      ) { resource_collection }
      resource_collection.should_receive(:scope).with(:bar, bar) {
        resource_collection
      }
      subject.bar(client, bar).should == resource_collection
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

      let(:singular_name) { mock("singular_name")}

      before do
        subject.stub(:singular_name => singular_name)
      end

      it "deletes the object" do
        client.should_receive(:request).with(singular_name, :method => :delete)
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

  describe ".available_scopes" do
    subject { Vend::Resource::Foo }
    its(:available_scopes)  { should == [:bar] }
  end

  describe ".accepts_scope?" do
    let(:scope_name) {:scope_name}
    subject { Vend::Resource::Foo }
    
    context "when scope is accepted" do
      before do
        subject.stub(:available_scopes => [scope_name])
      end
      specify do
        subject.accepts_scope?(scope_name).should be_true
      end
    end

    context "when scope is not accepted" do
      before do
        subject.stub(:available_scopes => [])
      end
      specify do
        subject.accepts_scope?(scope_name).should be_false
      end
    end
  end

  describe ".findable_by" do
    subject { Vend::Resource::Foo }

    let(:args)  { mock("args") }

    it "creates a find_by_foo method on the class" do
      subject.should_not respond_to(:find_by_foo)
      subject.findable_by(:foo)
      subject.should respond_to(:find_by_foo)
    end

    it "proxies to search" do
      subject.findable_by(:foo)
      subject.should_receive(:search).with(client, :foo, args)
      subject.find_by_foo(client, args)
    end

    it "allows a different method name" do
      subject.findable_by(:foo, :as => :bar)
      subject.should_receive(:search).with(client, :bar, args)
      subject.find_by_foo(client, args)
    end

  end
end
