module Vend
  module Logable
    attr_accessor :logger

    def logger
      @logger ||= NullLogger.new
    end
  end
end
