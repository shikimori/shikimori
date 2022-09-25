describe IncompleteDate do
  let(:date) { described_class.new day: day, month: month, year: year }

  let(:day) { 8 }
  let(:month) { 9 }
  let(:year) { 1972 }

  describe '#human' do
    subject do
      I18n.with_locale(locale) { date.human }
    end

    context 'no date' do
      let(:day) { nil }
      let(:month) { nil }
      let(:year) { nil }
      let(:locale) { %i[ru en].sample }

      it { is_expected.to eq nil }
      it { expect(date).to be_blank }
    end

    context 'full date' do
      context 'ru' do
        let(:locale) { :ru }
        it { is_expected.to eq '8 сентября 1972' }
      end

      context 'en' do
        let(:locale) { :en }
        it { is_expected.to eq 'September 8, 1972' }
      end
    end

    context 'no year' do
      let(:year) { nil }

      context 'ru' do
        let(:locale) { :ru }
        it { is_expected.to eq '8 сентября' }
      end

      context 'en' do
        let(:locale) { :en }
        it { is_expected.to eq 'September 8' }
      end
    end

    context 'no month' do
      let(:month) { nil }
      let(:locale) { %i[ru en].sample }
      it { is_expected.to eq '1972' }
    end

    context 'no day' do
      let(:day) { nil }

      context 'ru' do
        let(:locale) { :ru }
        it { is_expected.to eq 'Сентябрь 1972' }
      end

      context 'en' do
        let(:locale) { :en }
        it { is_expected.to eq 'September 1972' }
      end
    end
  end

  describe '#date' do
    subject { date.date }

    context 'has date' do
      it { is_expected.to eq Date.new(year, month, day) }
    end

    context 'no date' do
      let(:day) { nil }
      let(:month) { nil }
      let(:year) { nil }

      it { is_expected.to eq Date.new(1901, 1, 1) }
    end
  end

  describe '.from_string' do
    subject { described_class.from_string string }

    context 'has date' do
      let(:string) { '1992-08-25' }
      it { is_expected.to eq IncompleteDate.new(year: 1992, month: 8, day: 25) }
    end

    context 'no date' do
      let(:string) { '' }
      it { is_expected.to eq IncompleteDate.new }
    end
  end
end
