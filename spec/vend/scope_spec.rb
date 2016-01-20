require 'spec_helper'

describe Vend::Scope do
  let(:name)    { :name }
  let(:value)   { "value" }

  subject { described_class.new(name, value) }

  specify :name do
    expect(subject.name).to eq name
  end

  specify :value do
    expect(subject.value).to eq value
  end

  describe "#to_s" do
    let(:escaped_value) { "escaped_value" }

    before do
      subject.stub(escaped_value: escaped_value)
    end

    specify :to_s do
      expect(subject.to_s).to eq "/#{name}/#{escaped_value}"
    end
  end

  describe "#escaped_value" do
    let(:value) { "value with spaces" }
    specify :escaped_value do
      expect(subject.escaped_value).to eq "value+with+spaces"
    end

    context "when value is a Fixnum" do
      let(:value) { 42 }
      specify :escaped_value do
        expect(subject.escaped_value).to eq "42"
      end
    end

    context "when value is a timestamp" do
      let(:value) { Time.new(2012, 7, 11, 10, 40, 29) }
      specify :escaped_value do
        expect(subject.escaped_value).to eq "2012-07-11+10%3A40%3A29"
      end
    end
  end
end
