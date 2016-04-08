describe Schedule do
  before { Timecop.freeze '06-04-2016' }
  after { Timecop.return }

  describe '.parse' do
    subject { Schedule.parse schedule }

    context 'nil' do
      let(:schedule) { nil }
      it { is_expected.to be_nil }
    end

    context 'blank' do
      let(:schedule) { '' }
      it { is_expected.to be_nil }
    end

    context 'matched' do
      let(:schedule) { 'Thursdays at 22:00 (JST)' }
      it { is_expected.to eq Time.zone.parse('07-04-2016 16:00') }
    end
  end
end
