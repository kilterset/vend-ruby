module Vend
  module Resource

    class CustomerFactory < Vend::BaseFactory #:nodoc:
      findable_by :email
      findable_by :name, :as => :q
    end

    class Customer < Vend::Base; end

  end
end
