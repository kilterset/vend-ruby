require 'spec_helper'

describe Vend::BaseFactory do
  class Vend::Resource::FooFactory < Vend::BaseFactory #:nodoc:
    findable_by :bar
    findable_by :flum, :as => :flar
  end

  class Vend::Resource::Foo < Vend::Base #:nodoc:
  end

  let(:client) { mock() }
  subject { Vend::Resource::FooFactory.new(client) }

  it "initializes correctly" do
    subject.should be_instance_of(Vend::Resource::FooFactory)
    subject.client.should == client
    subject.target_class.should == Vend::Resource::Foo
  end

  it "proxies 'find' to the target class" do
    Vend::Resource::Foo.should_receive(:find)
    subject.find
  end

  it "proxies 'all' to the target class" do
    Vend::Resource::Foo.should_receive(:all)
    subject.all
  end

  it "proxies 'since' to the target class" do
    Vend::Resource::Foo.should_receive(:since)
    subject.since
  end

  it "proxies 'build' to the target class" do
    Vend::Resource::Foo.should_receive(:build)
    subject.build
  end

  it "returns the target class" do
    subject.target_class.should == Vend::Resource::Foo
  end

  describe "search" do
    it "defines find_by_field methods" do
      collection = Array.new(2) { |i| Vend::Resource::Foo.new(client) }
      subject.target_class.should_receive(:search).with(client, :bar, 'baz').
        and_return(collection)
      subject.should respond_to(:find_by_bar)
      results = subject.find_by_bar('baz')
      results.first.should be_a Vend::Resource::Foo
    end

    it "allows us to specify the url param name" do
      subject.target_class.should_receive(:search).with(client, :flar, 'baz')
      subject.should respond_to(:find_by_flum)
      subject.find_by_flum('baz')
    end
  end

end
