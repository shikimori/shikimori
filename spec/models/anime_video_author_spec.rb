describe AnimeVideoAuthor do
  describe 'relations' do
    it { is_expected.to have_many :anime_videos }
    it { is_expected.to validate_presence_of :name }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }
  end

  describe 'instance methods' do
    describe '#name=' do
      let(:author) { build :anime_video_author, name: 'z' * 300 }
      it { expect(author.name).to eq 'z' * 255 }
    end
  end
end
