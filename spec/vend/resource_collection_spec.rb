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
    let(:next_page)   { mock("next_page") }

    before do
      target_class.should_receive(:build_from_json).with(client, next_page) {
        [member_one, member_two]
      }
      client.stub(:request).with(endpoint, request_args) { json }
      subject.stub(:get_next_page) { next_page }
      subject.stub(:last_page?).and_return(false, true)
    end

    it "yields each member and returns self" do
      member_one.should_receive(:ping!)
      member_two.should_receive(:ping!)
      subject.each do |member|
        member.ping!
      end.should == subject
    end

  end

  describe "#last_page?" do

    context "when pagination is set" do
      let(:value)       { mock("value") }
      let(:pagination)  { mock("pagination", :last_page? => value) }
      before do
        subject.stub(:pagination => pagination)
      end
      it "delegates to #pagination" do
        subject.last_page?.should == value
      end
    end

    context "when pagination is nil" do
      it { should_not be_last_page }
    end

  end

  [:pages, :page, :paged?].each do |method|
    describe method do
      let(:value)       { mock("value") }
      let(:pagination)  { mock("pagination", method => value) }
      before do
        subject.stub(:pagination => pagination)
      end
      it "delegates to #pagination" do
        subject.send(method).should == value
      end
    end
  end

end
