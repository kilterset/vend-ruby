module Vend
  module Oauth2

    class Client < Vend::Client

      DEFAULT_OPTIONS = {}

      include Logable

      attr_accessor :store, :auth_token

      def initialize(store, auth_token, options = {})
        @store = store
        @auth_token = auth_token
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def http_client
        @http_client ||= Vend::HttpClient.new(http_client_options)
      end

      def http_client_options
        options.merge(
            auth_token: @auth_token, base_url: base_url
        )
      end

    end

  end
end
