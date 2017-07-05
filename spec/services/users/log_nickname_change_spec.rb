describe Users::LogNicknameChange do
  let(:service) { Users::LogNicknameChange.new user, old_nickname }

  let(:user) { create :user, nickname: nickname, created_at: created_at }

  let(:nickname) { 'test' }
  let(:old_nickname) { 'test old' }

  let(:created_at) { (User::DAY_LIFE_INTERVAL + 1.hour).ago }

  let(:friend_1) { seed :user }
  let(:friend_2) { create :user }
  let!(:friend_link_1) { create :friend_link, dst: user, src: friend_1 }
  let!(:friend_link_2) { create :friend_link, dst: user, src: friend_2 }

  before do
    allow(Messages::CreateNotification).to receive(:new)
      .and_return messages_service
  end
  let(:messages_service) { double nickname_changed: nil }
  subject { service.call }

  it do
    expect { subject }.to change(UserNicknameChange, :count).by 1
    expect(user.nickname_changes.first).to have_attributes(
      value: old_nickname
    )

    expect(Messages::CreateNotification).to have_received(:new).with(user).twice
    expect(messages_service).to have_received(:nickname_changed)
      .with(friend_1, old_nickname, user.nickname)
    expect(messages_service).to have_received(:nickname_changed)
      .with(friend_2, old_nickname, user.nickname)
  end

  context 'not day registered' do
    let(:created_at) { (User::DAY_LIFE_INTERVAL - 1.hour).ago }
    it do
      expect { subject }.to_not change UserNicknameChange, :count
    end
  end

  # describe 'should_log?' do
    # context 'less than User::DAY_LIFE_INTERVAL after registration' do
      # let(:created_at) { (User::DAY_LIFE_INTERVAL + 1.hour).ago }
      # it { expect { user.update nickname: 'test' }.to_not change(UserNicknameChange, :count) }
    # end

    # context 'more than User::DAY_LIFE_INTERVAL after registration' do
      # context 'nickname "Новый пользователь1"' do
        # let(:nickname) { 'Новый пользователь1' }
        # it { expect { user.update nickname: 'test' }.to_not change(UserNicknameChange, :count) }
      # end

      # context 'nickname "some other nickname"' do
        # let(:nickname) { 'some other nickname' }
        # it { expect { user.update nickname: 'test' }.to change(UserNicknameChange.where(user_id: user.id, value: nickname), :count).by 1 }
      # end
    # end
  # end

  # describe 'notify_friends' do

    # it { expect { user.update nickname: "#{nickname}z" }.to change(Message, :count).by 1 }
  # end
end
