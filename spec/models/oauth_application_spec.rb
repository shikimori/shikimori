describe OauthApplication do
  describe 'relations' do
    it { is_expected.to belong_to :owner }
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
      it { is_expected.to be_able_to :manage, oauth_application }
    end

    context 'not import owner' do
      let(:oauth_application_user) { build_stubbed :user }
      it { is_expected.to_not be_able_to :manage, oauth_application }
    end
  end
end
