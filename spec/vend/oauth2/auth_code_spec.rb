require 'spec_helper'

describe Vend::Oauth2::AuthCode do

  subject { described_class.new('store', 'client_id', 'secret', 'redirect_uri') }

  its(:store) { is_expected.to eq('store') }
  its(:client_id) { is_expected.to eq('client_id') }
  its(:secret) { is_expected.to eq('secret') }
  its(:redirect_uri) { is_expected.to eq('redirect_uri') }

  it "creates an instance of Client" do
    expect(subject).to be_a Vend::Oauth2::AuthCode
  end

  describe "#authorize_url" do
    it "return url" do
      expect(subject.authorize_url).to eq('https://secure.vendhq.com/connect?client_id=client_id&redirect_uri=redirect_uri&response_type=code')
    end
  end


  describe "#get_token" do
    let(:store) {"store"}
    let(:token_type) { "Bearer" }
    let(:access_token) { "Uy4eObSRn1RwzQbAitDMEkY6thdHsDJjwdGehpgr"}
    let(:refresh_token) {"nbCoejmJp1XZgs7as6FeQQ5QZLlUfefzaBjrxvtV"}

    before do
      stub_request(:post, "https://store.vendhq.com/api/1.0/token").
          to_return(:status => 200, :body => {token_type: token_type,
	                expires: 2435942384,
                  domain_prefix: store,
                  access_token: access_token,
                  refresh_token: refresh_token,
                  expires_at: 2435942383}.to_json, :headers=>{ 'Content-Type' => 'application/json' })
    end

    it "return access token" do
      token = subject.get_token('code')
      expect(token).to be_a OAuth2::AccessToken
      expect(token.token).to eq(access_token)
      expect(token.refresh_token).to eq(refresh_token)
    end
  end

end
