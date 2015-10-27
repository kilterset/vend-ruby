require 'forwardable'

module Vend #:nodoc:
  # Main access point which allows resources within the Vend gem to
  # make HTTP requests to the Vend API.
  #
  # Client must be initialized with:
  #   * a store url (e.g. the storeurl portion of http://storeurl.vendhq.com/),
  #   * a valid username and password
  #
  class Client
    DEFAULT_OPTIONS = {}

    extend Forwardable
    def_delegator :http_client, :request

    include Logable

    # The store url for this client
    attr_accessor :store, :username, :password
    attr_reader :options

    def initialize(store, username, password, options = {}) #:nodoc:
      @store = store
      @username = username
      @password = password
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def Product #:nodoc:
      Vend::BaseFactory.new(self, Resource::Product)
    end

    def Outlet #:nodoc:
      Vend::BaseFactory.new(self, Resource::Outlet)
    end

    def Customer #:nodoc:
      Vend::BaseFactory.new(self, Resource::Customer)
    end

    def PaymentType #:nodoc:
      Vend::BaseFactory.new(self, Resource::PaymentType)
    end

    def Register #:nodoc:
      Vend::BaseFactory.new(self, Resource::Register)
    end

    def RegisterSale #:nodoc:
      Vend::BaseFactory.new(self, Resource::RegisterSale)
    end

    def Tax #:nodoc:
      Vend::BaseFactory.new(self, Resource::Tax)
    end

    def User #:nodoc:
      Vend::BaseFactory.new(self, Resource::User)
    end

    # Returns the base API url for the client.
    # E.g. for the store 'foo', it returns https://foo.vendhq.com/api/
    def base_url
      "https://#{@store}.vendhq.com/api/"
    end

    def http_client
      @http_client ||= HttpClient.new(http_client_options)
    end

    def http_client_options
      options.merge(
        :base_url => base_url, :username => username, :password => password
      )
    end
  end
end
