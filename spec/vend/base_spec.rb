require 'spec_helper'

describe Vend::Base do
  class Vend::Resource::Foo < Vend::Base #:nodoc
    url_scope :bar
  end

  let(:client) { double(:client) }
  let(:attribute_hash) { { key: 'value', 'id' => 1} }
  let(:mock_response) do
    {
      'foos' => [
        {'id' => '1', 'bar' => 'baz'},
        {'id' => '2', 'flar' => 'flum'}
      ]
    }
  end

  subject { Vend::Resource::Foo.new(client, attrs: attribute_hash) }

  it 'creates an instance of Foo' do
    expect(subject).to be_instance_of(Vend::Resource::Foo)
  end

  it 'assigns the client' do
    expect(subject.client).to eq client
  end

  it 'assigns the attributes' do
    expect(subject.attrs).to eq attribute_hash
  end

  describe '.build' do
    it 'builds a Foo' do
      expect(Vend::Resource::Foo.build(client, attrs: attribute_hash)).to be_instance_of(Vend::Resource::Foo)
    end
  end

  describe '.initialize_singular' do
    it 'initializes a singular resource from parsed JSON results' do
      resource = Vend::Resource::Foo.initialize_singular(client, mock_response)
      expect(resource).to be_a Vend::Resource::Foo
      expect(resource.bar).to eq 'baz'
    end
  end

  describe '.initialize_collection' do
    subject { Vend::Resource::Foo }

    let(:endpoint)            { double('endpoint') }
    let(:args)                { double('args') }
    let(:resource_collection) { double('resource_collection') }

    before do
      expect(Vend::ResourceCollection).to receive(:new).with(
        client, subject, endpoint, args
      ) { resource_collection }
    end

    it 'creates a ResourceCollection instance' do
      expect(
        subject.initialize_collection(client, endpoint, args)
      ).to eq resource_collection
    end
  end

  describe '.endpoint_name' do
    it 'returns the endpoint name' do
      expect(Vend::Resource::Foo.endpoint_name).to eq 'foo'
    end
  end

  describe '.collection_name' do
    it 'returns the collection name' do
      expect(Vend::Resource::Foo.collection_name).to eq 'foos'
    end
  end

  describe '.singular_name' do
    it 'returns the collection name plus the id' do
      expect(Vend::Resource::Foo.singular_name('1')).to eq 'foos/1'
      expect(Vend::Resource::Foo.singular_name(42)).to eq 'foos/42'
    end
  end

  describe '#singular_name' do
    specify :singular_name do
      expect(subject.singular_name).to eq "foos/#{subject.id}"
    end
  end

  describe '.find' do
    let(:id) { 1 }
    let(:singular_name) { 'foos/1' }

    before do
      Vend::Resource::Foo.stub(:singular_name).with(id) { singular_name }
    end

    it 'finds a Foo by id' do
      mock_response = { 'foos' => [{ 'id' => '1', 'bar' => 'baz' }]}
      expect(client).to receive(:request).with(singular_name) { mock_response }
      foo = Vend::Resource::Foo.find(client, id)
      expect(foo).to be_instance_of(Vend::Resource::Foo)
      expect(foo.bar).to eq 'baz'
    end
  end

  describe '.all' do
    subject { Vend::Resource::Foo }

    let(:collection_name)     { double('collection_name') }
    let(:resource_collection) { double('resource_collection') }

    before do
      subject.stub(collection_name: collection_name)
    end

    it 'calls initialize_collection with the collection_name' do
      expect(subject).to receive(:initialize_collection).with(
        client, collection_name
      ) { resource_collection }
      expect(subject.all(client)).to eq resource_collection
    end
  end

  describe '.url_scope' do
    subject { Vend::Resource::Foo }

    let(:collection_name)     { double('collection_name') }
    let(:resource_collection) { double('resource_collection') }
    let(:bar)                 { double('bar') }

    before do
      subject.stub(collection_name: collection_name)
    end

    it 'calls initialize_collection with collection_name and :bar arg' do
      expect(subject).to receive(:initialize_collection).with(
        client, collection_name
      ) { resource_collection }
      expect(resource_collection).to receive(:scope).with(:bar, bar) {
        resource_collection
      }
      expect(subject.bar(client, bar)).to eq resource_collection
    end
  end

  describe '.search' do
    subject { Vend::Resource::Foo }

    let(:collection_name)     { double('collection_name') }
    let(:resource_collection) { double('resource_collection') }
    let(:field)               { 'field' }
    let(:query)               { 'query' }

    before do
      subject.stub(collection_name: collection_name)
    end

    it 'calls initialize_collection with collection_name and :outlet_id arg' do
      expect(subject).to receive(:initialize_collection).with(
        client, collection_name, url_params: { field.to_sym => query }
      ) { resource_collection }
      expect(subject.search(client, field, query)).to eq resource_collection
    end
  end

  describe '.build_from_json' do
    subject { Vend::Resource::Foo }

    let(:json)              { {'foos' => attributes_array} }
    let(:attributes_one)    { double('attributes_one') }
    let(:attributes_two)    { double('attributes_two') }
    let(:attributes_array)  { [attributes_one, attributes_two] }
    let(:instance_one)      { double('instance_one') }
    let(:instance_two)      { double('instance_two') }

    specify do
      subject.stub(:build).with(client, attributes_one) { instance_one }
      subject.stub(:build).with(client, attributes_two) { instance_two }
      expect(subject.build_from_json(client, json)).to eq [
        instance_one, instance_two
      ]
    end
  end

  describe 'dynamic instance methods' do
    let(:attrs) { { 'one' => 'foo', 'two' => 'bar', 'object_id' => 'fail' } }
    subject { Vend::Resource::Foo.new(client, attrs: attrs) }

    it 'responds to top level attributes' do
      expect(subject).to respond_to(:one)
      expect(subject).to respond_to(:two)
      expect(subject).to respond_to(:object_id)
      expect(subject.one).to eq 'foo'
      expect(subject.two).to eq 'bar'
      expect(subject.object_id).to_not eq 'fail'
      expect(subject.attrs['object_id']).to eq 'fail'
    end
  end

  describe 'delete!' do
    context 'when id is present' do
      subject { Vend::Resource::Foo.new(client, attrs: {'id' => 1}) }

      let(:singular_name) { double('singular_name') }

      before do
        subject.stub(singular_name: singular_name)
      end

      it 'deletes the object' do
        expect(client).to receive(:request).with(singular_name, method: :delete)
        subject.delete!
      end
    end

    context 'when id is absent' do
      subject { Vend::Resource::Foo.new(client, attrs: {foo: 'bar'}) }

      it 'raises Vend::Resource::IllegalAction' do
        expect(client).to_not receive(:request)
        expect do
          subject.delete!
        end.to raise_error(Vend::Resource::IllegalAction, 'Vend::Resource::Foo has no unique ID')
      end
    end
  end

  describe 'delete' do
    it 'returns false when no id is present' do
      subject = Vend::Resource::Foo.new(client, attrs: {foo: 'bar'})
      expect(client).to_not receive(:request)
      expect(subject.delete).to be_falsey
    end
  end

  describe '.default_collection_request_args' do
    subject { Vend::Resource::Foo }
    specify :default_collection_request_args do
      expect(subject.default_collection_request_args).to eq({})
    end
  end

  describe '.paginates?' do
    subject { Vend::Resource::Foo }

    it 'defaults to false' do
      expect(subject.paginates?).to be_falsey
    end
  end

  describe '.available_scopes' do
    subject { Vend::Resource::Foo }
    specify :available_scopes do
      expect(subject.available_scopes).to eq [:bar]
    end
  end

  describe '.accepts_scope?' do
    let(:scope_name) { :scope_name }
    subject { Vend::Resource::Foo }

    context 'when scope is accepted' do
      before do
        subject.stub(available_scopes: [scope_name])
      end
      specify do
        expect(subject.accepts_scope?(scope_name)).to be_truthy
      end
    end

    context 'when scope is not accepted' do
      before do
        subject.stub(available_scopes: [])
      end
      specify do
        expect(subject.accepts_scope?(scope_name)).to be_falsey
      end
    end
  end

  describe '.findable_by' do
    subject { Vend::Resource::Foo }

    let(:args)  { double('args') }

    it 'creates a find_by_foo method on the class' do
      expect(subject).to_not respond_to(:find_by_foo)
      subject.findable_by(:foo)
      expect(subject).to respond_to(:find_by_foo)
    end

    it 'proxies to search' do
      subject.findable_by(:foo)
      expect(subject).to receive(:search).with(client, :foo, args)
      subject.find_by_foo(client, args)
    end

    it 'allows a different method name' do
      subject.findable_by(:foo, as: :bar)
      expect(subject).to receive(:search).with(client, :bar, args)
      subject.find_by_foo(client, args)
    end
  end

  describe '.cast_attribute' do
    subject { Vend::Resource::Foo }

    let(:attrs) { {'floater' => '1.23'} }

    it 'casts to float' do
      subject.cast_attribute :floater, Float
      foo = Vend::Resource::Foo.new(client, attrs: attrs)
      expect(foo.floater).to eq 1.23
    end
  end
end
