module Vend
  # This is an enumerable class which allows iteration over a collection of
  # resources.  This class will automatically fetch paginated results if the
  # target_class supports it.
  class ResourceCollection

    class PageOutOfBoundsError < StandardError ; end

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

    def is_paged?
      !pagination.nil?
    end

    def last_page?
      if !response.nil?
        if is_paged?
          pagination['page'] == pagination['pages']
        else
          true
        end
      end
    end

    # FIXME - Extract class
    def current_page
      if !response.nil?
        if is_paged?
          pagination["page"]
        else
          1
        end
      end
    end

    def pages
      if !response.nil?
        if is_paged?
          pagination["pages"]
        else
          1
        end
      end
    end

    def pagination
      if response.instance_of? Hash
        response["pagination"]
      end
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
      if response && is_paged?
        next_page = current_page + 1
        full_endpoint = endpoint + '/page/' + next_page.to_s
      else
        full_endpoint = endpoint
      end
      self.response = client.request(full_endpoint, request_args)
    end
  
  end
end
