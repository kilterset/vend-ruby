require 'spec_helper'

describe Vend::HttpClient do

  let(:base_url)  { "https://foo/bar/" }
  let(:username)  { "username" }
  let(:password)  { "password" }
  let(:options)   {
    {:base_url => base_url, :username => username, :password => password}
  }

  subject {
    described_class.new(options)
  }

  it_should_behave_like "it has a logger"

  its(:base_url) { should == base_url }
  its(:username) { should == username }
  its(:password) { should == password }

  describe "#verify_ssl?" do
    its(:verify_ssl) { should be_true }

    context "when overridden in the options" do
      subject { described_class.new(options.merge(:verify_ssl => false)) }
    end
  end

  describe "#get_http_connection" do
    let(:http)        { mock("http") }
    let(:verify_mode) { mock("verify_mode") }
    let(:host)        { "foo" }
    let(:port)        { 42 }

    before do
      subject.stub(:verify_mode => verify_mode)
      http.should_receive(:use_ssl=).with(true)
      http.should_receive(:verify_mode=).with(verify_mode)
      Net::HTTP.stub(:new).with(host, port) { http }
    end

    it "returns the http_connection" do
      subject.get_http_connection(host, port).should == http
    end
  end

  describe "#verify_mode" do

    context "when verify_ssl? is true" do
      before do
        subject.stub(:verify_ssl? => true)
      end
      its(:verify_mode) { should == OpenSSL::SSL::VERIFY_PEER }
    end

    context "when verify_ssl? is false" do
      before do
        subject.stub(:verify_ssl? => false)
      end
      its(:verify_mode) { should == OpenSSL::SSL::VERIFY_NONE }
    end

  end

  describe "#request" do

    context "when using invalid credentials" do

      let(:username)  { "invalid" }

      it "raises an error" do
        stub_request(:get, "https://invalid:password@foo/bar/products").
          to_return(:status => 401)

        expect {
          subject.request('products')
        }.to raise_error(Vend::Unauthorized)
      end

    end

    it "throws an error when an invalid request is made" do
      stub_request(:get, "https://username:password@foo/bar/invalid").
        to_return(:status => 404, :body => '{"foo":"bar"}', :headers => {})

      expect {
        subject.request('invalid')
      }.to raise_error(Vend::HTTPError)
    end

    it "returns parsed JSON" do
      stub_request(:get, "https://username:password@foo/bar/bun").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})
      subject.request("bun").should == {"foo" => "bar"}
    end

    it "returns nil if the response was empty" do
      stub_request(:get, "https://username:password@foo/bar/bun").
        to_return(:status => 200, :body => '', :headers => {})
      subject.request("bun").should be_nil
    end
    it "allows us to specify HTTP method" do
      stub_request(:post, "https://username:password@foo/bar/foo").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo', :method => :post)
      response.should == {"foo" => "bar"}
    end

    it "allows us to set a request body" do
      stub_request(:post, "https://username:password@foo/bar/foo").
        with(:body => "{\"post\":\"data\"}").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo', :method => :post, :body => '{"post":"data"}')
      response.should == {"foo" => "bar"}
    end

    it "allows us to specify url parameters" do
      stub_request(:get, "https://username:password@foo/bar/foo?foo=bar&baz=baloo&flum%5B0%5D=blob&flum%5B1%5D=splat").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo', :url_params => {:foo => "bar", :baz => "baloo", :flum => ["blob","splat"]})
      response.should == {"foo" => "bar"}
    end

  end
end
