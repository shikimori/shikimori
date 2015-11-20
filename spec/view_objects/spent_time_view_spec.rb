describe SpentTimeView do
  let(:view) { SpentTimeView.new spent_time }
  let(:spent_time) { SpentTime.new days }

  subject { view.text }

  context '0 days' do
    let(:days) { 0 }
    it { is_expected.to eq '0 часов' }
  end

  context '3 year, 2 months' do
    let(:days) { 3 * 365 + 2 * 30 }
    it { is_expected.to eq '3 года и 2 месяца' }
  end

  context '3 years, 0 months' do
    let(:days) { 3 * 365 }
    it { is_expected.to eq '3 года' }
  end

  context '3 months, 2 weeks' do
    let(:days) { 3 * 30 + 2 * 7 }
    it { is_expected.to eq '3 месяца и 2 недели' }
  end

  context '3 months, 0 weeks' do
    let(:days) { 3 * 30 }
    it { is_expected.to eq '3 месяца' }
  end

  context '3 weeks, 2 days' do
    let(:days) { 3 * 7 + 2 }
    it { is_expected.to eq '3 недели и 2 дня' }
  end

  context '3 weeks, 0 days' do
    let(:days) { 3 * 7 }
    it { is_expected.to eq '3 недели' }
  end

  context '3 days, 12 hours' do
    let(:days) { 3 + 0.5 }
    it { is_expected.to eq '3 дня и 12 часов' }
  end

  context '3 days, 0 hours' do
    let(:days) { 3 }
    it { is_expected.to eq '3 дня' }
  end

  context '12 hours, 10 minutes' do
    let(:days) { 0.5 + 0.02 }
    it { is_expected.to eq '12 часов и 28 минут' }
  end

  context '12 hours, 0 minutes' do
    let(:days) { 0.5 }
    it { is_expected.to eq '12 часов' }
  end

  context '28 minutes' do
    let(:days) { 0.02 }
    it { is_expected.to eq '28 минут' }
  end
end
