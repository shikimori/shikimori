describe Collection do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :locale }
  end
end
