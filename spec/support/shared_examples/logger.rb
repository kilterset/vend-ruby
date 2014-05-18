shared_examples_for "a logger" do
  it { should respond_to(:debug) }
  it { should respond_to(:info) }
  it { should respond_to(:warn) }
  it { should respond_to(:error) }
  it { should respond_to(:fatal) }
end

shared_examples_for "it has a logger" do
  describe "#logger" do

    let(:logger)  { double("logger") }

    it "defaults to a null logger" do
      subject.logger.should be_instance_of(Vend::NullLogger)
    end

    it "allows the logger to be set" do
      subject.logger = logger
      subject.logger.should == logger
    end

  end

end
