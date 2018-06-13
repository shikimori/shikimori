describe Neko::Stats do
  describe '#interval' do
    let(:statistics) { Neko::Stats.new interval_0: 1, interval_2: 9 }
    it { expect(statistics.interval(0)).to eq 1 }
    it { expect(statistics.interval(1)).to eq 0 }
    it { expect(statistics.interval(2)).to eq 9 }
  end

  describe '#increment' do
    let(:statistics) { Neko::Stats.new }
    subject! { statistics.increment! user_rates_count }

    context do
      let(:user_rates_count) { 0 }
      it do
        expect(statistics).to have_attributes(
          interval_0: 1,
          interval_1: 0,
          interval_2: 0,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 0
        )
      end
    end

    context do
      let(:user_rates_count) { 1 }
      it do
        expect(statistics).to have_attributes(
          interval_0: 1,
          interval_1: 0,
          interval_2: 0,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 0
        )
      end
    end

    context do
      let(:user_rates_count) { Neko::Stats::INTERVALS[0] - 1 }
      it do
        expect(statistics).to have_attributes(
          interval_0: 1,
          interval_1: 0,
          interval_2: 0,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 0
        )
      end
    end

    context do
      let(:user_rates_count) { Neko::Stats::INTERVALS[0] }
      it do
        expect(statistics).to have_attributes(
          interval_0: 1,
          interval_1: 0,
          interval_2: 0,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 0
        )
      end
    end

    context do
      let(:user_rates_count) { Neko::Stats::INTERVALS[0] + 1 }
      it do
        expect(statistics).to have_attributes(
          interval_0: 0,
          interval_1: 1,
          interval_2: 0,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 0
        )
      end
    end

    context do
      let(:user_rates_count) { Neko::Stats::INTERVALS[1] + 1 }
      it do
        expect(statistics).to have_attributes(
          interval_0: 0,
          interval_1: 0,
          interval_2: 1,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 0
        )
      end
    end

    context do
      let(:user_rates_count) { 999_999 }
      it do
        expect(statistics).to have_attributes(
          interval_0: 0,
          interval_1: 0,
          interval_2: 0,
          interval_3: 0,
          interval_4: 0,
          interval_5: 0,
          interval_6: 1
        )
      end
    end
  end
end
