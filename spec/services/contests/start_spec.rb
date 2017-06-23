describe Contests::Start do
  let(:service) { Contests::Start.new contest }

  include_context :timecop

  let(:contest) do
    create :contest, :with_5_members,
      started_on: 1.day.ago,
      updated_at: 1.day.ago
  end

  before { allow(Contests::GenerateRounds).to receive(:call).and_call_original }
  subject! { service.call }

  it do
    expect(contest.reload.started_on).to eq Time.zone.today
    expect(contest.updated_at).to be_within(0.1).of(Time.zone.now)
    expect(contest.rounds).to have(6).items
    expect(contest.rounds.first).to be_started

    expect(Contests::GenerateRounds).to have_received(:call).with contest
  end
end
