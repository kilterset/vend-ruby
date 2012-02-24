
module Vend
  module Resource

    class RegisterSaleFactory < Vend::BaseFactory #:nodoc:
      findable_by :state, :as => :status
    end

    class RegisterSale < Vend::Base; end

  end
end
