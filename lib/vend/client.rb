require 'net/http'

module Vend

  # Main access point for all resources within the Vend API
  #
  # Client must be initialized with:
  #   * a store url (e.g. the storeurl portion of http://storeurl.vendhq.com/),
  #   * a valid username and password
  #
  class Client

    # The store url for this client
    attr_accessor :store

    def initialize(store, username, password)
      @store = store;
      @username = username;
      @password = password;
    end

    # Makes a request to the specified path within the Vend API
    # E.g. request('foo') will make a request
    def request(path, method = 'get')
      url = URI.parse(base_url + path)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      method = ("Net::HTTP::" + method.to_s.classify).constantize

      request = method.new(url.path)
      request.basic_auth @username, @password

      http.request(request)
    end

    # Returns the base API url for the client.
    # E.g. for the store 'foo', it returns https://foo.vendhq.com/api/
    def base_url
      "https://#{@store}.vendhq.com/api/"
    end

  end
end
