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

    describe '#label' do
      let(:external_link) { build :external_link, kind, url: url }
      subject { external_link.label }

      context 'not wikipedia' do
        let(:kind) { :official_site }
        let(:url) { 'zzz' }
        it { is_expected.to eq external_link.kind_text }
      end

      context 'wikipedia' do
        let(:kind) { :wikipedia }

        context 'ru' do
          let(:url) { 'https://ru.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq 'Википедия' }
        end

        context 'en' do
          let(:url) { 'https://en.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq 'Wikipedia' }
        end

        context 'ja' do
          let(:url) { 'https://ja.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq 'ウィキペディア' }
        end

        context 'zh' do
          let(:url) { 'https://zh.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq '维基百科' }
        end

        context 'other variants' do
          let(:url) { 'https://ru.wikipedia.org/wiki/Tsuki_ga_Kirei' }
          it { is_expected.to eq external_link.kind_text }
        end
      end
    end
  end
end
