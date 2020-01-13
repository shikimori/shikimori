describe AnimeVideoAuthor do
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

  describe 'class methods' do
    describe '.fix_name' do
      let(:name) { 'z' * 300 }
      it { expect(AnimeVideoAuthor.fix_name name).to eq 'z' * 255 }
    end
  end
end
