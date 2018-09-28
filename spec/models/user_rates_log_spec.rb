describe UserRatesLog do
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
end
