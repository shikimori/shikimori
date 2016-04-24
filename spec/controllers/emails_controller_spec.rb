describe EmailsController do
  describe '#bounce' do
    let(:user) { create :user }
    let(:make_request) { post :bounce, recipient: email }

    context 'present user' do
      let(:email) { user.email }
      it do
        expect{make_request}.to change(Message, :count).by 1
        expect(user.reload.messages).to have(1).item
        expect(user.email).to eq ''
        expect(user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL).to eq 0

        expect(response).to have_http_status :success
      end
    end

    context 'missing user' do
      let(:email) { 'zxcsdrtgfdgv' }
      it do
        expect{make_request}.to_not change Message, :count

        expect(user.reload.email).to_not eq ''
        expect(user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL).to_not eq 0
        expect(response).to have_http_status :success
      end
    end

    context 'missing email' do
      let(:email) { '' }
      it do
        expect{make_request}.to_not change Message, :count

        expect(user.reload.email).to_not eq ''
        expect(user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL).to_not eq 0
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#spam' do
    let(:user) { create :user }
    before { post :spam, recipient: user.email }

    it do
      expect(user.reload.messages).to be_empty
      expect(user.email).to eq ''
      expect(user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL).to eq 0
      expect(response).to have_http_status :success
    end
  end
end
