module Vend
  module Resource

    class CustomerFactory < Vend::BaseFactory #:nodoc:
    end

    class Customer < Vend::Base
      url_scope :since
      findable_by :email
      findable_by :name, :as => :q
    end

  end
end
