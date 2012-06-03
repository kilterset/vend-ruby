require 'spec_helper'

describe Vend::Client do

  subject { Vend::Client.new('store','user','password') }

  it "creates an instance of Client" do
    subject.should be_instance_of(Vend::Client)
  end

  it "sets the store" do
    subject.store.should == 'store'
  end

  it "returns the API base url" do
    subject.base_url.should == "https://store.vendhq.com/api/"
  end

  it "raises an error when using invalid credentials" do
    stub_request(:get, "https://invalid:user@intergalactic.vendhq.com/api/products").
      to_return(:status => 401)
    invalid_client = Vend::Client.new('intergalactic', 'invalid', 'user')

    expect {
      invalid_client.request('products')
    }.to raise_error(Vend::Unauthorized)
  end

  describe "when using valid credentials" do

    subject { Vend::Client.new('intergalactic','trish','sand') }

    describe "arbitrary requests to the API" do

      it "throws an error when an invalid request is made" do
        stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/invalid").
          to_return(:status => 404, :body => '', :headers => {})

        expect {
          subject.request('invalid')
        }.to raise_error(Vend::HTTPError)
      end

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
        stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/foo?foo=bar&baz=baloo&flum%5B0%5D=blob&flum%5B1%5D=splat").
          to_return(:status => 200, :body => "", :headers => {})

        response = subject.request('foo', :url_params => {:foo => "bar", :baz => "baloo", :flum => ["blob","splat"]})
        response.should be_instance_of(Net::HTTPOK)
      end

      it "allows us to specify an id" do
        stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/foos/1").
          to_return(:status => 200, :body => "", :headers => {})

        response = subject.request('foos', :id => 1)
        response.should be_instance_of(Net::HTTPOK)
      end

      it "allows us to specify a since parameter" do
        time = Time.new(2012,5,8)
        stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/foos/since/#{CGI.escape(time.strftime(Vend::Client::DATETIME_FORMAT))}").
          to_return(:status => 200, :body => "", :headers => {})

        response = subject.request('foos', :since => time)
        response.should be_instance_of(Net::HTTPOK)
      end

      it "allows us to specify an outlet_id parameter" do
        stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/foos/outlet_id/outlet_guid_goes_here").
          to_return(:status => 200, :body => "", :headers => {})

        response = subject.request('foos', :outlet_id => 'outlet_guid_goes_here')
        response.should be_instance_of(Net::HTTPOK)
      end

    end
  end

  describe "resource factories" do
    it "gets all products" do
      Vend::Resource::Product.should_receive(:all).and_return([])
      subject.Product.all.should == []
    end
  end
end
