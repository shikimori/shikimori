describe IncompleteDate do
  let(:date) { IncompleteDate.new day: day, month: month, year: year }
  let(:day) { 8 }
  let(:month) { 9 }
  let(:year) { 1972 }

  describe '#human' do
    subject { date.human }

    context 'no date' do
      let(:day) { nil }
      let(:month) { nil }
      let(:year) { nil }
      it { is_expected.to eq nil }
    end

    context 'full date' do
      it { is_expected.to eq '8 сентября 1972' }
    end

    context 'no year' do
      let(:year) { nil }
      it { is_expected.to eq '8 сентября' }
    end

    context 'no month' do
      let(:month) { nil }
      it { is_expected.to eq '1972' }
    end

    context 'no day' do
      let(:day) { nil }
      it { is_expected.to eq 'Сентябрь 1972' }
    end
  end
end
