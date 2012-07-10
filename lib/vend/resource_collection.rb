require 'forwardable'
module Vend
  # This is an enumerable class which allows iteration over a collection of
  # resources.  This class will automatically fetch paginated results if the
  # target_class supports it.
  class ResourceCollection

    class PageOutOfBoundsError < StandardError ; end

    include Enumerable
    extend Forwardable

    attr_reader :client, :target_class, :endpoint, :request_args

    def_delegators :pagination, :pages, :page, :paged?

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

    protected
    attr_accessor :response

    protected
    def members
      return @members if @members
      @members = []
      until last_page?
        @members.concat(target_class.build_from_json(client, get_next_page))
      end
      return @members
    end

    protected
    def get_next_page
      if last_page?
        raise PageOutOfBoundsError.new(
          "get_next_page called when already on last page"
        )
      end
      if response && paged?
        next_page = page + 1
        full_endpoint = endpoint + '/page/' + next_page.to_s
      else
        full_endpoint = endpoint
      end
      self.response = client.request(full_endpoint, request_args)
    end

  end
end
