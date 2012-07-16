module Vend
  module Resource

    class Product < Vend::Base
      url_scope :since
      url_scope :active

      cast_attribute :supply_price, Float
    end

  end
end
