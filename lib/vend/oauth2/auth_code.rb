require 'oauth2'

module Vend
  module Oauth2

    class AuthCode

      DEFAULT_OPTIONS = {}
      AUTHORIZE_URL = '/connect'
      TOKEN_URL = '/api/1.0/token'

      attr_accessor :store, :client_id, :secret, :redirect_uri

      def initialize(store, client_id, secret, redirect_uri, options = {})
        @store = store
        @client_id = client_id
        @secret = secret
        @redirect_uri = redirect_uri
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def authorize_url
        get_oauth2_client.auth_code.authorize_url(redirect_uri: redirect_uri)
      end

      def token_from_code(code)
        client = get_oauth2_client(store)
        client.auth_code.get_token(code, redirect_uri: redirect_uri)
      end

      def refresh_token(auth_token, refresh_token)
        access_token = OAuth2::AccessToken.new(get_oauth2_client(store), auth_token, {refresh_token: refresh_token})
        access_token.refresh!
      end

      protected
      def get_oauth2_client(domain_prefix = 'secure')
        OAuth2::Client.new(client_id, secret, {
            site: "https://#{domain_prefix}.vendhq.com",
            authorize_url: AUTHORIZE_URL,
            token_url: TOKEN_URL
        })
      end

    end

  end
end
