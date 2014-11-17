
describe Subscription do
  it { should belong_to :user }
  it { should belong_to :target }

  it { should validate_presence_of :user }
  it { should validate_presence_of :target }
end
