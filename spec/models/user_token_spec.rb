describe UserToken do
  describe 'relations' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should validate_presence_of :user }
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'owner' do
      let(:user_token) { build_stubbed :user_token, user: user }
      it { should be_able_to :manage, user_token }
    end

    context 'guest' do
      let(:user_token) { build_stubbed :user_token }
      let(:user) { nil }
      it { should_not be_able_to :manage, user_token }
    end

    context 'user' do
      let(:user_token) { build_stubbed :user_token }
      let(:user) { nil }
      it { should_not be_able_to :manage, user_token }
    end
  end
end
