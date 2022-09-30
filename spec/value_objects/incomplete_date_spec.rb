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

  describe 'comparison logic' do
    context 'date vs incomplete_date' do
      let(:date) { [Date, DateTime, Time.zone].sample.parse string }
      let(:object) { IncompleteDate.new year: 1992, month: 8, day: 25 }

      context 'date equal to object' do
        let(:string) { '1992-08-25 15:00' }

        it { expect(date).to eq object }
        it { expect(object).to eq date }
      end

      context 'date greater than object' do
        let(:string) { '1992-08-26 15:00' }

        it { expect(date).to_not eq object }
        it { expect(object).to_not eq date }
        it { expect(date > object).to eq true }
        it { expect(date < object).to eq false }
      end

      context 'date less than object' do
        let(:string) { '1992-08-24 15:00' }

        it { expect(date).to_not eq object }
        it { expect(object).to_not eq date }
        it { expect(date < object).to eq true }
        it { expect(date > object).to eq false }
      end
    end

    context 'incomplete_date vs incomplete_date' do
      let(:object) { IncompleteDate.new(year: 1992, month: 8, day: 25) }
      it { expect(object).to eq IncompleteDate.new(year: 1992, month: 8, day: 25) }
    end
  end

  describe '.new' do
    subject { described_class.new object }

    context 'string' do
      context 'has date' do
        let(:object) { '1992-08-25' }
        it { is_expected.to eq IncompleteDate.new(year: 1992, month: 8, day: 25) }
      end

      context 'no date' do
        let(:object) { ['', nil].sample }
        it { is_expected.to eq IncompleteDate.new }
      end
    end

    context 'hash' do
      let(:object) { { 'year' => 1992, 'month' => 8, 'day' => 25 } }
      it { is_expected.to eq IncompleteDate.new(year: 1992, month: 8, day: 25) }
    end

    context 'date' do
      let(:object) { [Date, DateTime, Time.zone].sample.parse '1992-08-25 15:00' }
      it { is_expected.to eq IncompleteDate.new(year: 1992, month: 8, day: 25) }
    end
  end
end
