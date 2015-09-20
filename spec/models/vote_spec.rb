describe Vote do
  describe 'relations' do
    it { should belong_to :user }
    it { should belong_to :voteable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :voteable }
  end
end
