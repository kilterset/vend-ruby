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

  it_behaves_like "it has a logger"

  specify :base_url do
    expect(subject.base_url).to eq base_url
  end

  specify :username do
    expect(subject.username).to eq username
  end

  specify :password do
    expect(subject.password).to eq password
  end

  describe "#verify_ssl?" do
    specify :verify_ssl do
      expect(subject.verify_ssl).to be_truthy
    end

    context "when overridden in the options" do
      subject { described_class.new(options.merge(verify_ssl: false)) }
    end
  end

  describe "#get_http_connection" do
    let(:http)        { double("http") }
    let(:verify_mode) { double("verify_mode") }
    let(:host)        { "foo" }
    let(:port)        { 42 }

    before do
      subject.stub(:verify_mode => verify_mode)
      expect(http).to receive(:use_ssl=).with(true)
      expect(http).to receive(:verify_mode=).with(verify_mode)
      expect(http).to receive(:read_timeout=).with(240)
      Net::HTTP.stub(:new).with(host, port) { http }
    end

    it "returns the http_connection" do
      expect(subject.get_http_connection(host, port)).to eq http
    end
  end

  describe "#verify_mode" do

    context "when verify_ssl? is true" do
      before do
        subject.stub(:verify_ssl? => true)
      end
      specify :verify_mode do
        expect(subject.verify_mode).to eq OpenSSL::SSL::VERIFY_PEER
      end
    end

    context "when verify_ssl? is false" do
      before do
        subject.stub(:verify_ssl? => false)
      end
      specify :verify_mode do
        expect(subject.verify_mode).to eq OpenSSL::SSL::VERIFY_NONE
      end
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
      expect(subject.request("bun")).to eq({"foo" => "bar"})
    end

    it "returns nil if the response was empty" do
      stub_request(:get, "https://username:password@foo/bar/bun").
        to_return(:status => 200, :body => '', :headers => {})
      expect(subject.request("bun")).to be_nil
    end
    it "allows us to specify HTTP method" do
      stub_request(:post, "https://username:password@foo/bar/foo").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo', :method => :post)
      expect(response).to eq({"foo" => "bar"})
    end

    it "allows us to set a request body" do
      stub_request(:post, "https://username:password@foo/bar/foo").
        with(:body => "{\"post\":\"data\"}").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo', :method => :post, :body => '{"post":"data"}')
      expect(response).to eq({"foo" => "bar"})
    end

    it "allows us to specify url parameters" do
      stub_request(:get, "https://username:password@foo/bar/foo?foo=bar&baz=baloo&flum%5B0%5D=blob&flum%5B1%5D=splat").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo', :url_params => {:foo => "bar", :baz => "baloo", :flum => ["blob","splat"]})
      expect(response).to eq({"foo" => "bar"})
    end

    it "follows redirects" do
      stub_request(:get, "https://username:password@foo/bar/foo").
        to_return(:status => 302, :body => '{"bar":"baz"}', :headers => {"Location" => "http://username:password@foo/bar/floo"})

      stub_request(:get, "http://username:password@foo/bar/floo").
        to_return(:status => 200, :body => '{"foo":"bar"}', :headers => {})

      response = subject.request('foo')
      expect(response).to eq({"foo" => "bar"})
    end

    it "raises an exception when the redirection limit is exceeded" do
      stub_request(:get, "https://username:password@foo/bar/foo").
        to_return(:status => 302, :body => '{"bar":"baz"}', :headers => {"Location" => "https://username:password@foo/bar/foo"})
      expect {
        subject.request('foo')
      }.to raise_exception(Vend::RedirectionLimitExceeded)
    end
  end
end
