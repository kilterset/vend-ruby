module Vend
  module Resource

    class ProductFactory < Vend::BaseFactory #:nodoc:
    end

    class Product < Vend::Base
      url_scope :since
      url_scope :active
    end

  end
end
