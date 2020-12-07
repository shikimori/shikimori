describe DbStatistics::ListDuration do
  let(:service) { described_class.new scope, type }
  subject { service.call }
  let(:scope) { UserRate.where(target_type: 'Anime') }
  let(:type) { :anime }

  before do
    allow(service)
      .to receive(:fetch)
      .and_return stats
    allow(service)
      .to receive(:spawn_intervals)
      .with(stats)
      .and_return intervals
  end
  let(:stats) { [699, 700, 701, 72999, 73000, 73001] }
  let(:intervals) do
    [700, 2100, 5200, 11000, 19000, 28000, 40000, 54000, 73000, described_class::FINAL_INTERVAL]
  end

  it do
    is_expected.to eq(
      '1-' => 1, # [0..700)
      '2' => 2, # [700-2100)
      '3-4' => 0, # [2100..5200)
      '5-8' => 0, # [5200..11000)
      '9-14' => 0, # [11000..19000)
      '15-20' => 0, # [19000..28000)
      '21-28' => 0, # [28000..40000)
      '29-38' => 0, # [40000..54000)
      '39-51' => 1, # [40000..73000)
      '51+' => 2 # [73000..)
    )
  end
end
