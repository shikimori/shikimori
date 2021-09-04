describe BanDuration do
  describe 'to_s' do
    subject { BanDuration.new(duration).to_s }

    describe 'nothing' do
      let(:duration) { 0 }
      it { is_expected.to eq '0m' }
    end

    describe 'minutes' do
      let(:duration) { 30 }
      it { is_expected.to eq '30m' }
    end

    describe 'hours' do
      let(:duration) { 60 * 2 }
      it { is_expected.to eq '2h' }
    end

    describe 'days' do
      let(:duration) { 60 * 24 * 3 }
      it { is_expected.to eq '3d' }
    end

    describe 'weeks' do
      let(:duration) { 60 * 24 * 7 * 2 }
      it { is_expected.to eq '2w' }
    end

    describe 'months' do
      let(:duration) { 60 * 24 * 60 }
      it { is_expected.to eq '2M' }
    end

    describe 'years' do
      let(:duration) { 365 * 60 * 24 * 2 }
      it { is_expected.to eq '2y' }
    end

    describe 'mixed' do
      let(:duration) { 60 * 24 * 365 * 7 + 60 * 24 * 7 * 8 + 60 * 24 * 3 + 60 * 4 + 15 }
      it { is_expected.to eq '7y 1M 4w 1d 4h 15m' }
    end
  end

  describe 'to_i' do
    subject { BanDuration.new(duration).to_i }

    describe 'minutes' do
      let(:duration) { '30m' }
      it { is_expected.to eq 30 }
    end

    describe 'hours' do
      let(:duration) { '1.5h' }
      it { is_expected.to eq 60 * 1.5 }
    end

    describe 'days' do
      let(:duration) { '40d' }
      it { is_expected.to eq 60 * 24 * 40 }
    end

    describe 'weeks' do
      let(:duration) { '3w' }
      it { is_expected.to eq 60 * 24 * 7 * 3 }
    end

    describe 'months' do
      let(:duration) { '3M' }
      it { is_expected.to eq 60 * 24 * 30 * 3 }
    end

    describe 'years' do
      let(:duration) { '9y' }
      it { is_expected.to eq 60 * 24 * 365 * 9 }
    end

    describe 'mixed' do
      let(:duration) { '7y 2M 3w 2h 5d 1m' }
      it do
        is_expected.to eq(
          60 * 24 * 365 * 7 +
            60 * 24 * 30 * 2 +
            60 * 24 * 7 * 3 +
            60 * 24 * 5 +
            60 * 2 + 1
        )
      end
    end
  end

  describe 'humanize' do
    subject { BanDuration.new(duration).humanize }

    describe 'minutes' do
      let(:duration) { '33m' }
      it { is_expected.to eq '33 минуты' }
    end

    describe 'hours' do
      let(:duration) { '1.5h' }
      it { is_expected.to eq '1 час 30 минут' }
    end

    describe 'days' do
      let(:duration) { '6d' }
      it { is_expected.to eq '6 дней' }
    end

    describe 'weeks' do
      let(:duration) { '3w' }
      it { is_expected.to eq '3 недели' }
    end

    describe 'years' do
      let(:duration) { '9y' }
      it { is_expected.to eq '9 лет' }
    end

    describe 'mixed' do
      let(:duration) { '3w 2h 5d 1m' }
      it { is_expected.to eq '3 недели 5 дней' }
    end

    describe 'mixed_with_zero' do
      let(:duration) { '3w 5h 1m' }
      it { is_expected.to eq '3 недели' }
    end
  end
end
