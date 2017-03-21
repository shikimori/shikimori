describe Messages::CreateNotification do
  let(:service) { Messages::CreateNotification.new target }

  describe '#user_registered' do
    let(:target) { build_stubbed :user }
    let!(:sender) { create :user, id: 999_999_999 }
    it do
      expect { service.user_registered }.to change(target.messages, :count).by 1
    end
  end

  describe '#nickname_changed' do
    let(:target) { create :user }
    let(:friend) { create :user, notifications: notifications }
    let(:old_nickname) { 'old_nick' }
    let(:new_nickname) { 'new_nick' }

    subject(:notify) { service.nickname_changed friend, old_nickname, new_nickname }

    context 'disabled_notifications' do
      let(:notifications) { User::DEFAULT_NOTIFICATIONS - User::NICKNAME_CHANGE_NOTIFICATIONS }
      it { is_expected.to be nil }
      it { expect { subject }.to_not change(Message, :count) }
    end

    context 'allowed_notifications' do
      before { allow(BotsService).to receive(:get_poster).and_return bot }
      let(:notifications) { User::DEFAULT_NOTIFICATIONS }
      let(:bot) { create :user }

      it { is_expected.to be_persisted }
      its(:from) { is_expected.to eq bot }
      its(:to) { is_expected.to eq friend }
      its(:body) { is_expected.to include old_nickname }
      its(:body) { is_expected.to include new_nickname }
      it { expect { subject }.to change(Message, :count).by 1 }
      it 'ignores antispam' do
        expect(proc do
          service.nickname_changed friend, old_nickname, new_nickname
          service.nickname_changed friend, old_nickname, new_nickname
        end).to change(Message, :count).by 2
      end
    end
  end

  describe '#round_finished' do
    let(:target) { create :contest_round, contest: contest }
    let(:contest) { create :contest, :with_topics }

    before { service.round_finished }

    it do
      contest.topics.each do |topic|
        expect(topic.comments).to have(1).item
      end
    end
  end

  describe '#contest_finished' do
    let(:target) { create :contest, :with_topics }
    let!(:round) { create :contest_round, contest: target }
    let!(:match) { create :contest_match, round: round }
    let!(:user_vote) { create :contest_user_vote, match: match, user: user_1, item_id: 1, ip: '1' }

    let!(:user_1) { create :user }
    let!(:user_2) { create :user }

    before { service.contest_finished }

    it do
      target.topics.each do |topic|
        expect(topic.comments).to have(1).item
      end

      expect(user_1.messages).to have(1).item
      expect(user_2.messages).to be_empty
    end
  end
end
