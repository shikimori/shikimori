describe EmailsController do
  let(:reloaded_user) { User.find user.id }

  describe '#bounce' do
    let(:make_request) { post :bounce, params: { recipient: email } }

    context 'present user' do
      let(:email) { user.email }
      it do
        expect { make_request }.to change(Message, :count).by 1
        expect(reloaded_user.messages).to have(1).item
        expect(reloaded_user.email).to eq ''
        expect(reloaded_user).to_not be_notification_settings_private_message_email

        expect(response).to have_http_status :success
      end
    end

    context 'missing user' do
      let(:email) { 'zxcsdrtgfdgv' }
      it do
        expect { make_request }.to_not change Message, :count

        expect(reloaded_user.email).to_not eq ''
        expect(reloaded_user).to be_notification_settings_private_message_email
        expect(response).to have_http_status :success
      end
    end

    context 'missing email' do
      let(:email) { '' }
      it do
        expect { make_request }.to_not change Message, :count

        expect(reloaded_user.email).to_not eq ''
        expect(reloaded_user).to be_notification_settings_private_message_email
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#spam' do
    subject! { post :spam, params: { recipient: user.email } }

    it do
      expect(reloaded_user.messages).to be_empty
      expect(reloaded_user.email).to eq ''
      expect(reloaded_user).to_not be_notification_settings_private_message_email
      expect(response).to have_http_status :success
    end
  end
end
