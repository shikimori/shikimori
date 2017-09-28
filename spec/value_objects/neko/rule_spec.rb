describe Neko::Rule do
  let(:rule) do
    Neko::Rule.new(
      neko_id: Types::Achievement::NekoId[:test],
      level: 1,
      image: '',
      border: nil,
      title_ru: 'zxc',
      text_ru: 'vbn'
    )
  end

  describe '#title' do
    it { expect(rule.title).to eq rule.title_ru }
  end

  describe '#text' do
    it { expect(rule.text).to eq rule.text_ru }
  end
end
