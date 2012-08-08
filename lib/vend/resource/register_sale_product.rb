module Vend
  module Resource
    # Note this class does not have a corresponding endpoint in the vend api
    # It is used to provide a consistent interface to clients using this gem
    class RegisterSaleProduct
      attr_reader :attrs

      def initialize(attrs)
        @attrs = attrs
      end

      def method_missing(method_name, *args, &block)
        if attrs.keys.include? method_name.to_s
          attrs[method_name.to_s]
        else
          super(method_name)
        end
      end
    end
  end
end
