describe AnimeVideo do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
    it { is_expected.to have_many(:reports).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :anime }
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

    describe '#vk?, #smotret_anime?' do
      let(:video) { build :anime_video, url: url }

      context 'vk' do
        let(:url) { attributes_for(:anime_video)[:url] }
        it { expect(video).to be_vk }
        it { expect(video).to_not be_smotret_anime }
      end

      context 'smotret_anime' do
        let(:url) { 'http://smotretanime.ru/translations/embed/960633' }
        it { expect(video).to_not be_vk }
        it { expect(video).to be_smotret_anime }
      end
    end

    describe '#allowed?' do
      context 'true' do
        %w[working uploaded].each do |state|
          it { expect(build(:anime_video, state: state).allowed?).to eq true }
        end
      end

      context 'false' do
        %w[broken wrong banned_hosting].each do |state|
          it { expect(build(:anime_video, state: state).allowed?).to eq false }
        end
      end
    end
  end
end
