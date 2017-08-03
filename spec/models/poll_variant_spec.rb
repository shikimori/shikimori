describe PollVariant do
  describe 'relations' do
    it { is_expected.to belong_to :poll }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :text }
  end
end
