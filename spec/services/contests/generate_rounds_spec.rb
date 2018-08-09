describe Contests::GenerateRounds do
  let(:contest) do
    create :contest, :with_5_members,
      started_on: 1.day.ago,
      updated_at: 1.day.ago
  end
  let!(:some_round) { create :contest_round, contest: contest }

  before { allow(contest.strategy).to receive(:create_rounds).and_call_original }
  subject! { Contests::GenerateRounds.call contest }

  it do
    expect { some_round.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(contest.rounds).to have(6).items
    expect(contest.strategy).to have_received :create_rounds
  end
end
