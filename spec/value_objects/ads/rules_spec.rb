describe Ads::Rules do
  include_context :timecop, Time.zone.at(1503267118).to_s

  let(:ad_rules) { Ads::Rules.new rules, shows_cookie }
  let(:rules) do
    {
      shows_per_week: shows_per_week
    }
  end
  let(:shows_per_week) { 10 }
  let(:shows_cookie) { shows&.map(&:to_i)&.join(Ads::Rules::DELIMITER) }
  let(:shows) { [] }

  describe '#shows' do
    context 'no value' do
      let(:shows_cookie) { '' }
      it { expect(ad_rules.shows).to eq [] }
    end

    context 'nil value' do
      let(:shows_cookie) { nil }
      it { expect(ad_rules.shows).to eq [] }
    end

    context 'joined values' do
      let(:shows_cookie) { "1503265526#{Ads::Rules::DELIMITER}1503266305" }

      it do
        expect(ad_rules.shows).to eq [
          Time.zone.at(1503265526),
          Time.zone.at(1503266305)
        ]
      end
    end

    context 'expired value' do
      let(:shows_cookie) { "1503265526#{Ads::Rules::DELIMITER}1502658400" }

      it do
        expect(ad_rules.shows).to eq [
          Time.zone.at(1503265526)
        ]
      end
    end
  end

  context '#show?' do
    let(:shows_per_week) { 8 }

    context 'weekly shows' do
      context 'too many shows' do
        let(:shows) do
          [
            6.days.ago,
            6.days.ago,
            5.days.ago,
            3.days.ago,
            2.days.ago,
            1.day.ago,
            1.hour.ago,
            30.minutes.ago
          ]
        end
        it { expect(ad_rules).to_not be_show }
      end

      context 'not enough shows' do
        let(:shows) do
          [
            6.days.ago,
            6.days.ago,
            5.days.ago,
            3.days.ago,
            2.days.ago,
            1.day.ago,
            1.hour.ago
          ]
        end
        it { expect(ad_rules).to be_show }
      end
    end

    context 'dayly shows' do
      context 'too many shows' do
        let(:shows) do
          [
            (Ads::Rules::DAY_INTERVAL - 1.hour).ago,
            30.minutes.ago
          ]
        end
        it { expect(ad_rules).to_not be_show }
      end

      context 'not enough shows' do
        let(:shows) do
          [
            (Ads::Rules::DAY_INTERVAL + 1.hour).ago,
            30.minutes.ago
          ]
        end
        it { expect(ad_rules).to be_show }
      end
    end
  end

  describe '#export_shows' do
    let(:shows) { [[], nil, [1.day.ago]].sample }

    it do
      expect(ad_rules.export_shows).to eq(
        ((shows || []) + [Time.zone.now]).map(&:to_i).join(Ads::Rules::DELIMITER)
      )
    end
  end

  describe '#fast_shows?, #next_show_in, #next_show_at' do
    let(:shows_policy) { ad_rules.send :shows_policy }
    let(:intervals) { Ads::Rules::INTERVALS[shows_policy] }

    context do
      let(:shows_per_week) { 3 }

      context do
        let(:shows) { [6.days.ago, 5.days.ago] }

        it { expect(ad_rules).to be_show }
        it { expect(ad_rules.send :fast_shows?).to eq true }
        it { expect(ad_rules.send :shows_policy).to eq Ads::Rules::FAST }
        it { expect(ad_rules.send :next_show_in).to eq intervals[0] }
        it { expect(ad_rules.send :next_show_at).to eq 1.minute.ago }
      end

      context do
        let(:shows) { [(Ads::Rules::DAY_INTERVAL - 1.hour).ago] }

        it { expect(ad_rules).to_not be_show }
        it { expect(ad_rules.send :fast_shows?).to eq false }
        it { expect(ad_rules.send :shows_policy).to eq Ads::Rules::SLOW }
        it { expect(ad_rules.send :next_show_in).to eq intervals[1] }
        it { expect(ad_rules.send :next_show_at).to eq shows.last + ad_rules.send(:next_show_in) }
      end

      context do
        let(:shows) { [2.days.ago] }
        it { expect(ad_rules).to be_show }
        it { expect(ad_rules.send :fast_shows?).to eq false }
      end

      context do
        let(:shows) { [3.days.ago] }
        it { expect(ad_rules).to be_show }
        it { expect(ad_rules.send :fast_shows?).to eq true }
      end
    end

    context do
      let(:shows_per_week) { 30 }

      context do
        let(:shows) { [] }
        it { expect(ad_rules).to be_show }
        it { expect(ad_rules.send :fast_shows?).to eq false }
      end

      context do
        let(:shows) do
          [25.hours.ago, 5.hours.ago, 5.hours.ago, 5.hours.ago, 5.hours.ago]
        end

        it { expect(ad_rules).to be_show }
        it { expect(ad_rules.send :fast_shows?).to eq false }
        it { expect(ad_rules.send :shows_policy).to eq Ads::Rules::SLOW }
        it { expect(ad_rules.send :next_show_in).to eq intervals[4] }
        it { expect(ad_rules.send :next_show_at).to eq shows.last + ad_rules.send(:next_show_in) }
      end

      context do
        let(:shows) do
          [5.hours.ago, 5.hours.ago, 5.hours.ago, 5.hours.ago, 5.hours.ago]
        end

        it { expect(ad_rules).to_not be_show }
        it { expect(ad_rules.send :fast_shows?).to eq false }
        it { expect(ad_rules.send :shows_policy).to eq Ads::Rules::SLOW }
        it { expect(ad_rules.send :next_show_in).to eq intervals.last }
        it { expect(ad_rules.send :next_show_at).to eq shows.last + ad_rules.send(:next_show_in) }
      end

      context do
        let(:shows) do
          [30.hours.ago, 5.hours.ago, 5.hours.ago, 5.hours.ago, 5.hours.ago]
        end

        it { expect(ad_rules).to be_show }
        it { expect(ad_rules.send :fast_shows?).to eq true }
        it { expect(ad_rules.send :shows_policy).to eq Ads::Rules::FAST }
        it { expect(ad_rules.send :next_show_in).to eq intervals.last }
        it { expect(ad_rules.send :next_show_at).to eq shows.last + ad_rules.send(:next_show_in) }
      end
    end
  end
end
