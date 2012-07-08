module Vend
  # This is an enumerable class which allows iteration over a collection of
  # resources.  This class will automatically fetch paginated results if the
  # target_class supports it.
  class ResourceCollection

    include Enumerable

    attr_reader :client, :target_class, :endpoint, :request_args

    def initialize(client, target_class, endpoint, request_args = {})
      @client       = client
      @target_class = target_class
      @endpoint     = endpoint
      @request_args = request_args
    end

    def each
      members.each do |member|
        yield member if block_given?
      end
      self
    end

    protected
    def members
      response = client.request(endpoint, request_args)
      @members ||= target_class.build_from_json(client, response)
    end
  
  end
end
