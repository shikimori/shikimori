describe String do
  subject { 'тЕст' }

  its(:capitalize) { is_expected.to eq 'Тест' }
  # its(:upcase) { is_expected.to eq 'ТЕСТ' }
  its(:downcase) { is_expected.to eq 'тест' }

  describe '#first_downcase' do
    let(:string) { 'Реклама ВКонтакте' }
    it { expect(string.first_downcase).to eq 'реклама ВКонтакте' }
  end

  describe '#first_upcase' do
    let(:string) { 'реклама ВКонтакте' }
    it { expect(string.first_upcase).to eq 'Реклама ВКонтакте' }
  end

  describe '#to_underscore' do
    subject { name.to_underscore }

    context 'camelized' do
      let(:name) { 'ZxcVbn' }
      it { is_expected.to eq 'zxc_vbn' }
    end

    context 'downcased' do
      let(:name) { 'zxc' }
      it { is_expected.to eq 'zxc' }
    end
  end
end
