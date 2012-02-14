require 'spec_helper'

describe Vend::BaseFactory do
  class Vend::Resource::FooFactory < Vend::BaseFactory #:nodoc:
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

  it "proxies 'all' to the target class" do
    Vend::Resource::Foo.should_receive(:all)
    subject.all
  end

  it "returns the target class" do
    subject.target_class.should == Vend::Resource::Foo
  end

end
