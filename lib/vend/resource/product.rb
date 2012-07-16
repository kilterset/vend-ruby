module Vend
  module Resource

    class Product < Vend::Base
      url_scope :since
      url_scope :active
    end

  end
end
