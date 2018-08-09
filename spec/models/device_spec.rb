describe Device do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :platform }
    it { is_expected.to validate_presence_of :token }
    # it { is_expected.to validate_uniqueness_of(:token).scoped_to :user }
  end

  describe 'permissions' do
    subject { Ability.new user }

    context 'own_device' do
      let(:device) { build :device, user: user }
      it { is_expected.to be_able_to :manage, device }
    end

    context 'foreign_device' do
      let(:user_2) { build_stubbed :user }
      let(:device) { build :device, user: user_2 }
      it { is_expected.to_not be_able_to :manage, device }
    end

    context 'guest' do
      subject { Ability.new nil }
      let(:device) { build :device, user: user }
      it { is_expected.to_not be_able_to :manage, device }
    end
  end
end
