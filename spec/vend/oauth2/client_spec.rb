require 'spec_helper'

describe Vend::Oauth2::Client do

  subject { described_class.new('store', 'auth_token') }

  it_behaves_like "it has a logger"

  describe "#initialize" do
    it "sets up the attr_readers" do
      expect(subject.store).to      eq('store')
      expect(subject.auth_token).to eq('auth_token')
    end
  end

  it "creates an instance of Client" do
    expect(subject).to be_a Vend::Oauth2::Client
  end

  describe "resource factories" do
    it "gets all products" do
      expect(Vend::Resource::Product).to receive(:all).and_return([])
      expect(subject.Product.all).to eq []
    end
  end

  describe "#http_client_options" do
    let(:options)   { {foo: 'bar'} }
    let(:base_url)  { "http://foo/" }
    let(:auth_token)  { "auth_token" }

    before do
      subject.stub(
        options: options,
        base_url: base_url,
        auth_token: auth_token
      )
    end

    specify :http_client_options do
      expect(subject.http_client_options).to eq({
        foo: 'bar',
        base_url: base_url,
        auth_token: auth_token
      })
    end
  end
end
