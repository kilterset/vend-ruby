require 'spec_helper'

describe Vend::Resource::RegisterSaleProduct do
  let(:attrs) { double("attrs") }

  subject { described_class.new(attrs) }

  it :attrs do
    expect(subject.attrs).to eq attrs
  end

  describe "provides an attr reader for the attributes in attrs" do
    let(:attr1) { double("attr1") }

    let(:attrs) {
      {
        "attr1" => attr1
      }
    }

    it "responds to attr1" do
      expect(subject.send(:attr1)).to eq attr1
    end

    it "does not respond to attr2" do
      expect { subject.send(:attr2) }.to raise_error NoMethodError
    end
  end
end
