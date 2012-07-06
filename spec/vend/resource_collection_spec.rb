require 'spec_helper'

describe Vend::ResourceCollection do

  let(:client)        { mock("client") }
  let(:target_class)  { mock("target_class") }
  let(:response)      { mock("response") }

  subject { described_class.new(client, target_class, response) }

  its(:client)        { should == client }
  its(:target_class)  { should == target_class }
  its(:response)      { should == response }

  describe "#each" do

    let(:member_one)  { mock("member_one") }
    let(:member_two)  { mock("member_two") }

    before do
      subject.stub(:members => [member_one, member_two])
    end

    it "yields each member" do
      member_one.should_receive(:ping!)
      member_two.should_receive(:ping!)
      subject.each do |member|
        member.ping!
      end
    end

    it "returns self" do
      subject.each.should == subject
    end
  end

end
