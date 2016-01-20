RSpec::Matchers.define :have_attributes do |expected|
  match do |_attributes|
    expected.each do |key, value|
      expect(actual.send(key)).to eq value
    end
  end

  failure_message do |actual|
    "expected #{actual.attrs} to match #{expected}"
  end
end
