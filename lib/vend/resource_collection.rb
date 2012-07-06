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
      @members ||= build_members
    end

    # FIXME - Extract JSON parser / instance builder
    protected
    def build_members
      parse_json[target_class.collection_name].map do |attrs|
        target_class.build(client, attrs)
      end
    end

    protected
    def parse_json
      response = client.request(endpoint, request_args)
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise Vend::Resource::InvalidResponse, "JSON Parse Error: #{string}"
    end

  end
end
