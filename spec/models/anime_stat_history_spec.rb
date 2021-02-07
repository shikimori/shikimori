describe AnimeStatHistory do
  describe 'associations' do
    it { is_expected.to belong_to :entry }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:entry_type).in(*Types::AnimeStat::EntryType.values) }
  end
end
