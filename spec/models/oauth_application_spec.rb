describe OauthApplication do
  describe 'relations' do
    it { is_expected.to belong_to :owner }
    it { is_expected.to have_many(:user_rates_logs).dependent(:destroy) }
  end

  describe 'permissions' do
    let(:oauth_application) do
      build_stubbed :oauth_application,
        owner: oauth_application_user
    end
    let(:user) { build_stubbed :user }

    subject { Ability.new user }

    context 'oauth_application owner' do
      let(:oauth_application_user) { user }

      context 'day_registered' do
        let(:user) { build_stubbed :user, :day_registered }
        it { is_expected.to be_able_to :manage, oauth_application }
      end

      context 'not day_registered' do
        it { is_expected.to_not be_able_to :manage, oauth_application }
      end
    end

    context 'not import owner' do
      let(:oauth_application_user) { build_stubbed :user }
      it { is_expected.to_not be_able_to :manage, oauth_application }
      it { is_expected.to be_able_to :read, oauth_application }
    end

    context 'guest' do
      let(:oauth_application_user) { build_stubbed :user }
      let(:user) { nil }
      it { is_expected.to_not be_able_to :manage, oauth_application }
      it { is_expected.to be_able_to :read, oauth_application }
    end
  end
end
