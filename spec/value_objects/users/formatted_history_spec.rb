describe Users::FormattedHistory do
  let(:entry) do
    Users::FormattedHistory.new(
      name: name,
      russian: russian,
      image: '',
      image_2x: '',
      action: action,
      created_at: created_at,
      url: '',
      action_info: action_info
    )
  end
  let(:name) { 'test' }
  let(:russian) { nil }
  let(:action) { '' }
  let(:created_at) { Time.zone.now }
  let(:action_info) { nil }

  describe '#localized_name' do
    context 'with russian' do
      let(:russian) { 'тест' }
      it { expect(entry.localized_name).to eq "<span class='name-en'>test</span><span class='name-ru'>тест</span>" }
    end

    context 'without russian' do
      it { expect(entry.localized_name).to eq 'test' }
    end
  end

  describe '#reversed_action' do
    let(:action) { 'Смотрю 1й эпизод, Просмотрено' }
    it { expect(entry.reversed_action).to eq 'Просмотрено, Смотрю 1й эпизод' }
  end

  describe '#special?' do
    context 'with action_info' do
      let(:action_info) { 'test' }
      it { expect(entry).to be_special }
    end

    context 'without action_info' do
      it { expect(entry).to_not be_special }
    end
  end

  describe '#localized_date' do
    let(:created_at) { Time.zone.parse('2001-01-01 01:01') }
    it { expect(entry.localized_date).to eq '1 января 2001' }
  end
end
