describe Collection do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :locale }
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'owner' do
      let(:collection) { build_stubbed :collection, user: user }
      it { is_expected.to be_able_to :manage, collection }
    end

    context 'guest' do
      let(:collection) { build_stubbed :collection }
      let(:user) { nil }
      it { is_expected.to_not be_able_to :manage, collection }
    end

    context 'user' do
      let(:collection) { build_stubbed :collection }
      let(:user) { nil }
      it { is_expected.to_not be_able_to :manage, collection }
    end
  end
end
