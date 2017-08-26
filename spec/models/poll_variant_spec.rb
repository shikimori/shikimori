describe PollVariant do
  describe 'relations' do
    it { is_expected.to belong_to :poll }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :label }
  end

  describe 'instance methods' do
  end
end
