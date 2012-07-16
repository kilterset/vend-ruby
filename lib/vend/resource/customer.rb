module Vend
  module Resource

    class Customer < Vend::Base
      url_scope :since
      findable_by :email
      findable_by :name, :as => :q
    end

  end
end
