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

    # Returns the list of URL parameter scopes that are available for this
    # resource.  For example, if the resource accepted URLs like:
    #
    #   /api/resources/since/YYYY-MM-DD HH:MM:SS/outlet_id/abc-1234-def
    #
    # this method would return [:since, :outlet_id]
    def self.available_scopes
      @available_scopes ||= []
    end

    def self.accepts_scope?(scope_name)
      available_scopes.include?(scope_name)
    end

    # Creates a class method that allows access to a filtered collection of
    # resources on the API.  For example:
    #
    #   class MyResource << Vend::Base
    #     url_scope :since
    #   end
    #
    # Will create a class method:
    #
    #   client.MyResource.since(argument)
    #
    # That will call the following URL on the Vend API:
    #
    #   /api/my_resources/since/:argument
    #
    # And return the corresponding collection of resources
    def self.url_scope(method_name)
      (class << self ; self ; end).instance_eval do
        define_method(method_name) do |client, arg|
          initialize_collection(client, collection_name).scope(method_name, arg)
        end
      end
      available_scopes << method_name
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

    # Initializes a single object from a JSON response.
    # Assumes the response is a JSON array with a single item.
    def self.initialize_singular(client, json)
      self.build(client, json[collection_name].first)
    end

    # Will initialize a collection of Resources from the APIs JSON Response.
    def self.initialize_collection(client, endpoint, args = {})
      ResourceCollection.new(client, self, endpoint, args)
    end


    # Attempts to pull a singular object from Vend through the singular GET
    # endpoint.
    def self.find(client, id)
      response = client.request(collection_name, :id => id)
      initialize_singular(client, response)
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
