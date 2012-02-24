def url(store, username, password)
  "https://#{username}:#{password}@#{store}.vendhq.com/api/"
end

def get_mock_from_path(method, options = {})
  file_path = described_class.endpoint_name.pluralize
  file_path += "/#{options[:id]}" if options[:id]
  file_path = file_path + '.' + method.to_s unless method == :get
  get_mock_response("#{file_path}.json")
end

def class_basename
  described_class.name.split('::').last
end

def build_receiver
  client.send(class_basename)
end

shared_examples "a resource with a collection GET endpoint" do

  let(:username)  {"foo"}
  let(:password)  {"bar"}
  let(:store)     {"baz"}

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  it "gets the collection" do
    stub_request(:get, "https://#{username}:#{password}@#{store}.vendhq.com/api/#{class_basename.to_s.underscore.pluralize}").
    to_return(:status => 200, :body => get_mock_from_path(:get))

    collection = build_receiver.all
    collection.length.should == expected_collection_length

    first = collection.first
    first.should have_attributes(expected_attributes)
  end
end

shared_examples "a resource with a singular GET endpoint" do

  let(:username)  {"foo"}
  let(:password)  {"bar"}
  let(:store)     {"baz"}

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  it "gets the resource" do
    stub_request(:get, "https://#{username}:#{password}@#{store}.vendhq.com/api/#{class_basename.to_s.underscore.pluralize}/#{id}").
    to_return(:status => 200, :body => get_mock_from_path(:get, :id => id))

    objekt = build_receiver.find(id)
    objekt.should have_attributes(expected_attributes)
  end
end

shared_examples "a resource with a DELETE endpoint" do

  let(:username)  {"foo"}
  let(:password)  {"bar"}
  let(:store)     {"baz"}

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  it "deletes the resource" do
    stub_request(:delete, "https://#{username}:#{password}@#{store}.vendhq.com/api/#{class_basename.to_s.underscore.pluralize}/#{expected_attributes['id']}").
    to_return(:status => 200, :body => {})

    objekt = build_receiver.build(expected_attributes)
    objekt.delete.should be_true
  end

end
