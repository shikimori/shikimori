describe Ignore do
  describe '#relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :target }
  end

  describe '#validations' do
    it { is_expected.to validate_uniqueness_of(:target_id).scoped_to :user_id }
  end
end
