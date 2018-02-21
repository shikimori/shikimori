describe Users::OauthApplicationsController do
  include_context :authenticated, :user

  describe '#index' do
    let!(:oauth_application_1) { create :oauth_application, user: user }
    let!(:oauth_application_2) { create :oauth_application, user: user }
    let!(:oauth_application_3) { create :oauth_application, user: seed(:user) }

    # before { get :index, params: { profile_id: user.to_param } }
    before do
      get :index, params: { profile_id: user.to_param }
    end

    it do
      expect(collection).to eq [oauth_application_2, oauth_application_1]
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    let(:oauth_application) { create :oauth_application, user: user }
    before do
      get :show,
        params: {
          profile_id: user.to_param,
          id: oauth_application.id
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    before do
      get :new,
        params: {
          profile_id: user.to_param,
          oauth_application: { user_id: user.id }
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    before do
      post :create,
        params: {
          profile_id: user.to_param,
          oauth_application: oauth_application_params
        }
    end
    let(:image) { Rack::Test::UploadedFile.new 'spec/files/anime.jpg', 'image/jpg' }

    context 'valid params' do
      let(:oauth_application_params) do
        {
          user_id: user.id,
          name: 'test',
          image: image,
          redirect_uri: 'https://test.com'
        }
      end

      it do
        expect(resource).to be_valid
        expect(resource).to be_persisted
        expect(resource).to have_attributes oauth_application_params.except(:image)
        expect(resource.image).to be_exists
        expect(response).to redirect_to edit_profile_oauth_application_url(user, resource)
      end
    end

    context 'invalid params' do
      let(:oauth_application_params) { { user_id: user.id } }

      it do
        expect(resource).to_not be_valid
        expect(resource).to_not be_persisted
        expect(response).to render_template :form
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#edit' do
    let(:oauth_application) { create :oauth_application, user: user }
    before do
      get :edit,
        params: {
          profile_id: user.to_param,
          id: oauth_application.id
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:oauth_application) { create :oauth_application, user: user }

    before do
      post :update,
        params: {
          profile_id: user.to_param,
          id: oauth_application.id,
          oauth_application: oauth_application_params
        }
    end

    context 'valid params' do
      let(:oauth_application_params) do
        {
          name: 'test',
          redirect_uri: 'https://test.com'
        }
      end

      it do
        expect(resource).to be_valid
        expect(resource).to_not be_changed
        expect(resource).to have_attributes oauth_application_params
        expect(response).to redirect_to edit_profile_oauth_application_url(user, resource)
      end
    end

    context 'invalid params' do
      let(:oauth_application_params) { { name: '' } }

      it do
        expect(resource).to_not be_valid
        expect(resource).to be_changed
        expect(response).to render_template :form
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    let(:oauth_application) { create :oauth_application, user: user }

    before do
      delete :destroy,
        params: {
          profile_id: user.to_param,
          id: oauth_application.id
        }
    end

    it do
      expect(resource).to be_destroyed
      expect(response).to redirect_to profile_oauth_applications_url(user)
    end
  end
end
