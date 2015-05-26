describe Api::V1::IgnoresController do
  let(:user) { create :user }
  let(:user_2) { create :user, id: 1234567, nickname: 'user_1234567' }

  describe '#create' do
    let(:make_request) { post :create, id: user_2.id }

    context 'unauthorized' do
      before { make_request }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authorized' do
      include_context :authenticated, :user

      context 'not yet ignored', :show_in_doc do
        before { make_request }

        it { expect(response).to have_http_status :success }
        it { expect(user.reload.ignores?(user_2)).to be_truthy }
        it { expect(user.reload.ignores).to have(1).item }
      end

      context 'already ignored' do
        let!(:ignore) { create :ignore, user: user, target: user_2 }
        before { make_request }

        it { expect(response).to have_http_status :success }
        it { expect(user.reload.ignores?(user_2)).to be_truthy }
        it { expect(user.reload.ignores).to have(1).item }
      end
    end
  end

  describe '#destroy' do
    let(:make_request) { delete :destroy, id: user_2.id }

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
      end
    end
  end
end

