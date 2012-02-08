module Vend
  class Client

    attr_accessor :domain, :username
    def initialize(domain, username, password)
      @domain = domain;
      @username = username;
      @password = password;
    end

  end
end
