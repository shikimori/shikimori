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
      rule: {
        threshold: 15
      }
    )
  end
  let(:neko_id) { Types::Achievement::NekoId[:test] }

  describe '#title' do
    it { expect(rule.title).to eq rule.title_ru }
  end

  describe '#text' do
    it { expect(rule.text).to eq rule.text_ru }
  end

  describe '#hint' do
    context 'test' do
      let(:neko_id) { Types::Achievement::NekoId[:test] }
      it { expect(rule.hint).to eq 'Неизвестная ачивка 1 уровня' }
    end

    context 'animelist' do
      let(:neko_id) { Types::Achievement::NekoId[:animelist] }
      it { expect(rule.hint).to eq '15 просмотренных аниме' }
    end

    %i[ru en].each do |locale|
      context locale do
        include_context :stub_locale, locale

        Types::Achievement::NekoId.values.to_a.each do |neko_id_spec|
          context neko_id_spec do
            let(:neko_id) { neko_id_spec }
            it do
              expect(rule.hint).to be_present
              expect(rule.hint).to eq rule.hint
            end
          end
        end
      end
    end
  end
end
