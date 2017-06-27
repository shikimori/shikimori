describe Contest::Start do
  let(:operation) { Contest::Start.new contest }

  include_context :timecop

  let(:contest) do
    create :contest, :with_5_members,
      started_on: 1.day.ago,
      updated_at: 1.day.ago
  end
  let!(:contest_suggestion) { create :contest_suggestion, contest: contest }

  before { allow(Contests::GenerateRounds).to receive(:call).and_call_original }
  subject! { operation.call }

  it do
    expect(contest.reload).to be_started
    expect(contest.started_on).to eq Time.zone.today
    expect(contest.updated_at).to be_within(0.1).of(Time.zone.now)
    expect(contest.rounds).to have(6).items
    expect(contest.rounds.first).to be_started

    expect(Contests::GenerateRounds).to have_received(:call).with contest

    expect { contest_suggestion.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
