describe UserNicknameChange do
  describe 'relations' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :value }
    #it { should validate_uniqueness_of(:user_id).scoped_to(:value) }
  end

  describe '#create' do
    let!(:user) { create :user, nickname: nickname, created_at: created_at }
    let(:created_at) { Time.zone.now - UserNicknameChange::MINIMUM_LIFE_INTERVAL - 1.hour }
    let(:comments_count) { UserNicknameChange::MINIMUM_COMMENTS_COUNT + 1 }
    let(:nickname) { 'test' }

    before { allow(user).to receive_message_chain(:comments, :count).and_return comments_count }

    describe 'sohuld_log?' do
      context 'less than UserNicknameChange::MINIMUM_LIFE_INTERVAL after registration' do
        let(:created_at) { Time.zone.now - UserNicknameChange::MINIMUM_LIFE_INTERVAL + 1.hour }
        it { expect{user.update nickname: 'test'}.to_not change(UserNicknameChange, :count) }
      end

      context 'more than UserNicknameChange::MINIMUM_LIFE_INTERVAL after registration' do
        context 'less than MINIMUM_COMMENTS_COUNT user commens' do
          let(:comments_count) { UserNicknameChange::MINIMUM_COMMENTS_COUNT - 1 }
          it { expect{user.update nickname: 'test'}.to_not change(UserNicknameChange, :count) }
        end

        context 'more than MINIMUM_COMMENTS_COUNT user commens' do
          context 'nickname "Новый пользователь1"' do
            let(:nickname) { 'Новый пользователь1' }
            it { expect{user.update nickname: 'test'}.to_not change(UserNicknameChange, :count) }
          end

          context 'nickname "some other nickname"' do
            let(:nickname) { 'some other nickname' }
            it { expect{user.update nickname: 'test'}.to change(UserNicknameChange.where(user_id: user.id, value: nickname), :count).by 1 }
          end
        end
      end
    end

    describe 'notify_friends' do
      let!(:user_2) { create :user }
      let!(:friend_link_2) { create :friend_link, dst: user, src: user_2 }

      it { expect{user.update nickname: "#{nickname}z"}.to change(Message, :count).by 1 }
    end
  end
end
