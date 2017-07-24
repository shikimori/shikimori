describe Users::ListImportsController do
  include_context :authenticated, :user

  describe '#new' do
    subject! do
      get :new,
        params: {
          profile_id: user.to_param,
          list_import: { user_id: user.id }
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    let(:list) do
      fixture_file_upload "#{Rails.root}/spec/files/list.xml", 'application/xml'
    end

    subject! do
      post :create,
        params: {
          profile_id: user.to_param,
          list_import: {
            user_id: user.id,
            list: list
          }
        }
    end

    it do
      expect(resource).to be_persisted
      expect(resource.user_id).to eq user.id
      expect(response).to redirect_to list_import_url(resource)
    end
  end

  describe '#show' do
    let(:list_import) { create :list_import, user: user }
    subject! do
      get :show,
        params: {
          profile_id: user.to_param,
          idd: list_import.id
        }
    end

    it { expect(response).to have_http_status :success }
  end
end
