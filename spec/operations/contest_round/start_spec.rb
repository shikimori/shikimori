describe ContestRound::Start do
  include_context :timecop

  let(:operation) { ContestRound::Start.new contest_round }

  let(:contest) { create :contest, :with_topics, :with_5_members, state: 'started' }
  let(:contest_round) { create :contest_round, contest: contest }

  before do
    contest.strategy.fill_round_with_matches contest_round
    contest_round.matches.last.update started_on: Time.zone.tomorrow
  end

  subject! { operation.call }

  it do
    contest_round.matches[0..-2].each do |contest_match|
      expect(contest_match).to be_started
    end
    expect(contest_round.matches.last).to be_created
  end
end
