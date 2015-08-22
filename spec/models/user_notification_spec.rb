describe User do
  describe '#notify_bounced_email' do
    before { user.notify_bounced_email }

    describe 'subscribed user' do
      let(:user) { create :user, notifications: User::PRIVATE_MESSAGES_TO_EMAIL + User::NICKNAME_CHANGE_NOTIFICATIONS }
      it { expect(user.reload.notifications).to eq User::NICKNAME_CHANGE_NOTIFICATIONS }
    end

    describe 'not subscribed user' do
      let(:user) { create :user, notifications: User::NICKNAME_CHANGE_NOTIFICATIONS }
      it { expect(user.reload.notifications).to eq User::NICKNAME_CHANGE_NOTIFICATIONS }
    end
  end
end
