describe UserRateLog do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :target }
    it { is_expected.to belong_to :oauth_application }
    it { is_expected.to belong_to :anime }
    it { is_expected.to belong_to :manga }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :ip }
    it { is_expected.to validate_presence_of :user_agent }
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
end
