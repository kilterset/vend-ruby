require 'forwardable'
module Vend
  # This is an enumerable class which allows iteration over a collection of
  # resources.  This class will automatically fetch paginated results if the
  # target_class supports it.
  class ResourceCollection

    class PageOutOfBoundsError  < StandardError ; end
    class AlreadyScopedError    < StandardError ; end

    include Enumerable
    extend Forwardable

    attr_reader :client, :target_class, :endpoint, :request_args

    def_delegators :pagination, :pages, :page
    def_delegators :target_class, :accepts_scope?

    def initialize(client, target_class, endpoint, request_args = {})
      @client       = client
      @target_class = target_class
      @endpoint     = endpoint
      @request_args = request_args
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
      if response.instance_of? Hash
        PaginationInfo.new(response)
      end
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
      scopes.any? {|s| s.name == name }
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
    
    def url
      if paged?
        next_page = page + 1
        endpoint_with_scopes + '/page/' + next_page.to_s
      else
        endpoint_with_scopes
      end
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
