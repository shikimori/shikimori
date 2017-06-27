describe Contest::Finish do
  let(:operation) { Contest::Finish.new contest }

  include_context :timecop

  let(:contest) { create :contest, :started, user_vote_key: 'can_vote_1' }
  let!(:user) { create :user, can_vote_1: true }
  let!(:contest_suggestion) { create :contest_suggestion, contest: contest }
  let(:notifications) { double contest_finished: nil }

  before do
    allow(Messages::CreateNotification)
      .to receive(:new)
      .with(contest)
      .and_return(notifications)
  end
  subject! { operation.call }

  it do
    expect(contest.reload).to be_finished
    expect(contest.finished_on).to eq Time.zone.today
    expect { contest_suggestion.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(user.reload.can_vote_1).to eq false
    expect(notifications).to have_received :contest_finished
  end
end
