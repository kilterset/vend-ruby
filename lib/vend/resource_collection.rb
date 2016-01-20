require 'forwardable'
module Vend
  # This is an enumerable class which allows iteration over a collection of
  # resources.  This class will automatically fetch paginated results if the
  # target_class supports it.
  class ResourceCollection
    class PageOutOfBoundsError < StandardError; end
    class AlreadyScopedError < StandardError; end
    class ScopeNotFoundError < StandardError; end

    include Enumerable
    extend Forwardable

    attr_reader :client, :target_class, :endpoint, :request_args

    def_delegators :pagination, :pages, :page
    def_delegators :target_class, :accepts_scope?

    def initialize(client, target_class, endpoint, request_args = {})
      @client       = client
      @target_class = target_class
      @endpoint     = endpoint
      @request_args = target_class.default_collection_request_args.merge(request_args)
    end

    def each
      # If each has previously been invoked on this collection, the response
      # member will already be set, causing last_page? to immeadiatly return
      # true.  So reset it here.
      self.response = nil

      until last_page?
        target_class.build_from_json(client, get_next_page).map do |resource|
          yield resource
        end
      end
      self
    end

    def pagination
      PaginationInfo.new(response) if response.instance_of? Hash
    end

    def last_page?
      pagination && pagination.last_page?
    end

    def paged?
      pagination && pagination.paged?
    end

    def scopes
      @scopes ||= []
    end

    # Adds a new URL scope parameter to this ResourceCollection. Calling
    # scope(:foo, 'bar') will effectively append '/foo/bar' to the resource
    # URL.
    def scope(name, value)
      raise AlreadyScopedError if has_scope?(name)
      scopes << Scope.new(name, value)
      self
    end

    def has_scope?(name)
      scopes.any? { |s| s.name == name }
    end

    def method_missing(method_name, *args, &block)
      if accepts_scope?(method_name)
        scope(method_name, *args)
      else
        super
      end
    end

    def respond_to?(method_name)
      return true if accepts_scope?(method_name)
      super
    end

    def increment_page
      if paged?
        page_scope = get_or_create_page_scope
        page_scope.value = page_scope.value + 1
      end
    end

    def get_scope(name)
      result = scopes.find { |scope| scope.name == name }
      if result.nil?
        raise ScopeNotFoundError.new(
          "Scope: #{name} was not found in #{scopes}."
        )
      end
      result
    end

    def get_or_create_page_scope
      scope(:page, page) unless has_scope? :page
      get_scope :page
    end

    def url
      increment_page
      endpoint_with_scopes
    end

    def endpoint_with_scopes
      endpoint + scopes.join
    end

  protected

    attr_accessor :response

  protected

    def get_next_page
      if last_page?
        raise PageOutOfBoundsError.new(
          "get_next_page called when already on last page"
        )
      end
      self.response = client.request(url, request_args)
    end
  end
end
