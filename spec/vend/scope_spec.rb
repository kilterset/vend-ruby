require 'spec_helper'

describe Vend::Scope do

  let(:name)    { :name }
  let(:value)   { "value" }

  subject { described_class.new(name, value) }

  its(:name)    { should == name }
  its(:value)   { should == value }


  describe "#to_s" do

    let(:escaped_value) { "escaped_value" }

    before do
      subject.stub(:escaped_value => escaped_value)
    end

    its(:to_s)    { should == "/#{name}/#{escaped_value}" }

  end

  describe "#escaped_value" do
    let(:value) { "value with spaces" }
    its(:escaped_value) { should == "value+with+spaces" }

    context "when value is a Fixnum" do
      let(:value) { 42 }
      its(:escaped_value) { should == "42" }
    end

    context "when value is a timestamp" do
      let(:value) { Time.new(2012,7,11,10,40,29) }
      its(:escaped_value) { should == "2012-07-11+10%3A40%3A29" }
    end
  end

end
