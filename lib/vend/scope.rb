module Vend
  class Scope
    attr_reader :name
    attr_accessor :value

    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    def initialize(name, value)
      @name = name
      @value = value
    end

    def escaped_value
      if value.instance_of? Time
        result = value.strftime(DATETIME_FORMAT)
      else
        result = value.to_s
      end
      CGI::escape(result)
    end

    def to_s
      "/%s/%s" % [name, escaped_value]
    end
  end
end
