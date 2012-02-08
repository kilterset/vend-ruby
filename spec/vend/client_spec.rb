require 'spec_helper'

describe Vend::Client do

  subject { Vend::Client.new('intergalactic','trish','sand') }

  it "creates an instance of Client" do
    subject.should be_instance_of(Vend::Client)
  end

  it "sets the store" do
    subject.store.should == 'intergalactic'
  end

  it "returns the API base url" do
    subject.base_url.should == "https://intergalactic.vendhq.com/api/"
  end

  it "makes arbitrary requests to the API" do
    stub_request(:get, "https://trish:sand@intergalactic.vendhq.com/api/foo").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})

    response = subject.request('foo')
    response.should be_instance_of(Net::HTTPOK)
  end

end
