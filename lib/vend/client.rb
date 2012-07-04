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

    DEFAULT_OPTIONS = {
      :ssl_verify_mode => OpenSSL::SSL::VERIFY_PEER
    }

    # The store url for this client
    attr_accessor :store, :logger
    attr_reader :options

    def initialize(store, username, password, options = {}) #:nodoc:
      @store = store
      @username = username
      @password = password
      @options = DEFAULT_OPTIONS.merge(options)
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
      elsif options[:outlet_id]
        path += "/outlet_id/#{CGI::escape(options[:outlet_id])}"
      elsif options[:since]
        path += "/since/#{CGI::escape(options[:since].strftime(DATETIME_FORMAT))}"
      end
      url = URI.parse(base_url + path)
      http = get_http_connection(url.host, url.port)

      method = ("Net::HTTP::" + options[:method].to_s.classify).constantize
      request = method.new(url.path + url_params_for(options[:url_params]))
      request.basic_auth @username, @password

      request.body = options[:body] if options[:body]
      logger.debug url
      response = http.request(request)
      raise Unauthorized.new(UNAUTHORIZED_MESSAGE) if response.kind_of?(Net::HTTPUnauthorized)
      raise HTTPError.new(response) unless response.kind_of?(Net::HTTPSuccess)
      logger.debug response
      response
    end

    # sets up a http connection
    def get_http_connection(host, port)
      http = Net::HTTP.new(host, port)
      http.use_ssl = true
      http.verify_mode = @options[:ssl_verify_mode]
      http
    end

    # Returns the base API url for the client.
    # E.g. for the store 'foo', it returns https://foo.vendhq.com/api/
    def base_url
      "https://#{@store}.vendhq.com/api/"
    end

    def logger
      @logger ||= NullLogger.new
    end

  protected

    # Internal method to parse URL parameters.
    # Returns an empty string from a nil argument
    #
    # E.g. url_params_for({:field => "value"}) will return ?field=value
    # url_params_for({:field => ["value1","value2"]}) will return ?field[]=value1&field[]=value2
    def url_params_for(options)
      ary = Array.new
      if !options.nil?
        options.each do |option,value|
          if value.class == Array
            ary << value.collect { |key| "#{option}%5B%5D=#{CGI::escape(key.to_s)}" }.join('&')
          else
            ary << "#{option}=#{CGI::escape(value.to_s)}"
          end
        end
        '?'.concat(ary.join('&'))
      else
        ''
      end
    end

  end

end
