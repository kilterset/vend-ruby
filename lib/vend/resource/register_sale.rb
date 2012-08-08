
module Vend
  module Resource

    class RegisterSale < Vend::Base
      url_scope :since
      url_scope :outlet_id
      url_scope :tag
      findable_by :state, :as => :status

      def register_sale_products
        attrs["register_sale_products"].collect do |sale_product_attrs|
          RegisterSaleProduct.new(sale_product_attrs)
        end
      end
    end

  end
end
