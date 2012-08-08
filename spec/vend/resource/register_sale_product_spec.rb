require 'spec_helper'

describe Vend::Resource::RegisterSaleProduct do
  let(:attrs) { mock("attrs") }

  subject { described_class.new(attrs) }

  its(:attrs) { should == attrs }

  describe "provides an attr reader for the attributes in attrs" do
    let(:attr1) { mock("attr1") }

    let(:attrs) { 
      { 
        "attr1" => attr1
      }
    }

    it "responds to attr1" do
      subject.send(:attr1).should == attr1
    end

    it "does not respond to attr2" do
      lambda { subject.send(:attr2) }.should raise_error NoMethodError
    end
  end
end
