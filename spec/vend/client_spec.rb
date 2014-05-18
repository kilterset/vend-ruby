require 'spec_helper'

describe Vend::Client do

  subject { Vend::Client.new('store','user','password') }

  it_should_behave_like "it has a logger"

  its(:store) { should == 'store' }
  its(:username) { should == 'user' }
  its(:password) { should == 'password' }

  it "creates an instance of Client" do
    subject.should be_instance_of(Vend::Client)
  end

  it "returns the API base url" do
    subject.base_url.should == "https://store.vendhq.com/api/"
  end

  it "should set options" do
    options = { :key => :value }
    client = Vend::Client.new('store','user','password', options)
    options.each do |key, value|
      client.options[key].should == value
    end
  end

  describe "resource factories" do
    it "gets all products" do
      Vend::Resource::Product.should_receive(:all).and_return([])
      subject.Product.all.should == []
    end
  end

  describe "#http_client" do

    let(:http_client)         { double("http_client") }
    let(:http_client_options) { double("http_client_options") }

    before do
      subject.stub(:http_client_options => http_client_options)
      Vend::HttpClient.should_receive(:new).with(http_client_options) { http_client }
    end

    it "should return a memoized HttpClient instance" do
      subject.http_client.should == http_client
      subject.http_client.should == http_client
    end

  end

  describe "#http_client_options" do

    let(:options)   { {:foo => 'bar'} }
    let(:base_url)  { "http://foo/" }
    let(:username)  { "username" }
    let(:password)  { "password" }

    before do
      subject.stub(
        :options => options,
        :base_url => base_url,
        :username => username,
        :password => password
      )
    end

    its(:http_client_options) {
      should == {
        :foo => 'bar',
        :base_url => base_url,
        :username => username,
        :password => password
      }
    }
  end

  describe "#request" do

    let(:response)    { double("response") }
    let(:http_client) { double("http_client") }

    before do
      subject.stub(:http_client => http_client)
      http_client.should_receive(:request).with("foo", "bar") { response }
    end

    it "delegates to the http_client" do
      subject.request("foo", "bar").should == response
    end
  end
end
