module Vend
  class NullLogger
    def debug(*_args); end

    def info(*_args); end

    def warn(*_args); end

    def error(*_args); end

    def fatal(*_args); end
  end
end
