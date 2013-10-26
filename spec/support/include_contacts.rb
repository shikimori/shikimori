RSpec::Matchers.define :include_contacts do |expected|
  match do |actual|
    actual.include?(expected[:jabber]) &&
      actual.include?(expected[:icq]) &&
      actual.include?(expected[:skype]) &&
      actual.include?(expected[:mail])
  end
end
