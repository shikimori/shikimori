describe Doorkeeper::OauthApplicationsController do
  include_context :authenticated, :user, :day_registered

  describe '#index' do
    let!(:oauth_application_1) { create :oauth_application, owner: user }
    let!(:oauth_application_2) { create :oauth_application, owner: user }
    let!(:oauth_application_3) { create :oauth_application, owner: user_1 }

    context 'w/o user_id' do
      subject! { get :index }

      it do
        expect(collection).to eq [
          oauth_application_1,
          oauth_application_2,
          oauth_application_3
        ]
        expect(response).to have_http_status :success
      end
    end

    context 'user_id' do
      subject! { get :index, params: { user_id: user.id } }

      it do
        expect(collection).to eq [
          oauth_application_1,
          oauth_application_2
        ]
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#show' do
    let(:oauth_application) { create :oauth_application, owner: user }
    subject! do
      get :show,
        params: {
          id: oauth_application.id
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    subject! do
      get :new,
        params: {
          oauth_application: { owner_id: user.id, owner_type: User.name }
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    subject! do
      post :create,
        params: {
          oauth_application: oauth_application_params
        }
    end
    let(:image) { Rack::Test::UploadedFile.new 'spec/files/anime.jpg', 'image/jpg' }

    context 'valid params' do
      let(:oauth_application_params) do
        {
          owner_id: user.id,
          owner_type: User.name,
          name: 'test',
          image: image,
          redirect_uri: 'https://test.com',
          description_ru: '',
          description_en: '',
          scopes: %w[ignores user_rates]
        }
      end

      it do
        expect(resource).to be_persisted
        expect(resource).to_not be_changed
        expect(resource).to be_valid
        expect(resource).to have_attributes oauth_application_params.except(:image, :scopes)
        expect(resource.scopes).to eq %w[user_rates]
        expect(resource.image).to be_exists
        expect(response).to redirect_to edit_oauth_application_url(resource)
      end
    end

    context 'invalid params' do
      let(:oauth_application_params) do
        {
          owner_id: user.id,
          owner_type: User.name
        }
      end

      it do
        expect(resource).to_not be_valid
        expect(resource).to_not be_persisted
        expect(response).to render_template :form
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#edit' do
    subject! { get :edit, params: { id: oauth_application.id } }
    let(:oauth_application) { create :oauth_application, owner: user }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:oauth_application) do
      create :oauth_application,
        owner: user,
        scopes: 'ignores',
        allowed_scopes: %w[ignores user_rates]
    end

    subject! do
      post :update,
        params: {
          id: oauth_application.id,
          oauth_application: oauth_application_params
        }
    end

    context 'valid params' do
      let(:oauth_application_params) do
        {
          name: 'test',
          redirect_uri: 'https://test.com',
          scopes: %w[ignores friends user_rates]
        }
      end

      it do
        expect(resource).to be_valid
        expect(resource).to_not be_changed
        expect(resource).to have_attributes oauth_application_params.except(:scopes)
        expect(resource.scopes).to eq %w[user_rates ignores]
        expect(response).to redirect_to edit_oauth_application_url(resource)
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
    subject! { delete :destroy, params: { id: oauth_application.id } }
    let(:oauth_application) { create :oauth_application, owner: user }

    it do
      expect(resource).to be_destroyed
      expect(response).to redirect_to oauth_applications_url
    end
  end

  describe '#revoke' do
    let(:user_2) { create :user }

    let(:oauth_application_1) { create :oauth_application, owner: user_2 }
    let(:oauth_application_2) { create :oauth_application, owner: user_2 }

    let!(:token_1) do
      create %i[oauth_token oauth_grant].sample,
        resource_owner_id: user.id,
        application_id: oauth_application_1.id
    end
    let!(:token_2) do
      create %i[oauth_token oauth_grant].sample,
        resource_owner_id: user.id,
        application_id: oauth_application_2.id
    end
    let!(:token_3) do
      create %i[oauth_token oauth_grant].sample,
        resource_owner_id: user_2.id,
        application_id: oauth_application_1.id
    end

    subject! { post :revoke, params: { id: oauth_application_1.id } }

    it do
      expect { token_1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(token_2.reload).to be_persisted
      expect(token_3.reload).to be_persisted
      expect(response).to redirect_to oauth_application_url(oauth_application_1)
    end
  end
end
