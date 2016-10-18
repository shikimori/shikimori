describe Style do
  describe 'relations' do
    it { is_expected.to belong_to :owner }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :owner }
    it { is_expected.to validate_presence_of :css }
  end
end
