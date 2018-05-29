describe Api::V1::FriendsController do
  let(:user) { create :user }
  let(:user2) { create :user, id: 1234567, nickname: 'user_1234567' }

  describe '#create' do
    context 'unauthorized' do
      before { post :create, params: { id: user2.id } }
      it { expect(response).to be_redirect }
    end

    context 'authorized', :show_in_doc do
      include_context :authenticated, :user
      before { post :create, params: { id: user2.id } }

      it do
        expect(user.reload.messages).to be_empty
        expect(user2.reload.messages).to have(1).item

        expect(user.friends.include?(user2)).to eq true
        expect(user2.friends.include?(user2)).to eq false

        expect(json[:notice]).to eq 'user_1234567 добавлен в друзья'
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    context 'unauthorized' do
      before { delete :destroy, params: { id: user2.id } }
      it { expect(response).to be_redirect }
    end

    context 'authorized', :show_in_doc do
      include_context :authenticated, :user
      before { delete :destroy, params: { id: user2.id } }

      it do
        expect(User.find(user.id).friends.include?(user2)).to eq false

        expect(json[:notice]).to eq 'user_1234567 удалён из друзей'
        expect(response).to have_http_status :success
      end
    end
  end
end
