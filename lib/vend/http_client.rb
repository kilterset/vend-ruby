require 'net/http'
require 'json'
require 'cgi'
module Vend
  class HttpClient

    UNAUTHORIZED_MESSAGE = "Client not authorized. Check your store URL and credentials are correct and try again."

    include Logable

    attr_accessor :base_url, :verify_ssl, :username, :password
    alias :verify_ssl? :verify_ssl

    def initialize(options = {})
      @base_url = options[:base_url]
      @username = options[:username]
      @password = options[:password]
      @verify_ssl = if options.has_key?(:verify_ssl)
                      options[:verify_ssl]
                    else
                      true
                    end
    end

    # sets up a http connection
    def get_http_connection(host, port)
      http = Net::HTTP.new(host, port)
      http.use_ssl = true
      http.verify_mode = verify_mode
      http
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
      url = URI.parse(base_url + path) 
      http = get_http_connection(url.host, url.port)

      # FIXME extract method
      method = ("Net::HTTP::" + options[:method].to_s.classify).constantize
      request = method.new(url.path + url_params_for(options[:url_params]))
      request.basic_auth username, password

      request.body = options[:body] if options[:body]
      logger.debug url
      response = http.request(request)
      raise Unauthorized.new(UNAUTHORIZED_MESSAGE) if response.kind_of?(Net::HTTPUnauthorized)
      raise HTTPError.new(response) unless response.kind_of?(Net::HTTPSuccess)
      logger.debug response
      JSON.parse response.body unless response.body.empty?
    end

    # Returns the SSL verification mode, based upon the value of verify_ssl?
    def verify_mode
      if verify_ssl?
        OpenSSL::SSL::VERIFY_PEER
      else
        OpenSSL::SSL::VERIFY_NONE
      end
    end

    # Internal method to parse URL parameters.
    # Returns an empty string from a nil argument
    #
    # E.g. url_params_for({:field => "value"}) will return ?field=value
    # url_params_for({:field => ["value1","value2"]}) will return ?field[]=value1&field[]=value2
    protected
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

    protected
    # Modifies path with the provided options
    def expand_path_with_options(path, options)
      # FIXME - Remove from here
      if options[:id]
        path += "/#{options[:id]}"
      end
      return path
    end

  end
end
