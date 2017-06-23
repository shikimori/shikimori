describe Contests::Finalize do
  let(:service) { Contests::Finalize.new contest }

  include_context :timecop

  let(:contest) { create :contest, user_vote_key: 'can_vote_1' }
  let!(:user) { create :user, can_vote_1: true }
  let(:notifications) { double contest_finished: nil }

  before do
    allow(Messages::CreateNotification)
      .to receive(:new)
      .with(contest)
      .and_return(notifications)
  end
  subject! { service.call }

  it do
    expect(user.reload.can_vote_1).to eq false
    expect(contest.reload.finished_on).to eq Time.zone.today
    expect(notifications).to have_received :contest_finished
  end
end
