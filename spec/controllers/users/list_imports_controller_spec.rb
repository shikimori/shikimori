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
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/files/list.xml'),
        'application/xml'
      )
    end

    subject! do
      post :create,
        params: {
          profile_id: user.to_param,
          list_import: {
            user_id: user.id,
            list: list,
            duplicate_policy: Types::ListImport::DuplicatePolicy.values.first,
            list_type: Types::ListImport::ListType.values.first
          }
        }
    end

    it do
      expect(resource).to be_persisted
      expect(resource).to_not be_changed
      expect(resource.user_id).to eq user.id
      expect(response).to redirect_to profile_list_import_url(user, resource)
    end
  end

  describe '#show' do
    let(:list_import) { create :list_import, user: user, is_archived: is_archived }
    subject! do
      get :show,
        params: {
          profile_id: user.to_param,
          id: list_import.id
        }
    end

    context 'not archived' do
      let(:is_archived) { false }
      it { expect(response).to have_http_status :success }
    end

    context 'archived' do
      let(:is_archived) { true }
      it { expect(response).to redirect_to edit_profile_url(user, section: :list) }
    end
  end
end
