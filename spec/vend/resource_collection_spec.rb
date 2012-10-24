require 'spec_helper'

describe Vend::ResourceCollection do

  let(:client)        { mock("client") }
  let(:target_class)  {
    mock("target_class", :default_collection_request_args => {})
  }
  let(:endpoint)      { "endpoint" }
  let(:request_args)  { {} }

  subject { described_class.new(client, target_class, endpoint, request_args) }

  its(:client)        { should == client }
  its(:target_class)  { should == target_class }
  its(:endpoint)      { should == endpoint }
  its(:scopes)        { should == [] }

  describe "#request_args" do

    its(:request_args)  { should == request_args }

    context "when not set in initialize" do
      subject {
        described_class.new(client, target_class, endpoint)
      }
      its(:request_args)  { should == {} }
    end

    context "when target class has default request args" do
      subject {
        described_class.new(client, target_class, endpoint)
      }
      before { target_class.stub(:default_collection_request_args => {:foo => :bar}) }
      its(:request_args)  { should == {:foo => :bar}}
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

  describe "#paged?" do

    context "when pagination is set" do
      let(:value)       { mock("value") }
      let(:pagination)  { mock("pagination", :paged? => value) }
      before do
        subject.stub(:pagination => pagination)
      end
      it "delegates to #pagination" do
        subject.paged?.should == value
      end
    end

    context "when pagination is nil" do
      specify do
        subject.paged?.should be_false
      end
    end

  end

  [:pages, :page].each do |method|
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

  describe "#scope" do
    let(:value)   { mock("value") }
    let(:scope)   { mock("scope") }
    let(:scopes)  { mock("scopes") }

    context "when scope is not already present" do
      before do
        subject.stub(:has_scope?).with(:name) { false }
        subject.stub(:scopes => scopes)
        Vend::Scope.stub(:new).with(:name, value) { scope }
        scopes.should_receive(:<<).with(scope)
      end
      it "returns self" do
        subject.scope(:name, value).should == subject
      end
    end

    context "when already scoped" do
      before do
        subject.stub(:has_scope?).with(:name) { true }
      end
      it "raises and AlreadyScopedError" do
        lambda do
          subject.scope(:name, value)
        end.should raise_exception(Vend::ResourceCollection::AlreadyScopedError)
      end
    end
  end

  describe "#has_scope?" do
    context "when scope is not present" do
      it { should_not have_scope(:name) }
    end
    context "when scope is present" do
      let(:scope) { mock("scope", :name => :name) }
      before do
        subject.stub(:scopes => [scope])
      end
      it { should have_scope(:name) }
    end
  end

  describe "#accepts_scope?" do
    let(:value) { mock("value") }
    before do
      target_class.stub(:accepts_scope?).with(:name)  { value }
    end
    it "delegates to target_class" do
      subject.accepts_scope?(:name).should == value
    end
  end

  describe "#method_missing" do

    let(:value) { mock("value") }

    context "when the method name is a valid scope name" do

      before do
        subject.stub(:accepts_scope?).with(:foo) { true }
      end

      it { should respond_to(:foo) }

      it "adds the relevant scope if it accepts a scope for the method name" do
        subject.should_receive(:scope).with(:foo, value) { subject }
        subject.foo(value).should == subject
      end

    end

    context "when the method name is not a valid scope name" do

      before do
        subject.stub(:accepts_scope?).with(:foo) { false }
      end

      it { should_not respond_to(:foo) }

      it "raises method missing" do
        lambda do
          subject.foo(value)
        end.should raise_exception(NoMethodError)
      end

    end

  end

  describe "#url" do

    let(:endpoint_with_scopes) { "endpoint_with_scopes" }

    before do
      subject.stub(:endpoint_with_scopes => endpoint_with_scopes)
      subject.should_receive(:increment_page)
    end

    its(:url) { should == endpoint_with_scopes }
  end

  describe "#endpoint_with_scopes" do
    
    context "when there are no scopes" do
      its(:endpoint_with_scopes) { should == endpoint }
    end

    context "when there are scopes" do
      let(:scope1) { "scope1" }
      let(:scope2) { "scope2" }
      let(:scopes) { [scope1, scope2] }
      before do
        subject.stub(:scopes => scopes)
      end

      its(:endpoint_with_scopes) { should == endpoint + scopes.join}
    end
  end

  describe "#increment_page" do

    context "when not paged" do

      before do
        subject.stub(:paged? => false)
      end

      its(:increment_page) { should be_nil }

    end

    context "when paged" do

      let(:page_scope)  { mock("page_scope", :value => 1) }

      before do
        subject.stub(:paged? => true)
        subject.stub(:page => 1)
        subject.should_receive(:get_or_create_page_scope) { page_scope }
        page_scope.should_receive(:value=).with(2) { 2 }
      end

      its(:increment_page) { should == 2 }

    end

  end

  describe "#get_or_create_page_scope" do

    let(:page_scope)  { mock("page_scope") }
    let(:page)        { 1 }

    before do
      subject.stub(:page => page)
      subject.should_receive(:get_scope).with(:page) { page_scope }
    end

    context "when scope is not present" do
      before do
        subject.stub(:has_scope?).with(:page) { false }
        subject.should_receive(:scope).with(:page, page) { page_scope }
      end
      its(:get_or_create_page_scope)  { should == page_scope }
    end

    context "when scope is already present" do
      before do
        subject.stub(:has_scope?).with(:page) { true }
      end
      its(:get_or_create_page_scope)  { should == page_scope }
    end
  end

  describe "#get_scope" do

    let(:scope_name)  { :scope_name }
    let(:scope)       { mock("scope", :name => scope_name) }

    context "when scope is present" do

      before do
        subject.stub(:scopes => [scope])
      end

      specify do
        subject.get_scope(scope_name).should == scope
      end

    end

    context "when scope is not present" do
      before do
        subject.stub(:scopes => [])
      end
      specify do
        lambda do
          subject.get_scope(scope_name)
        end.should raise_exception(Vend::ResourceCollection::ScopeNotFoundError)
      end
    end

  end
end
