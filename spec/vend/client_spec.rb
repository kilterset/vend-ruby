require 'spec_helper'

describe Vend::Client do
  subject { Vend::Client.new('store', 'user', 'password') }
  it_behaves_like "it has a logger"

  specify :store do
    expect(subject.store).to eq 'store'
  end

  specify :username do
    expect(subject.username).to eq 'user'
  end

  specify :password do
    expect(subject.password).to eq 'password'
  end

  it "creates an instance of Client" do
    expect(subject).to be_instance_of(Vend::Client)
  end

  it "returns the API base url" do
    expect(subject.base_url).to eq "https://store.vendhq.com/api/"
  end

  it "sets options" do
    options = { key: :value }
    client = Vend::Client.new('store', 'user', 'password', options)
    options.each do |key, value|
      expect(client.options[key]).to eq value
    end
  end

  describe "resource factories" do
    it "gets all products" do
      expect(Vend::Resource::Product).to receive(:all).and_return([])
      expect(subject.Product.all).to eq []
    end
  end

  describe "#http_client" do
    let(:http_client)         { double("http_client") }
    let(:http_client_options) { double("http_client_options") }

    before do
      subject.stub(http_client_options: http_client_options)
      expect(Vend::HttpClient).to receive(:new).with(http_client_options) { http_client }
    end

    it "returns a memoized HttpClient instance" do
      expect(subject.http_client).to eq http_client
      expect(subject.http_client).to eq http_client
    end
  end

  describe "#http_client_options" do
    let(:options)   { {foo: 'bar'} }
    let(:base_url)  { "http://foo/" }
    let(:username)  { "username" }
    let(:password)  { "password" }

    before do
      subject.stub(
        options: options,
        base_url: base_url,
        username: username,
        password: password
      )
    end
    specify :http_client_options do
      expect(subject.http_client_options).to eq({
        foo: 'bar',
        base_url: base_url,
        username: username,
        password: password
      })
    end
  end

  describe "#request" do
    let(:response)    { double("response") }
    let(:http_client) { double("http_client") }

    before do
      subject.stub(http_client: http_client)
      expect(http_client).to receive(:request).with("foo", "bar") { response }
    end

    it "delegates to the http_client" do
      expect(subject.request("foo", "bar")).to eq response
    end
  end
end
