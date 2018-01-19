describe SpentTime do
  subject(:time) { SpentTime.new interval }

  context 'full time' do
    let(:years) { 1 }
    let(:months_6) { 1 }
    let(:months_3) { 1 }
    let(:months) { 2 }
    let(:weeks) { 3 }
    let(:days) { 4 }
    let(:hours) { 11 }
    let(:minutes) { 22 }

    let(:interval) do
      years * 365 +
        months_6 * 180 +
        months_3 * 90 +
        months * 30 +
        weeks * 7 +
        days +
        hours / 24.0 +
        minutes / 24.0 / 60
    end

    its(:years) { is_expected.to eq interval / 365 }
    its(:years_part) { is_expected.to eq years }

    its(:months_6) { is_expected.to eq interval / 180.0 }

    its(:months_3) { is_expected.to eq interval / 90.0 }

    its(:months) { is_expected.to eq interval / 30 }
    its(:months_part) { is_expected.to eq months + months_3 * 3 + months_6 * 6 }

    its(:weeks) { is_expected.to eq interval / 7 }
    its(:weeks_part) { is_expected.to eq weeks }

    its(:days) { is_expected.to eq interval }
    its(:days_part) { is_expected.to eq days }

    its(:hours) { is_expected.to eq interval * 24.0 }
    its(:hours_part) { is_expected.to eq hours }

    its(:minutes) { is_expected.to eq interval * 24.0 * 60.0 }
    its(:minutes_part) { is_expected.to eq minutes }
  end
end
