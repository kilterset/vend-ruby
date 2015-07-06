RSpec::Matchers.define :have_attributes do |expected|
  match do |attributes|
    expected.each do |key,value|
      actual.send(key).should == value
    end
  end

  failure_message do |actual|
    "expected #{actual.attrs} to match #{expected}"
  end
end
