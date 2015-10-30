require 'spec_helper'

describe Vend::Resource::RegisterSale do
  subject { described_class.new(nil, {}) }

  describe "#register_sale_products" do
    let(:register_sale_product) { double("register sale product") }
    let(:raw_register_sale_product) { double("raw register sale prodcut") }

    before do
      subject.stub(:attrs) do
        { "register_sale_products" => [raw_register_sale_product] }
      end
      Vend::Resource::RegisterSaleProduct.stub(:new).with(raw_register_sale_product) do
        register_sale_product
      end
    end

    it "returns all the register sale products" do
      expect(subject.register_sale_products).to eq [register_sale_product]
    end
  end
end
