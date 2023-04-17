describe Users::ResetEmailsController do
  include_context :authenticated, :admin

  describe '#new' do
    subject! do
      get :new,
        params: {
          profile_id: user_2.to_param
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    before do
      allow(ShikiMailer).to receive(:custom_message).and_return mail
    end
    let(:mail) { double deliver_now: nil }
    subject! do
      post :create,
        params: {
          profile_id: user_2.to_param,
          reset_email: {
            email: email,
            message: message
          }
        }
    end
    let(:message) { described_class::EMAIL_BODY }

    context 'invalid email' do
      let(:email) { user.email }
      it do
        expect(resource.reload.email).to eq user_2.email
        expect(ShikiMailer).to_not have_received :custom_message
        expect(mail).to_not have_received :deliver_now
        expect(response).to render_template :new
        expect(response).to have_http_status :success
      end
    end

    context 'the same email' do
      let(:email) { user_2.email }
      it do
        expect(resource.reload.email).to eq user_2.email
        expect(ShikiMailer).to_not have_received :custom_message
        expect(mail).to_not have_received :deliver_now
        expect(response).to render_template :new
        expect(response).to have_http_status :success
      end
    end

    context 'valid email' do
      let(:email) { 'asd@dfg.zxc' }

      context 'with message' do
        it do
          expect(resource.email).to eq email
          expect(user_2.reload.email).to eq email
          expect(resource).to_not be_changed
          expect(ShikiMailer)
            .to have_received(:custom_message)
            .with(
              email: email,
              subject: described_class::EMAIL_SUBJECT,
              body: format(message,
                user_url: resource.url,
                email: resource.email,
                password_recovery_url: new_user_password_url(user: { email: resource.email }))
            )
          expect(mail).to have_received :deliver_now
          expect(response).to render_template :success
          expect(response).to have_http_status :success
        end
      end

      context 'withwithout message' do
        let(:message) { ['', nil].sample }

        it do
          expect(resource.email).to eq email
          expect(resource).to_not be_changed
          expect(ShikiMailer).to_not have_received :custom_message
          expect(mail).to_not have_received :deliver_now
          expect(response).to render_template :success
          expect(response).to have_http_status :success
        end
      end
    end
  end
end
