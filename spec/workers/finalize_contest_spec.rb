describe FinalizeContest do
  let(:worker) { FinalizeContest.new }

  let!(:now) { Time.zone.now }

  before { Timecop.freeze now }
  after { Timecop.return }

  describe '#perform' do
    let(:contest) { create :contest, user_vote_key: 'can_vote_1' }
    let!(:user) { create :user, can_vote_1: true }
    let(:notifications) { double contest_finished: nil }

    before { allow(NotificationsService).to receive(:new).with(contest).and_return notifications }
    before { worker.perform contest.id }

    it do
      expect(user.reload.can_vote_1).to eq false
      expect(contest.reload.finished_on).to eq now.to_date
      expect(notifications).to have_received :contest_finished
    end
  end
end
