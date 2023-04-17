describe Users::ResetEmailsController do
  include_context :authenticated, :admin

  describe '#new' do
    subject! do
      get :new,
        params: {
          profile_id: user.to_param
        }
    end
    it { expect(response).to have_http_status :success }
  end
end
