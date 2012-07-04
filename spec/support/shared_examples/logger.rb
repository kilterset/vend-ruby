shared_examples_for "a logger" do
  it { should respond_to(:debug) }
  it { should respond_to(:info) }
  it { should respond_to(:warn) }
  it { should respond_to(:error) }
  it { should respond_to(:fatal) }
end
