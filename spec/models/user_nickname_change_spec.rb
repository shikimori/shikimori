describe UserNicknameChange do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :value }
    #it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:value) }
  end
end
