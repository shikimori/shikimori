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

  describe 'state_machine' do
    subject(:video) { create :anime_video }

    context 'initial' do
      it { is_expected.to be_working }
    end

    context 'broken' do
      before { video.broken }
      it { is_expected.to be_broken }
    end

    context 'wrong' do
      before { video.wrong }
      it { is_expected.to be_wrong }
    end

    context 'ban' do
      before { video.ban }
      it { is_expected.to be_banned_hosting }
    end
  end

  describe 'instance methods' do
    describe '#url=' do
      let(:video) { build :anime_video, url: url }

      describe 'new record' do
        context 'normal url' do
          let(:url) { 'http://vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16&hd=2' }
          it { expect(video.url).to eq 'http://vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16' }
        end

        context 'url w/o http' do
          let(:url) { 'vk.com/video_ext.php?oid=-49842926&id=171419019&hash=5ca0a0daa459cd16' }
          it { expect(video.url).to eq "http://#{url}" }
        end
      end

      describe 'persisted video', :vcr do
        let(:video) { build_stubbed :anime_video, url: url }
        let(:url) { 'http://rutube.ru/video/ef370e68cd9687a30ea67a68658c6ef8/?ref=logo' }
        before { video.url = new_url }

        describe 'indirect url' do
          let(:new_url) { '<iframe width="720" height="405" src="//rutube.ru/play/embed/3599097" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>' }
          it { expect(video.url).to eq 'http://rutube.ru/play/embed/ef370e68cd9687a30ea67a68658c6ef8' }
        end

        describe 'direct url' do
          let(:new_url) { 'http://rutube.ru/play/embed/3599097' }
          it { expect(video.url).to eq 'http://rutube.ru/play/embed/ef370e68cd9687a30ea67a68658c6ef8' }
        end
      end
    end

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
