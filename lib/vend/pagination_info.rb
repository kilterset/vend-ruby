module Vend
  class PaginationInfo
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def pages
      pagination['pages']
    end

    def page
      pagination['page']
    end

    def paged?
      !response['pagination'].nil?
    end

    def last_page?
      pages == page
    end

    protected
    def pagination
      @pagination ||= (response['pagination'] || {"pages" => 1, "page" => 1})
    end
  end
end
