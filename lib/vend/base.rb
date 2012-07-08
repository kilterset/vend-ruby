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
      initialize_collection(client, collection_name)
    end

    # Returns a collection containing all resources of the specified type that
    # have been modified since the specified date.
    def self.since(client, time)
      initialize_collection(client, collection_name, :since => time)
    end

    # Returns a collection containing all resources of the specified type that
    # have an association to a specific outlet.
    def self.outlet_id(client, outlet_id)
      initialize_collection(client, collection_name, :outlet_id => outlet_id)
    end

    # Sends a search request to the API and initializes a collection of Resources
    # from the response.
    # This method is only used internally by find_by_field methods.
    def self.search(client, field, query)
      initialize_collection(
        client, collection_name,  :url_params => { field.to_sym => query }
      )
    end

    # Builds a new instance of the described resource using the specified
    # attributes.
    def self.build(client, attrs)
      self.new(client, :attrs => attrs)
    end

    # Builds a collection of instances from a JSON response
    def self.build_from_json(client, json)
      json[collection_name].map do |attrs|
        self.build(client, attrs)
      end
    end

    def self.parse_json(string) #:nodoc:
      JSON.parse(string)
    rescue JSON::ParserError
      raise Vend::Resource::InvalidResponse, "JSON Parse Error: #{string}"
    end

    # Initializes a single object from a JSON response.
    # Assumes the response is a JSON array with a single item.
    def self.initialize_singular(client, json)
      result = parse_json(json)
      self.build(client, result[collection_name].first)
    end

    # Will initialize a collection of Resources from the APIs JSON Response.
    def self.initialize_collection(client, endpoint, args = {})
      ResourceCollection.new(client, self, endpoint, args).to_a
    end


    # Attempts to pull a singular object from Vend through the singular GET
    # endpoint.
    def self.find(client, id)
      response = client.request(collection_name, :id => id)
      initialize_singular(client, response.body)
    end

    # Whether or not this resource can be paginated, false by default.
    # Override this method in specific classes to enable pagination for that
    # resource.
    def self.paginates?
      false
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

    # Attempts to delete the resource. If an exception is thrown by delete!,
    # it is caught and false is returned (typically when the resource is not
    # a type which can be deleted).
    def delete
      delete!
    rescue Vend::Resource::IllegalAction
      false
    end

    # Attempts to delete there resource. Will throw an exception when the attempt
    # fails, otherwise will return true.
    def delete!
      raise(Vend::Resource::IllegalAction,
            "#{self.class.name} has no unique ID") unless attrs['id']
      client.request(self.class.collection_name,
                     :method => :delete, :id => attrs['id'])
      true
    end
  end
end
