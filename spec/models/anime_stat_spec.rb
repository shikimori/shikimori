describe AnimeStat do
  describe 'associations' do
    it { is_expected.to belong_to :entry }
  end

  describe 'validations' do
    # it { is_expected.to validate_presence_of :entry }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:entry_type).in(*Types::AnimeStat::EntryType.values) }
  end
end
