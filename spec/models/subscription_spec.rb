describe Subscription do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :target }

  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :target }
end
