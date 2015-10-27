require 'spec_helper'

describe Vend::Oauth2::Client do

  subject { described_class.new('store', 'auth_token') }

  it_behaves_like "it has a logger"

  its(:store) { is_expected.to eq('store') }
  its(:auth_token) { is_expected.to eq('auth_token') }

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
    let(:options)   { {:foo => 'bar'} }
    let(:base_url)  { "http://foo/" }
    let(:auth_token)  { "auth_token" }

    before do
      subject.stub(
        :options => options,
        :base_url => base_url,
        :auth_token => auth_token
      )
    end

    it :http_client_options do
      expect(subject.http_client_options).to eq({
        :foo => 'bar',
        :base_url => base_url,
        :auth_token => auth_token
      })
    end
  end
end
