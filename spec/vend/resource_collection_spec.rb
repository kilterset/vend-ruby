require 'spec_helper'

describe Vend::ResourceCollection do
  let(:client)        { double("client") }
  let(:target_class)  do
    double("target_class", default_collection_request_args: {})
  end
  let(:endpoint)      { "endpoint" }
  let(:request_args)  { {} }

  subject { described_class.new(client, target_class, endpoint, request_args) }

  specify :client do
    expect(subject.client).to eq client
  end

  specify :target_class do
    expect(subject.target_class).to eq target_class
  end

  specify :endpoint do
    expect(subject.endpoint).to eq endpoint
  end

  specify :scopes do
    expect(subject.scopes).to eq []
  end

  describe "#request_args" do
    specify :request_args  do
      expect(subject.request_args).to eq request_args
    end

    context "when not set in initialize" do
      subject { described_class.new(client, target_class, endpoint) }
      specify :request_args  do
        expect(subject.request_args).to eq({})
      end
    end

    context "when target class has default request args" do
      subject do
        described_class.new(client, target_class, endpoint)
      end

      before { target_class.stub(default_collection_request_args: {foo: :bar}) }

      specify :request_args  do
        expect(subject.request_args).to eq({ foo: :bar })
      end
    end
  end

  describe "#each" do
    let(:member_one)  { double("member_one") }
    let(:member_two)  { double("member_two") }
    let(:json)        { double("json") }
    let(:next_page)   { double("next_page") }

    before do
      expect(target_class).to receive(:build_from_json).with(client, next_page) {
        [member_one, member_two]
      }

      client.stub(:request).with(endpoint, request_args) { json }
      subject.stub(:get_next_page) { next_page }
      subject.stub(:last_page?).and_return(false, true)
    end

    it "yields each member and returns self" do
      expect(member_one).to receive(:ping!)
      expect(member_two).to receive(:ping!)
      expect(subject.each(&:ping!)).to eq subject
    end
  end

  describe "#last_page?" do
    context "when pagination" do
      let(:value)       { double("value") }
      let(:pagination)  { double("pagination", last_page?: value) }

      it "is set" do
        subject.stub(pagination: pagination)
        expect(subject.last_page?).to eq(value)
      end
    end

    context 'when pagination' do
      it "is nil" do
        expect(subject.last_page?).to_not be_truthy
      end
    end
  end

  describe "#paged?" do
    context "when pagination is set" do
      let(:value)       { double("value") }
      let(:pagination)  { double("pagination", paged?: value) }
      before do
        subject.stub(pagination: pagination)
      end

      it "delegates to #pagination" do
        expect(subject.paged?).to eq value
      end
    end

    context "when pagination" do
      it 'is nil' do
        expect(subject.paged?).to be_falsey
      end
    end
  end

  #   [:pages, :page].each do |method|
  #     describe method do
  #       let(:value)       { double("value") }
  #       let(:pagination)  { double("pagination", method => value) }
  #       before do
  #         subject.stub(pagination: pagination)
  #       end
  #       it "delegates to #pagination" do
  #         expect(subject.send(method)).to eq value
  #       end
  #     end
  #   end

  describe "#scope" do
    let(:value)   { double("value") }
    let(:scope)   { double("scope") }
    let(:scopes)  { double("scopes") }

    context "when scope is not already present" do
      before do
        subject.stub(:has_scope?).with(:name) { false }
        subject.stub(scopes: scopes)
        Vend::Scope.stub(:new).with(:name, value) { scope }
        expect(scopes).to receive(:<<).with(scope)
      end

      it "returns self" do
        expect(subject.scope(:name, value)).to eq subject
      end
    end

    context "when already scoped" do
      before do
        subject.stub(:has_scope?).with(:name) { true }
      end

      it "raises and AlreadyScopedError" do
        expect do
          subject.scope(:name, value)
        end.to raise_exception(Vend::ResourceCollection::AlreadyScopedError)
      end
    end
  end

  describe "#has_scope?" do
    it "when scope is not present" do
      expect(subject.has_scope?(:name)).to be_falsey
    end

    context "when scope is present" do
      let(:scope) { double("scope", name: :name) }

      before do
        subject.stub(scopes: [scope])
      end

      it "when scope is present" do
        expect(subject.has_scope?(:name)).to be_truthy
      end
    end
  end

  describe "#accepts_scope?" do
    let(:value) { double("value") }
    before do
      target_class.stub(:accepts_scope?).with(:name)  { value }
    end

    it "delegates to target_class" do
      expect(subject.accepts_scope?(:name)).to eq value
    end
  end

  describe "#method_missing" do
    let(:value) { double("value") }
    context "when the method name is a valid scope name" do
      before do
        subject.stub(:accepts_scope?).with(:foo) { true }
      end

      specify :responds_to_foo do
        expect(subject).to respond_to(:foo)
      end

      it "adds the relevant scope if it accepts a scope for the method name" do
        expect(subject).to receive(:scope).with(:foo, value) { subject }
        expect(subject.foo(value)).to eq subject
      end
    end

    context "when the method name is not a valid scope name" do
      before do
        subject.stub(:accepts_scope?).with(:foo) { false }
      end

      it 'responds to foo' do
        expect(subject).to_not respond_to(:foo)
      end

      it "raises method missing" do
        expect do
          subject.foo(value)
        end.to raise_exception(NoMethodError)
      end
    end
  end

  describe "#url" do
    let(:endpoint_with_scopes) { "endpoint_with_scopes" }

    before do
      subject.stub(endpoint_with_scopes: endpoint_with_scopes)
      expect(subject).to receive(:increment_page)
    end

    specify :url do
      expect(subject.url).to eq endpoint_with_scopes
    end
  end

  describe "#endpoint_with_scopes" do
    context "when there are no scopes" do
      specify :endpoint_with_scopes do
        expect(subject.endpoint_with_scopes).to eq endpoint
      end
    end

    context "when there are scopes" do
      let(:scope1) { "scope1" }
      let(:scope2) { "scope2" }
      let(:scopes) { [scope1, scope2] }
      before do
        subject.stub(scopes: scopes)
      end

      specify :endpoint_with_scopes do
        expect(subject.endpoint_with_scopes).to eq endpoint + scopes.join
      end
    end
  end

  describe "#increment_page" do
    context "when not paged" do
      before do
        subject.stub(paged?: false)
      end

      specify :increment_page do
        expect(subject.increment_page).to be_nil
      end
    end

    context "when paged" do
      let(:page_scope)  { double("page_scope", value: 1) }

      before do
        subject.stub(paged?: true)
        subject.stub(page: 1)
        expect(subject).to receive(:get_or_create_page_scope) { page_scope }
        expect(page_scope).to receive(:value=).with(2) { 2 }
      end

      specify :increment_page do
        expect(subject.increment_page).to eq 2
      end
    end
  end

  describe "#get_or_create_page_scope" do
    let(:page_scope)  { double("page_scope") }
    let(:page)        { 1 }

    before do
      subject.stub(page: page)
      expect(subject).to receive(:get_scope).with(:page) { page_scope }
    end

    context "when scope is not present" do
      before do
        subject.stub(:has_scope?).with(:page) { false }
        expect(subject).to receive(:scope).with(:page, page) { page_scope }
      end

      specify :get_or_create_page_scope  do
        expect(subject.get_or_create_page_scope).to eq page_scope
      end
    end

    context "when scope is already present" do
      before do
        subject.stub(:has_scope?).with(:page) { true }
      end
      specify :get_or_create_page_scope  do
        expect(subject.get_or_create_page_scope).to eq page_scope
      end
    end
  end

  describe "#get_scope" do
    let(:scope_name)  { :scope_name }
    let(:scope)       { double("scope", name: scope_name) }

    context "when scope is present" do
      before do
        subject.stub(scopes: [scope])
      end

      specify do
        expect(subject.get_scope(scope_name)).to eq scope
      end
    end

    context "when scope is not present" do
      before do
        subject.stub(scopes: [])
      end

      specify do
        expect do
          subject.get_scope(scope_name)
        end.to raise_exception(Vend::ResourceCollection::ScopeNotFoundError)
      end
    end
  end
end
