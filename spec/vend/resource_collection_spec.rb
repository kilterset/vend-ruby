require 'spec_helper'

describe Vend::ResourceCollection do

  let(:client)        { mock("client") }
  let(:target_class)  { mock("target_class") }
  let(:endpoint)      { mock("endpoint") }
  let(:request_args)  { mock("request_args") }

  subject { described_class.new(client, target_class, endpoint, request_args) }

  its(:client)        { should == client }
  its(:target_class)  { should == target_class }
  its(:endpoint)      { should == endpoint }

  describe "#request_args" do

    its(:request_args)  { should == request_args }

    context "when not set in initialize" do
      subject {
        described_class.new(client, target_class, endpoint)
      }
      its(:request_args)  { should == {} }
    end

  end

  describe "#each" do

    let(:member_one)  { mock("member_one") }
    let(:member_two)  { mock("member_two") }
    let(:json)        { mock("json") }

    before do
      target_class.should_receive(:build_from_json).with(client, json) {
        [member_one, member_two]
      }
      client.stub(:request).with(endpoint, request_args) { json }
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
