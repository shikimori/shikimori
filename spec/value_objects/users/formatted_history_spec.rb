describe Users::FormattedHistory do
  let(:entry) { Users::FormattedHistory.new params }

  describe '#localized_name' do
    context 'with russian' do
      let(:params) {{ name: 'test', russian: 'тест' }}
      it { expect(entry.localized_name).to eq "<span class='name-en'>test</span><span class='name-ru' data-text='тест'></span>" }
    end

    context 'without russian' do
      let(:params) {{ name: 'test' }}
      it { expect(entry.localized_name).to eq 'test' }
    end
  end

  describe '#reversed_action' do
    let(:params) {{ action: 'Смотрю 1й эпизод, Просмотрено' }}
    it { expect(entry.reversed_action).to eq 'Просмотрено, Смотрю 1й эпизод' }
  end

  describe '#special?' do
    context 'with action_info' do
      let(:params) {{ action_info: 'test' }}
      it { expect(entry).to be_special }
    end

    context 'without action_info' do
      let(:params) {{ action_info: nil }}
      it { expect(entry).to_not be_special }
    end
  end

  describe '#iso_date' do
    let(:params) {{ created_at: Time.zone.parse('2001-01-01 01:01') }}
    it { expect(entry.iso_date).to eq '2001-01-01T01:01:00+03:00' }
  end

  describe '#localized_date' do
    let(:params) {{ created_at: Time.zone.parse('2001-01-01 01:01') }}
    it { expect(entry.localized_date).to eq '1 января 2001' }
  end
end
