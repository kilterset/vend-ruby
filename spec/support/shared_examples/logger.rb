shared_examples_for "a logger" do
  specify :responds_to_debug do
    expect(subject).to respond_to(:debug)
  end

  specify :responds_to_info do
    expect(subject).to respond_to(:info)
  end

  specify :responds_to_warn do
    expect(subject).to respond_to(:warn)
  end

  specify :responds_to_error do
    expect(subject).to respond_to(:error)
  end

  specify :responds_to_fatal do
    expect(subject).to respond_to(:fatal)
  end
end

shared_examples_for "it has a logger" do
  describe "#logger" do

    let(:logger)  { double("logger") }

    it "defaults to a null logger" do
      expect(subject.logger).to be_instance_of(Vend::NullLogger)
    end

    it "allows the logger to be set" do
      subject.logger = logger
      expect(subject.logger).to eq logger
    end
  end
end
