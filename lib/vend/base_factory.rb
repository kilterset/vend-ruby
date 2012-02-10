module Vend

  class BaseFactory

    attr_reader :client

    def initialize(client)
      @client = client
    end

    # Returns the target class of this factory. E.g. Vend::Resource::FooFactory
    # generates Vend::Resource::Foo instances
    def target_class
      target = self.class.name.sub(/Factory$/,'')
      class_components = target.split('::')

      class_components.inject(Module) do |mod, const_name|
        mod.const_get(const_name)
      end
    end

    def self.delegate_to_target_class(*method_names)
      method_names.each do |method_name|
        define_method method_name do |*args|
          target_class.send(method_name, @client, *args)
        end
      end
    end

    # The main point of this factory class is to proxy methods to the target
    # class and prepend client to the argument list.
    delegate_to_target_class :all

  end

end
