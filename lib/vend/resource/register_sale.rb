
module Vend
  module Resource

    class RegisterSaleFactory < Vend::BaseFactory #:nodoc:
      findable_by :state, :as => :status
    end

    class RegisterSale < Vend::Base
      url_scope :since
      url_scope :outlet_id
      url_scope :tag
    end

  end
end
