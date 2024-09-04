describe Api::V1::IgnoresController do
  let(:user_2) { create :user, id: 1234567, nickname: 'user_1234567' }

  describe '#create' do
    let(:make_request) { post :create, params: { id: user_2.id } }

    context 'unauthorized' do
      before { make_request }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authorized' do
      include_context :authenticated, :user

      context 'not yet ignored', :show_in_doc do
        before { make_request }

        it do
          expect(response).to have_http_status :success
          expect(user.reload.ignores?(user_2)).to eq true
          expect(user.reload.ignores).to have(1).item
          expect(json[:notice]).to eq 'Сообщения от user_1234567 заблокированы'
        end
      end

      context 'already ignored' do
        let!(:ignore) { create :ignore, user:, target: user_2 }
        before { make_request }

        it do
          expect(response).to have_http_status :success
          expect(user.reload.ignores?(user_2)).to eq true
          expect(user.reload.ignores).to have(1).item
          expect(json[:notice]).to eq 'Сообщения от user_1234567 заблокированы'
        end
      end
    end
  end

  describe '#destroy' do
    let(:make_request) { delete :destroy, params: { id: user_2.id } }

    context 'unauthorized' do
      before { make_request }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authorized', :show_in_doc do
      include_context :authenticated, :user

      before { make_request }

      it do
        expect(user.reload.ignores? user_2).to eq false
        expect(user.ignores).to be_empty
        expect(response).to have_http_status :success
        expect(json[:notice]).to eq 'Сообщения от user_1234567 больше не блокируются'
      end
    end
  end
end
