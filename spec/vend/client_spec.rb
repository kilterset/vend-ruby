require 'spec_helper'

describe Vend::Client do

  subject { Vend::Client.new('intergalactic','trish','sand') }

  it "creates an instance of Client" do
    subject.should be_instance_of(Vend::Client)
  end

  it "sets the domain" do
    subject.domain.should == 'intergalactic'
  end

  it "sets the username" do
    subject.username.should == 'trish'
  end

end
