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
  let(:username)  { "foo".freeze }
  let(:password)  { "bar".freeze }
  let(:store)     { "baz".freeze }
  let(:append_to_url) { '' }

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  let(:endpoint) do
    class_basename.to_s == 'Supplier' ? class_basename.to_s.underscore : class_basename.to_s.underscore.pluralize
  end

  it "gets the collection" do
    url = "https://%s.vendhq.com/api/%s%s" % [
      store, endpoint, append_to_url
    ]
    
    stub_request(:get, url).to_return(
      status: 200, body: get_mock_from_path(:get)
    )

    collection = build_receiver.all
    expect(collection.count).to eq(expected_collection_length)

    first = collection.first
    expect(first).to have_attributes(expected_attributes)
  end
end

shared_examples "a resource with a singular GET endpoint" do
  let(:username)  { "foo".freeze }
  let(:password)  { "bar".freeze }
  let(:store)     { "baz".freeze }

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  it "gets the resource" do
    stub_request(:get, "https://#{username}:#{password}@#{store}.vendhq.com/api/#{class_basename.to_s.underscore.pluralize}/#{id}")
    .to_return(status: 200, body: get_mock_from_path(:get, id: id))

    objekt = build_receiver.find(id)
    expect(objekt).to have_attributes(expected_attributes)
  end
end

shared_examples "a resource with a DELETE endpoint" do
  let(:username)  { "foo".freeze }
  let(:password)  { "bar".freeze }
  let(:store)     { "baz".freeze }

  let(:client) do
    Vend::Client.new(store, username, password)
  end

  it "deletes the resource" do
    stub_request(:delete, "https://#{username}:#{password}@#{store}.vendhq.com/api/#{class_basename.to_s.underscore.pluralize}/#{expected_attributes['id']}")
    .to_return(status: 200, body: {}.to_json)

    objekt = build_receiver.build(expected_attributes)
    expect(objekt.delete).to be_truthy
  end
end
