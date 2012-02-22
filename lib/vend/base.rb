module Vend

  # This Base class provides the basic mapping between Vend::Resource subclasses
  # and the HTTP endpoints in the Vend API.
  #
  # Not all CRUD actions are available for every resource, and at current there
  # is no PUT endpoint and hence no update action
  class Base

    # Reference to the Vend::Client client object providing the HTTP interface to the
    # API
    attr_reader :client

    # Hash of attributes for this instance. Represents the data returned from
    # the Vend API
    attr_accessor :attrs

    def initialize(client, options = {}) #:nodoc:
      @client = client
      @attrs = options[:attrs] || {}
    end

    # Returns the endpoint name for the resource, used in API urls when making
    # requests.
    def self.endpoint_name
      self.name.split('::').last.underscore
    end

    # Returns the endpoint name for a collection of this resource
    def self.collection_name
      endpoint_name.pluralize
    end

    # Returns a collection containing all of the specified resource objects.
    # Will paginate.
    def self.all(client)
      response = client.request(collection_name)
      initialize_collection(client, response.body)
    end

    # Returns a collection containing all resources of the specified type that
    # have been modified since the specified date.
    def self.since(client, time)
      response = client.request(collection_name, :since => time)
      initialize_collection(client, response.body)
    end

    def self.build(client, attrs)
      self.new(client, :attrs => attrs)
    end

    def self.parse_json(string) #:nodoc:
      JSON.parse(string)
    rescue JSON::ParserError
      raise Vend::Resource::InvalidResponse, "JSON Parse Error: #{string}"
    end

    # Will initialize a collection of Resources from the APIs JSON Response.
    def self.initialize_collection(client, json)
      results = parse_json(json)
      results[collection_name].map do |attrs|
        self.build(client, attrs)
      end
    end

    # Sends a search request to the API and initializes a collection of Resources
    # from the response.
    # This method is only used internally by find_by_field methods.
    def self.search(client, field, query)
      response = client.request(collection_name, :url_params => { field.to_sym => query.to_s } )
      initialize_collection(client, response.body)
    end

    # Overrides respond_to? to query the attrs hash for the key before
    # proxying it to the object
    def respond_to?(method_name)
      if attrs.keys.include? method_name.to_s
        true
      else
        super(method_name)
      end
    end

    # Overrides method_missing to query the attrs hash for the value stored
    # at the specified key before proxying it to the object
    def method_missing(method_name, *args, &block)
      if attrs.keys.include? method_name.to_s
        attrs[method_name.to_s]
      else
        super(method_name)
      end
    end

    def delete
      delete!
    rescue Vend::Resource::IllegalAction
      false
    end

    def delete!
      raise(Vend::Resource::IllegalAction,
            "#{self.class.name} has no unique ID") unless attrs['id']
      client.request(self.class.collection_name,
                     :method => :delete, :id => attrs['id'])
      true
    end
  end
end
