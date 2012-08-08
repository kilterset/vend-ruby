require 'spec_helper'

describe Vend::Resource::RegisterSale do

  subject { described_class.new(nil, {}) }

  describe "#register_sale_products" do
    let(:register_sale_product) { mock("register sale product") }
    let(:raw_register_sale_product) { mock("raw register sale prodcut") }

    before do
      subject.stub(:attrs) { 
        { :register_sale_products => [raw_register_sale_product] } 
      }
      Vend::Resource::RegisterSaleProduct.stub(:new).with(raw_register_sale_product) {
        register_sale_product 
      }
    end

    it "returns all the register sale products" do
      subject.register_sale_products.should == [register_sale_product]
    end
  end
end
