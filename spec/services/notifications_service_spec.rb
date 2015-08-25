describe NotificationsService do
  let(:service) { NotificationsService.new target }

  describe '#nickname_changed' do
    let(:user) { create :user }
    let(:friend) { create :user, notifications: notifiactions }
    let(:old_nickname) { 'old_nick' }
    let(:new_nickname) { 'new_nick' }

    let(:target) { user }

    subject(:notify) { service.nickname_changed friend, old_nickname, new_nickname }

    context 'disabled_notifications' do
      let(:notifiactions) { User::DEFAULT_NOTIFICATIONS - User::NICKNAME_CHANGE_NOTIFICATIONS }
      it { should be nil }
      it { expect{subject}.to_not change(Message, :count) }
    end

    context 'allowed_notifications' do
      before { allow(BotsService).to receive(:get_poster).and_return bot }
      let(:notifiactions) { User::DEFAULT_NOTIFICATIONS  }
      let(:bot) { create :user }

      it { should be_persisted }
      its(:from) { should eq bot }
      its(:to) { should eq friend }
      its(:body) { should include old_nickname }
      its(:body) { should include new_nickname }
      it { expect{subject}.to change(Message, :count).by 1 }
      it 'ignores antispam' do
        expect {
          service.nickname_changed friend, old_nickname, new_nickname
          service.nickname_changed friend, old_nickname, new_nickname
        }.to change(Message, :count).by 2
      end
    end
  end

  describe '#round_finished' do
    let(:contest) { create :contest, :with_generated_thread }
    let(:round) { create :contest_round, contest: contest }

    let(:target) { round }

    before { service.round_finished }

    it { expect(contest.thread.comments).to have(1).item }
  end
end
