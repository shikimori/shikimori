describe IncompleteDate do
  let(:date) { described_class.new day: day, month: month, year: year }

  let(:day) { 8 }
  let(:month) { 9 }
  let(:year) { 1972 }

  describe '#human' do
    subject do
      I18n.with_locale(locale) { date.human is_short_month }
    end
    let(:is_short_month) { false }

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

        context 'is_short_month' do
          let(:is_short_month) { true }
          it { is_expected.to eq '8 сент. 1972' }
        end
      end

      context 'en' do
        let(:locale) { :en }
        it { is_expected.to eq 'September 8, 1972' }

        context 'is_short_month' do
          let(:is_short_month) { true }
          it { is_expected.to eq 'Sep 8, 1972' }
        end
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

  describe '#blank?, #present?, #uncertain?, #presence' do
    subject { IncompleteDate.new year: year, month: month, day: day }
    let(:year) { 1992 }
    let(:month) { 10 }
    let(:day) { 21 }

    context 'has date' do
      its(:blank?) { is_expected.to eq false }
      its(:present?) { is_expected.to eq true }
      its(:presence) { is_expected.to eq subject }
      its(:uncertain?) { is_expected.to eq false }
    end

    context 'no year' do
      let(:year) { nil }

      its(:blank?) { is_expected.to eq false }
      its(:present?) { is_expected.to eq true }
      its(:presence) { is_expected.to eq subject }
      its(:uncertain?) { is_expected.to eq true }
    end

    context 'no month' do
      let(:month) { nil }

      its(:blank?) { is_expected.to eq false }
      its(:present?) { is_expected.to eq true }
      its(:presence) { is_expected.to eq subject }
      its(:uncertain?) { is_expected.to eq true }
    end

    context 'no day' do
      let(:day) { nil }

      its(:blank?) { is_expected.to eq false }
      its(:present?) { is_expected.to eq true }
      its(:presence) { is_expected.to eq subject }
      its(:uncertain?) { is_expected.to eq true }
    end

    context 'nothing' do
      let(:year) { nil }
      let(:month) { nil }
      let(:day) { nil }

      its(:blank?) { is_expected.to eq true }
      its(:present?) { is_expected.to eq false }
      its(:presence) { is_expected.to eq nil }
      its(:uncertain?) { is_expected.to eq true }
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

      it { is_expected.to be_nil }
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
        it { expect(object > date).to eq false }
        it { expect(object < date).to eq true }
      end

      context 'date less than object' do
        let(:string) { '1992-08-24 15:00' }

        it { expect(date).to_not eq object }
        it { expect(object).to_not eq date }
        it { expect(date < object).to eq true }
        it { expect(date > object).to eq false }
        it { expect(object > date).to eq true }
        it { expect(object < date).to eq false }
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

    context 'incomplete date' do
      let(:object) { IncompleteDate.new year: 1992, month: 8, day: 25 }
      it { is_expected.to eq IncompleteDate.new(year: 1992, month: 8, day: 25) }
    end
  end
end
