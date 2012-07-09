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

    it "yields each member and returns self" do
      member_one.should_receive(:ping!)
      member_two.should_receive(:ping!)
      subject.each do |member|
        member.ping!
      end.should == subject
    end

  end

  describe "#is_paged?" do

    let(:response)  { {"pagination" => {} } }

    before do
      subject.stub(:response => response)
    end

    its(:is_paged?) { should be_true }

    context "when response doesn't contain a pagination key" do
      let(:response)  { {} }
      its(:is_paged?) { should be_false }
    end

  end

  describe "#last_page?" do

    let(:pagination)  { mock("pagination") }

    before do
      subject.stub(:response => response)
    end

    context "when response is absent" do
      let(:response)    { nil }
      its(:last_page?)  { should be_false }
    end

    context "when response is present" do

      context "and pagination info is absent" do
        let(:response)    { {} }
        its(:last_page?)  { should be_true }
      end

      context "and pagination info is present" do

        let(:response)    { {"pagination" => pagination} }

        context "and it is not the last page" do
          let(:pagination)  { {"page" => 1, "pages" => 2} }
          its(:last_page?)  { should be_false }
        end

        context "and it is the last page" do
          let(:pagination)  { {"page" => 2, "pages" => 2} }
          its(:last_page?)  { should be_true }
        end

      end

    end

  end

  describe "#current_page" do

    let(:response)  { mock("response") }

    it "returns nil when no requests have been made" do
      subject.stub(:response => nil)
      subject.current_page.should be_nil
    end

    it "returns 1 when a request has been made without pagination info" do
      subject.stub(:response => response, :is_paged? => false)
      subject.current_page.should == 1
    end

    it "returns the page number from the pagination info" do
      subject.stub(
        :response => response, :is_paged? => true, :pagination => {"page" => 42}
      )
      subject.current_page.should == 42
    end
  end

  describe "#pagination" do

    let(:pagination)  { mock("pagination") }

    before do
      subject.stub(:response => response)
    end

    context "when response is absent" do
      let(:response)    { nil }
      its(:pagination)  { should be_nil }
    end

    context "when response is present" do

      context "and pagination info is absent" do
        let(:response)    { {} }
        its(:pagination)  { should be_nil }
      end

      context "and pagination info is present" do
        let(:response)    { {"pagination" => pagination} }
        its(:pagination)  { should == pagination }
      end

    end

  end

  describe "#pages" do

    let(:pagination)  { {"pages" => 75} }
    let(:response)    { mock("response") }

    before do
      subject.stub(:response => response)
    end

    context "when response is absent" do
      let(:response)  { nil }
      its(:pages)     { should be_nil }
    end

    context "when response is present" do

      context "and pagination info is absent" do
        let(:response)  { {} }
        its(:pages)     { should == 1 }
      end

      context "and pagination info is present" do
        let(:response)  { {"pagination" => pagination} }
        its(:pages)     { should == 75 }
      end

    end
  end

end
