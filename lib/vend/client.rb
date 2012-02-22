require 'net/http'
require 'json'
require 'cgi'

module Vend #:nodoc:

  # Main access point which allows resources within the Vend gem to
  # make HTTP requests to the Vend API.
  #
  # Client must be initialized with:
  #   * a store url (e.g. the storeurl portion of http://storeurl.vendhq.com/),
  #   * a valid username and password
  #
  class Client

    UNAUTHORIZED_MESSAGE = "Client not authorized. Check your store URL and credentials are correct and try again."

    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    # The store url for this client
    attr_accessor :store

    def initialize(store, username, password) #:nodoc:
      @store = store;
      @username = username;
      @password = password;
    end

    def Product #:nodoc:
      Vend::Resource::ProductFactory.new(self)
    end

    def Outlet #:nodoc:
      Vend::Resource::OutletFactory.new(self)
    end

    def Customer #:nodoc:
      Vend::Resource::CustomerFactory.new(self)
    end

    def PaymentType #:nodoc:
      Vend::Resource::PaymentTypeFactory.new(self)
    end

    def Register #:nodoc:
      Vend::Resource::RegisterFactory.new(self)
    end

    def RegisterSale #:nodoc:
      Vend::Resource::RegisterSaleFactory.new(self)
    end

    def Tax #:nodoc:
      Vend::Resource::TaxFactory.new(self)
    end

    def User #:nodoc:
      Vend::Resource::UserFactory.new(self)
    end

    # Makes a request to the specified path within the Vend API
    # E.g. request('foo') will make a GET request to
    #      http://storeurl.vendhq.com/api/foo
    #
    # The HTTP method may be specified, by default it is GET.
    #
    # An optional hash of arguments may be specified. Possible options include:
    #   :method - The HTTP method
    #     E.g. request('foo', :method => :post) will perform a POST request for
    #          http://storeurl.vendhq.com/api/foo
    #
    #   :url_params - The URL parameters for GET requests.
    #     E.g. request('foo', :url_params => {:bar => "baz"}) will request
    #          http://storeurl.vendhq.com/api/foo?bar=baz
    #
    #   :id - The ID required for performing actions on specific resources
    #         (e.g. delete).
    #     E.g. request('foos', :method => :delete, :id => 1) will request
    #          DELETE http://storeurl.vendhq.com/api/foos/1
    #
    #   :body - The request body
    #     E.g. For submitting a POST to http://storeurl.vendhq.com/api/foo
    #          with the JSON data {"baz":"baloo"} we would call
    #          request('foo', :method => :post, :body => '{\"baz\":\"baloo\"}'
    #
    def request(path, options = {})
      options = {:method => :get}.merge options
      if options[:id]
        path += "/#{options[:id]}"
      elsif options[:since]
        path += "/since/#{CGI::escape(options[:since].strftime(DATETIME_FORMAT))}"
      end
      url = URI.parse(base_url + path)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      method = ("Net::HTTP::" + options[:method].to_s.classify).constantize
      request = method.new(url.path + url_params_for(options[:url_params]))
      request.basic_auth @username, @password

      request.body = options[:body] if options[:body]
      response = http.request(request)
      raise Unauthorized.new(UNAUTHORIZED_MESSAGE) if response.kind_of?(Net::HTTPUnauthorized)
      raise HTTPError.new(response) unless response.kind_of?(Net::HTTPSuccess)
      response
    end

    # Returns the base API url for the client.
    # E.g. for the store 'foo', it returns https://foo.vendhq.com/api/
    def base_url
      "https://#{@store}.vendhq.com/api/"
    end

  protected

    # Internal method to parse URL parameters.
    # Returns an empty string from a nil argument
    #
    # E.g. url_params_for({:field => "value"}) will return ?field=value
    def url_params_for(options)
      return "?".concat(options.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')) if not options.nil?
      return ''
    end

  end
end
