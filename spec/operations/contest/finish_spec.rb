describe Contest::Finish do
  include_context :timecop

  let(:contest) { create :contest, :started, user_vote_key: 'can_vote_1' }
  let!(:user) { create :user, can_vote_1: true }
  let(:notifications) { double contest_finished: nil }
  let(:uniq_voters_count) { 100 }
  let(:votes_scope) { double delete_all: nil }
  let!(:contest_round) { create :contest_round, :finished, contest: contest }

  before do
    allow(Messages::CreateNotification)
      .to receive(:new)
      .with(contest)
      .and_return(notifications)
    allow(Contests::ObtainWinners).to receive(:call)
    allow(Contests::UniqVotersCount)
      .to receive(:call)
      .with(contest)
      .and_return(uniq_voters_count)
    allow(Contests::Votes)
      .to receive(:call)
      .with(contest)
      .and_return(votes_scope)
  end
  subject! { described_class.call contest }

  it do
    expect(contest.reload).to be_finished
    expect(contest).to have_attributes(
      finished_on: Time.zone.today,
      cached_uniq_voters_count: uniq_voters_count
    )
    expect(votes_scope).to have_received :delete_all
    expect(user.reload.can_vote_1).to eq false
    expect(notifications).to have_received :contest_finished

    expect(Contests::ObtainWinners).to have_received(:call).with contest
  end
end
