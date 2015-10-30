require 'spec_helper'

describe Vend::BaseFactory do
  class Vend::Resource::FooFactory < Vend::BaseFactory #:nodoc:
  end

  class Vend::Resource::Foo < Vend::Base #:nodoc:
  end

  let(:client) { double() }
  subject { Vend::Resource::FooFactory.new(client, Vend::Resource::Foo) }

  it "initializes correctly" do
    expect(subject).to be_instance_of(Vend::Resource::FooFactory)
    expect(subject.client).to eq client
    expect(subject.target_class).to eq Vend::Resource::Foo
  end

  it "proxies 'find' to the target class" do
    expect(Vend::Resource::Foo).to receive(:find)
    subject.find
  end

  it "proxies 'all' to the target class" do
    expect(Vend::Resource::Foo).to receive(:all)
    subject.all
  end

  it "proxies 'since' to the target class" do
    expect(Vend::Resource::Foo).to receive(:since)
    subject.since
  end

  it "proxies 'outlet_id' to the target class" do
    expect(Vend::Resource::Foo).to receive(:outlet_id)
    subject.outlet_id
  end

  it "proxies 'build' to the target class" do
    expect(Vend::Resource::Foo).to receive(:build)
    subject.build
  end

  it "returns the target class" do
    expect(subject.target_class).to eq Vend::Resource::Foo
  end
end
