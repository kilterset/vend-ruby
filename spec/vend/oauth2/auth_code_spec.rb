require 'spec_helper'

describe Vend::Oauth2::AuthCode do

  subject { described_class.new('store', 'client_id', 'secret', 'redirect_uri') }

  describe "#initialize" do
    it "sets up the attr_readers" do
      expect(subject.store).to        eq 'store'
      expect(subject.client_id).to    eq 'client_id'
      expect(subject.secret).to       eq 'secret'
      expect(subject.redirect_uri).to eq 'redirect_uri'
    end
  end

  it "creates an instance of Client" do
    expect(subject).to be_a Vend::Oauth2::AuthCode
  end

  describe "#authorize_url" do
    it "return url" do
      expect(subject.authorize_url).to eq('https://secure.vendhq.com/connect?client_id=client_id&redirect_uri=redirect_uri&response_type=code')
    end
  end


  describe "#token_from_code" do
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
      token = subject.token_from_code('code')
      expect(token).to be_a OAuth2::AccessToken
      expect(token.token).to eq(access_token)
      expect(token.refresh_token).to eq(refresh_token)
    end
  end

end
