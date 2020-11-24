describe Neko::Rule do
  let(:rule) do
    Neko::Rule.new(
      neko_id: neko_id,
      level: 1,
      image: '',
      border_color: nil,
      title_ru: 'zxc',
      text_ru: 'vbn',
      title_en: nil,
      text_en: nil,
      topic_id: nil,
      rule: {
        threshold: 15,
        filters: filters
      }
    )
  end
  let(:neko_id) { Types::Achievement::NekoId[:test] }
  let(:filters) { {} }

  describe '#group' do
    it { expect(rule.group).to eq Types::Achievement::NekoGroup[:common] }
  end

  describe '#common?, #genre?, #franchise?' do
    context 'common' do
      let(:neko_id) { 'animelist' }
      it { expect(rule).to be_common }
      it { expect(rule).to_not be_genre }
      it { expect(rule).to_not be_franchise }
    end

    context 'genre' do
      let(:neko_id) { 'scifi' }
      it { expect(rule).to_not be_common }
      it { expect(rule).to be_genre }
      it { expect(rule).to_not be_franchise }
    end

    context 'franchise' do
      let(:neko_id) { 'ghost_in_the_shell' }
      it { expect(rule).to_not be_common }
      it { expect(rule).to_not be_genre }
      it { expect(rule).to be_franchise }
    end
  end

  describe '#group_name' do
    it { expect(rule.group_name).to eq 'Общие' }
  end

  describe '#title' do
    subject { rule.title user, is_ru_host }
    before { allow(I18n).to receive(:locale).and_return locale }
    let(:user) { nil }

    context 'ru_host' do
      let(:is_ru_host) { true }
      let(:locale) { :ru }
      it { is_expected.to eq rule.title_ru }
    end

    context 'not ru_host' do
      let(:is_ru_host) { false }
      let(:locale) { :en }
      it { is_expected.to eq Neko::Rule::NO_RULE.title(user, is_ru_host) }
    end
  end

  describe '#text' do
    subject { rule.text is_ru_host }
    before { allow(I18n).to receive(:locale).and_return locale }
    let(:user) { nil }

    context 'ru_host' do
      let(:is_ru_host) { true }
      let(:locale) { :ru }
      it { is_expected.to eq rule.text_ru }
    end

    context 'not ru_host' do
      let(:is_ru_host) { false }
      let(:locale) { :en }
      it { is_expected.to eq Neko::Rule::NO_RULE.text(is_ru_host) }
    end
  end

  describe '#neko_name' do
    it { expect(rule.neko_name).to eq 'Неизвестная ачивка' }
  end

  describe '#progress' do
    it { expect(rule.progress).to eq 0 }
  end

  describe '#hint' do
    context 'test' do
      let(:neko_id) { Types::Achievement::NekoId[:test] }
      it { expect(rule.hint nil, true).to eq 'Неизвестная ачивка 1 уровня' }
    end

    context 'animelist' do
      let(:neko_id) { Types::Achievement::NekoId[:animelist] }
      it { expect(rule.hint nil, true).to eq '15 просмотренных аниме' }
    end

    %i[ru en].each do |locale|
      context locale do
        include_context :stub_locale, locale

        Types::Achievement::NekoId.values.to_a.each do |neko_id_spec|
          context neko_id_spec do
            let(:neko_id) { neko_id_spec }
            it do
              expect(rule.hint nil, true).to be_present
              expect(rule.hint nil, true).to eq rule.hint(nil, true)
            end
          end
        end
      end
    end
  end

  describe '#sort_criteria' do
    it do
      expect(rule.sort_criteria).to eq [
        Types::Achievement::ORDERED_NEKO_IDS.index(rule.neko_id),
        rule.level
      ]
    end
  end

  describe '#animes_count' do
    let(:genre) { create :genre }
    let!(:anime) { create :anime, genre_ids: [genre.id] }

    context 'no filters' do
      it { expect(rule.animes_count).to be_nil }
    end

    # context 'anime_ids' do
    #   let(:filters) { { 'anime_ids' => [0, 1, 2] } }
    #   it { expect(rule.animes_count).to eq 3 }
    # end

    context 'genre_ids' do
      let(:filters) { { 'genre_ids' => [genre.id] } }
      it { expect(rule.animes_count).to eq 1 }
    end
  end

  describe '#statistics' do
    before do
      allow(Achievements::Statistics).to receive(:call).and_return statistics
    end
    let(:statistics) { :zzz }

    it do
      expect(rule.statistics).to eq statistics
      expect(Achievements::Statistics)
        .to have_received(:call)
        .with rule.neko_id, rule.level
    end
  end
end
