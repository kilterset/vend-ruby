module Vend
  class BaseFactory
    attr_reader :client, :target_class

    def initialize(client, target_class)
      @target_class = target_class
      @client = client
    end

    # The main point of this factory class is to proxy methods to the target
    # class and prepend client to the argument list.
    def method_missing(method_name, *args, &block)
      args.unshift(client)
      target_class.send(method_name, *args, &block)
    end

    def respond_to?(method_name)
      return true if target_class.respond_to?(method_name)
      super(method_name)
    end

    ## Generates find_by_field methods which call a search on the target class
    #def self.findable_by(field, options = {})
    #  url_param = options[:as] || field
    #  define_method "find_by_#{field.to_s}" do |*args|
    #    target_class.send(:search, @client, url_param, *args)
    #  end
    #end
  end
end
