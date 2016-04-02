describe NotificationsService do
  let(:service) { NotificationsService.new target }

  describe '#user_registered' do
    let(:target) { build_stubbed :user }
    let!(:sender) { create :user, id: User::COSPLAYER_ID }
    it { expect{service.user_registered}.to change(target.messages, :count).by 1 }
  end

  describe '#nickname_changed' do
    let(:target) { create :user }
    let(:friend) { create :user, notifications: notifiactions }
    let(:old_nickname) { 'old_nick' }
    let(:new_nickname) { 'new_nick' }

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
    let(:target) { create :contest_round, contest: contest }
    let(:contest) { create :contest, :with_topic }

    before { service.round_finished }

    it { expect(contest.topic.comments).to have(1).item }
  end

  describe '#contest_finished' do
    let(:target) { create :contest, :with_topic }
    let!(:round) { create :contest_round, contest: target }
    let!(:match) { create :contest_match, round: round }
    let!(:user_vote) { create :contest_user_vote, match: match, user: user_1, item_id: 1, ip: '1' }

    let!(:user_1) { create :user }
    let!(:user_2) { create :user }

    before { service.contest_finished }

    it do
      expect(target.topic.comments).to have(1).item
      expect(user_1.messages).to have(1).item
      expect(user_2.messages).to be_empty
    end
  end
end
