describe ClubPage do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :parent }
    it { is_expected.to have_many(:children).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :club }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :text }
  end
end
