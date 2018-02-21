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
    rescue => e
      ap e.backtrace
      raise
    end
    let(:image) { Rack::Test::UploadedFile.new 'spec/files/anime.jpg', 'image/jpg' }

    context 'valid params', :focus do
      let(:oauth_application_params) do
        {
          user_id: user.id,
          name: 'test',
          image: image
        }
      end

      it do
        expect(resource).to be_valid
        expect(resource).to be_persisted
        expect(resource).to have_attributes oauth_application_params.except(:image)
        expect(resource.image).to be_persisted
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

  # describe '#edit' do
  #   let(:oauth_application) { create :oauth_application, :pending, user: user }
  #   before { get :edit, params: { profile_id: user.to_param, id: oauth_application.id } }

  #   it { expect(response).to have_http_status :success }
  # end

  # describe '#update' do
  #   let(:oauth_application) { create :oauth_application, oauth_application_state, user: user, name: 'qqq', text: 'cc' }
  #   let!(:oauth_application_variant) { create :oauth_application_variant, oauth_application: oauth_application, label: 'zzz' }

  #   before do
  #     post :update,
  #       params: {
  #         profile_id: user.to_param,
  #         id: oauth_application.id,
  #         oauth_application: {
  #           name: 'test',
  #           text: 'zxc',
  #           variants_attributes: [{
  #             label: 'test 1'
  #           }, {
  #             label: 'test 2'
  #           }]
  #         }
  #       }
  #   end

  #   context 'pending' do
  #     let(:oauth_application_state) { :pending }
  #     it do
  #       expect(resource).to have_attributes(
  #         name: 'test',
  #         text: 'zxc',
  #         state: 'pending',
  #         user_id: user.id
  #       )
  #       expect(resource.variants).to have(2).items
  #       expect(resource.variants[0]).to have_attributes(label: 'test 1')
  #       expect(resource.variants[1]).to have_attributes(label: 'test 2')

  #       expect { oauth_application_variant.reload }.to raise_error ActiveRecord::RecordNotFound

  #       expect(resource).to be_valid
  #       expect(response).to redirect_to edit_profile_oauth_application_url(user, resource)
  #     end
  #   end

  #   context 'started' do
  #     let(:oauth_application_state) { :started }

  #     it do
  #       expect(resource).to have_attributes(
  #         name: 'test',
  #         text: 'zxc',
  #         state: 'started',
  #         user_id: user.id
  #       )
  #       expect(resource.variants).to have(1).items
  #       expect(resource.variants[0]).to eq oauth_application_variant.reload

  #       expect(resource).to be_valid
  #       expect(response).to redirect_to profile_oauth_application_url(user, resource)
  #     end
  #   end
  # end

  # describe '#start' do
  #   let(:oauth_application) { create :oauth_application, :pending, :with_variants, user: user }
  #   before { post :start, params: { profile_id: user.to_param, id: oauth_application.id } }

  #   it do
  #     expect(resource.reload).to be_started
  #     expect(response).to redirect_to profile_oauth_application_url(user, resource)
  #   end
  # end

  # describe '#stop' do
  #   let(:oauth_application) { create :oauth_application, :started, user: user }

  #   before { post :stop, params: { profile_id: user.to_param, id: oauth_application.id } }

  #   it do
  #     expect(resource.reload).to be_stopped
  #     expect(response).to redirect_to profile_oauth_application_url(user, resource)
  #   end
  # end

  # describe '#destroy' do
  #   let(:oauth_application) { create :oauth_application, user: user }

  #   before do
  #     delete :destroy,
  #       params: {
  #         profile_id: user.to_param,
  #         id: oauth_application.id
  #       }
  #   end

  #   it do
  #     expect(resource).to be_destroyed
  #     expect(response).to redirect_to profile_oauth_applications_url(user)
  #   end
  # end
end
