describe Forum do
  describe 'relations' do
    it { is_expected.to have_many :topics }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :permalink }
  end
end
