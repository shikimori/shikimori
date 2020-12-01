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
  let(:stats) { [0, 59, 60, 100, 100, 30000, 100001] }
  let(:intervals) do
    [700, 2100, 5200, 11000, 19000, 28000, 40000, 54000, 73000, 100000]
  end

  it do
    ap subject
    # is_expected.to have(described_class::INTERVALS[interval].size).keys
    # expect(subject['10']).to eq 1
    # expect(subject.values[1..].all?(&:zero?)).to eq true
  end

  # context 'user is excluded' do
  #   let(:user) do
  #     create :user,
  #       roles: [Types::User::ROLES_EXCLUDED_FROM_STATISTICS.sample]
  #   end
  #
  #   it do
  #     is_expected.to have(described_class::INTERVALS[interval].size).keys
  #     expect(subject.values.all?(&:zero?)).to eq true
  #   end
  # end
end
