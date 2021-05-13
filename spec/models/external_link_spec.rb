describe ExternalLink do
  describe 'associations' do
    it { is_expected.to belong_to :entry }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :entry }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_presence_of :source }
    it { is_expected.to validate_presence_of :url }

    # describe 'checksum' do
    #   let(:anime) { create :anime }
    #   subject { build :external_link, entry: anime }
    #   it { is_expected.to validate_uniqueness_of :checksum }
    # end
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::ExternalLink::Kind.values) }
    it { is_expected.to enumerize(:source).in(*Types::ExternalLink::Source.values) }
  end

  describe 'callbacks' do
    describe '#compute_checksum' do
      let(:anime) { create :anime, id: 1 }
      let(:external_link) { create :external_link, entry: anime }
      it { expect(external_link.checksum).to eq '85050d13de8bb1bb9083fbb810a0e338' }
    end
  end
  describe 'instance methods' do
    describe '#url=' do
      let(:external_link) { build :external_link, url: 'zzz' }
      it { expect(external_link.url).to eq 'http://zzz' }
    end

    describe '#visible?' do
      let(:external_link) { build :external_link, kind: kind }

      context 'visible' do
        let(:kind) do
          (
            Types::ExternalLink::Kind.values - Types::ExternalLink::INVISIBLE_KINDS
          ).sample
        end
        it { expect(external_link).to be_visible }
      end

      context 'invisible' do
        let(:kind) { Types::ExternalLink::INVISIBLE_KINDS.sample }
        it { expect(external_link).to_not be_visible }
      end
    end

    describe '#disabled?' do
      let(:external_link) { build :external_link, url: url }
      let(:url) { 'https://ya.ru' }

      it { expect(external_link).to_not be_disabled }

      context 'NONE url' do
        let(:url) { ['http://NONE', 'https://NONE', 'NONE'].sample }
        it { expect(external_link).to be_disabled }
      end
    end

    describe '#watch_online?' do
      let(:external_link) { build :external_link, kind }
      let(:kind) { Types::ExternalLink::Kind[:wikipedia] }

      it { expect(external_link).to_not be_watch_online }

      context 'watch online kind' do
        let(:kind) { Types::ExternalLink::Kind[:crunchyroll] }
        it { expect(external_link).to be_watch_online }
      end
    end

    describe '#read_online?' do
      let(:external_link) { build :external_link, kind }
      let(:kind) { Types::ExternalLink::Kind[:wikipedia] }

      it { expect(external_link).to_not be_read_online }

      context 'read online kind' do
        let(:kind) { Types::ExternalLink::Kind[:remanga] }
        it { expect(external_link).to be_read_online }
      end
    end

    describe '#label, #icon_kind' do
      subject(:external_link) { build :external_link, kind, url: url }

      context 'not wikipedia' do
        let(:kind) { :official_site }
        let(:url) { 'zzz' }
        its(:label) { is_expected.to eq external_link.kind_text }
      end

      context 'wikipedia' do
        let(:kind) { :wikipedia }

        context 'ru' do
          let(:url) { 'https://ru.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          its(:label) { is_expected.to eq 'Википедия' }
          its(:icon_kind) { is_expected.to eq 'wikipedia' }
        end

        context 'en' do
          let(:url) { 'https://en.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          its(:label) { is_expected.to eq 'Wikipedia' }
          its(:icon_kind) { is_expected.to eq 'wikipedia' }
        end

        context 'ja' do
          let(:url) { 'https://ja.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          its(:label) { is_expected.to eq 'ウィキペディア' }
          its(:icon_kind) { is_expected.to eq 'wikipedia' }
        end

        context 'zh' do
          let(:url) { 'https://zh.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          its(:label) { is_expected.to eq '维基百科' }
          its(:icon_kind) { is_expected.to eq 'wikipedia' }
        end

        context 'ko' do
          let(:url) { 'https://ko.wikipedia.org/wiki/플라워링_하트' }
          its(:label) { is_expected.to eq '위키백과' }
          its(:icon_kind) { is_expected.to eq 'wikipedia' }
        end

        context 'baike.baidu.com' do
          let(:url) { 'https://baike.baidu.com/item/%E6%A2%A6%E5%A1%94%C2%B7%E9%9B%AA%E8%B0%9C%E5%9F%8E/22343890' }
          its(:label) { is_expected.to eq 'Wiki Baidu' }
          its(:icon_kind) { is_expected.to eq 'baike_baidu_wiki' }
        end

        context 'namu.wiki' do
          let(:url) { 'https://namu.wiki/w/%EB%82%98%EB%AC%B4%EC%9C%84%ED%82%A4:%EB%8C%80%EB%AC%B8' }
          its(:label) { is_expected.to eq 'Wiki Namu' }
          its(:icon_kind) { is_expected.to eq 'namu_wiki' }
        end

        context 'other variants' do
          let(:url) { 'https://ru.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          its(:label) { is_expected.to eq external_link.kind_text }
          its(:icon_kind) { is_expected.to eq 'wikipedia' }
        end
      end
    end
  end
end
