describe Neko::Statistics do
  describe '#increment' do
    let(:statistics) { Neko::Statistics.new }
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
      let(:user_rates_count) { Neko::Statistics::INTERVALS[0] - 1 }
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
      let(:user_rates_count) { Neko::Statistics::INTERVALS[0] }
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
      let(:user_rates_count) { Neko::Statistics::INTERVALS[1] }
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
