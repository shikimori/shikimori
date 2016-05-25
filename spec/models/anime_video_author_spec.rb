describe AnimeVideoAuthor do
  describe 'relations' do
    it { is_expected.to have_many :anime_videos }
    it { is_expected.to validate_presence_of :name }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }
  end
end
