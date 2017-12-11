RSpec::Matchers.define :have_keys do |expected|
  match do |actual|
    actual.keys == expected
  end
end
