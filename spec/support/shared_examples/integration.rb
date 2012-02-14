def url(store, username, password)
  "https://#{username}:#{password}@#{store}.vendhq.com/api/"
end

def get_mock_from_path(method)
  file_path = described_class.endpoint_name.pluralize
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
  it "gets the collection" do
    stub_request(:get, "https://#{username}:#{password}@#{store}.vendhq.com/api/#{class_basename.to_s.downcase.pluralize}").
    to_return(:status => 200, :body => get_mock_from_path(:get))

    collection = build_receiver.all
    collection.length.should == expected_collection_length

    first = collection.first
    first.should have_attributes(expected_attributes)
  end
end
