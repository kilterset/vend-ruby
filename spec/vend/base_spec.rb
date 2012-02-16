require 'spec_helper'

describe Vend::Base do
  class Vend::Resource::Foo < Vend::Base #:nodoc
  end

  let(:client) { mock(:client) }
  let(:attribute_hash) { {:key => "value"} }

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

  it "parses JSON" do
    described_class.parse_json('{"baz":"baloo"}').should == {"baz" => "baloo"}
  end

  it "initializes a collection from JSON results" do
    collection = Vend::Resource::Foo.initialize_collection(client, '{"foos":[{"id":1,"foo":"bar"}]}')
    a_foo = collection.first
    a_foo.should be_a Vend::Resource::Foo
    a_foo.foo.should == "bar"
  end

  it "returns the endpoint name" do
    Vend::Resource::Foo.endpoint_name.should == 'foo'
  end

  it "returns the collection name" do
    Vend::Resource::Foo.collection_name.should == 'foos'
  end

  it "returns all Foo objects" do
    mock_response = '
      {
        "foos":[
            {"id":"1","bar":"baz"}
        ]
      }'
    response = mock
    response.should_receive(:body).and_return(mock_response);
    client.should_receive(:request).with('foos').and_return(response)
    foos = Vend::Resource::Foo.all(client)
    foos.length.should == 1
    foos.first.should be_instance_of(Vend::Resource::Foo)
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

  describe "searching" do

    it "returns an array of Foo objects" do
      mock_response = '{
          "foos":[
            {"id":"1","bar":"baz"},
            {"id":"2","bar":"baz"},
            {"id":"3","bar":"baz"}
          ]
        }'
      response = mock
      response.should_receive(:body).and_return(mock_response)
      client.should_receive(:request).with('foos', :url_params => {:bar => 'baz'}).
        and_return(response)
      foos = Vend::Resource::Foo.search(client, 'bar', 'baz')
      foos.first.should be_a Vend::Resource::Foo
    end
  end
end
