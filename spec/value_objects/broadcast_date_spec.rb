describe BroadcastDate do
  include_context :timecop, '06-04-2016'

  describe '.parse' do
    subject { BroadcastDate.parse schedule, start_on }
    let(:start_on) { Date.parse '06-04-2016' }

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

      context 'start_on now' do
        it { is_expected.to eq Time.zone.parse('07-04-2016 16:00') }
      end

      context 'start_on in future' do
        let(:start_on) { Date.parse '13-04-2016' }
        it { is_expected.to eq Time.zone.parse('14-04-2016 16:00') }
      end

      context 'start_on in past' do
        let(:start_on) { Date.parse '13-03-2016' }
        it { is_expected.to eq Time.zone.parse('07-04-2016 16:00') }
      end
    end
  end
end
