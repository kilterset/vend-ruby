module Vend
  class NullLogger
    def debug(*args) ; end
    def info(*args) ; end
    def warn(*args) ; end
    def error(*args) ; end
    def fatal(*args) ; end
  end
end
