describe Api::V1::FriendsController do
  let(:user) { create :user }
  let(:user2) { create :user, id: 1234567, nickname: 'user_1234567' }

  let(:create_request) { post :create, id: user2.id }
  let(:destroy_request) { delete :destroy, id: user2.id }

  describe '#create' do
    context 'unauthorized' do
      before { create_request }
      it { expect(response).to be_redirect }
    end

    context 'authorized' do
      include_context :authenticated, :user

      it 'success', :show_in_doc do
        create_request
        expect(response).to be_success

        expect(User.find(user.id).friends.include?(user2)).to be_truthy
      end

      describe FriendLink.name do
        it do
          expect{create_request}.to change(FriendLink, :count).by(1)
        end

        it 'only once' do
          expect {
            create_request
            create_request
          }.to change(FriendLink, :count).by(1)

          expect(json[:notice]).to eq 'user_1234567 добавлен в друзья'
        end

        context 'already friend' do
          let(:user) { create :user, friends: [user2] }
          before { create_request }

          it { expect(json[:notice]).to eq 'user_1234567 уже среди ваших друзей' }
        end
      end

      describe Message.name do
        it do
          expect{create_request}.to change(Message, :count).by(1)
        end

        it 'only once' do
          expect {
            create_request
            create_request
          }.to change(Message, :count).by(1)
        end
      end
    end
  end

  describe '#destroy' do
    context 'unauthorized' do
      before { destroy_request }
      it { expect(response).to be_redirect }
    end

    context 'authorized' do
      include_context :authenticated, :user

      it 'success', :show_in_doc do
        destroy_request

        expect(response).to be_success
        expect(User.find(user.id).friends.include?(user2)).to be_falsy

        expect(json[:notice]).to eq 'user_1234567 удален из друзей'
      end

      it FriendLink.name do
        create_request

        expect{destroy_request}.to change(FriendLink, :count).by(-1)
      end
    end
  end
end
