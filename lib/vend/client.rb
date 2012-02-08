require 'net/http'

module Vend

  # Main access point for all resources within the Vend API
  #
  # Client must be initialized with:
  #   * a store url (e.g. the storeurl portion of http://storeurl.vendhq.com/),
  #   * a valid username and password
  #
  class Client

    # The store url and username for this client
    attr_accessor :store

    def initialize(store, username, password)
      @store = store;
      @username = username;
      @password = password;
    end

    def request(path)
      url = URI.parse(base_url + path)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url.path)
      request.basic_auth @username, @password

      http.request(request)
    end

    def base_url
      "https://#{@store}.vendhq.com/api/"
    end

  end
end
