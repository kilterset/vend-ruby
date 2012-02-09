require 'spec_helper'

describe Vend::Client do

  subject { Vend::Client.new('intergalactic','trish','sand') }

  it "creates an instance of Client" do
    subject.should be_instance_of(Vend::Client)
  end

  it "sets the store" do
    subject.store.should == 'intergalactic'
  end

  it "returns the API base url" do
    subject.base_url.should == "https://intergalactic.vendhq.com/api/"
  end

  describe "makes arbitrary requests to the API" do

    it "allows us to specify HTTP method" do
      stub_request(:post, "https://trish:sand@intergalactic.vendhq.com/api/foo").
        to_return(:status => 200, :body => "", :headers => {})

      response = subject.request('foo', :method => :post)
      response.should be_instance_of(Net::HTTPOK)
    end

    it "allows us to set a request body" do
      stub_request(:post, "https://trish:sand@intergalactic.vendhq.com/api/foo").
        with(:body => "{\"post\":\"data\"}").
        to_return(:status => 200, :body => "", :headers => {})

      response = subject.request('foo', :method => :post, :body => '{"post":"data"}')
      response.should be_instance_of(Net::HTTPOK)
    end

    it "allows us to specify url parameters" do
      stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/foo?foo=bar&baz=baloo").
        to_return(:status => 200, :body => "", :headers => {})

      response = subject.request('foo', :url_params => {:foo => "bar", :baz => "baloo"})
      response.should be_instance_of(Net::HTTPOK)
    end

  end
end
