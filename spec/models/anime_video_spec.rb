describe AnimeVideo do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
    it { is_expected.to have_many(:reports).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to validate_presence_of :source }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_numericality_of(:episode).is_greater_than_or_equal_to(0) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :raw, :subtitles, :fandub, :unknown }
    it { is_expected.to enumerize(:language).in :russian, :english, :original, :unknown }
    it { is_expected.to enumerize(:quality).in :bd, :web, :tv, :dvd, :unknown }
  end

  describe 'instance methods' do
    describe '#hosting' do
      let(:anime_video) { build :anime_video }
      before { anime_video[:url] = url }
      subject! { anime_video.hosting }

      let(:url) { 'http://www.vk.com?id=1' }
      it { is_expected.to eq 'vk.com' }
    end
  end
end
