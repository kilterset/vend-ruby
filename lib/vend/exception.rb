module Vend
  module Resource
    class IllegalAction < StandardError; end
    class InvalidRequest < StandardError; end
    class InvalidResponse < StandardError; end
  end

  class HTTPError < StandardError
    extend Forwardable

    delegate [:message, :code] => :response

    attr_reader :response

    def initialize(response)
      @response = response
    end
  end
end
