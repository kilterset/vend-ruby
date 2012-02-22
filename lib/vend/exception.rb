require 'forwardable'

module Vend
  module Resource
    # Raised when the action being performed is not possible or applicable to
    # the resource under the current conditions
    class IllegalAction < StandardError; end

    # Raised when the response from the API is not able to be interpreted
    # in a useful way by the Gem (E.g. Parsing errors for non-JSON responses)
    class InvalidResponse < StandardError; end
  end

  # Raised when the specified endpoint does not exist in the API. (Indicated
  # by the response being a redirect to the signin page)
  class InvalidRequest < StandardError; end

  # This exception is thrown when a 401 Unauthorized response is received
  # from the Vend API
  class Unauthorized < StandardError; end

  # Nonspecific HTTP error which is usually thrown when a non 2xx response
  # is received.
  class HTTPError < StandardError
    extend Forwardable

    delegate [:message, :code] => :response

    attr_reader :response

    def initialize(response)
      @response = response
    end
  end
end
