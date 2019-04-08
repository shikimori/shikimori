describe UserRateLog do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:target).optional }
    it { is_expected.to belong_to(:oauth_application).optional }
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
  end

  describe 'instance methods' do
    describe '#action' do
      let(:user_rate_log) { build :user_rate_log, diff: diff }
      subject { user_rate_log.action }

      context 'create' do
        let(:diff) { { 'id': [nil, 48181226] } }
        it { is_expected.to eq :create }
      end

      context 'update' do
        let(:diff) { { 'score': [1, 2] } }
        it { is_expected.to eq :update }
      end

      context 'destroy' do
        let(:diff) { { 'id': [48181226, nil] } }
        it { is_expected.to eq :destroy }
      end
    end
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:user) { build_stubbed :user, roles: [role] }
    let(:role) { Types::User::Roles.values }
    let(:user_rate_log) { build :user_rate_log }
    it { is_expected.to be_able_to :read, user_rate_log }
  end
end
