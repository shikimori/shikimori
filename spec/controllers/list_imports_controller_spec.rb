describe ListImportsController do
  include_context :authenticated, :user

  describe '#new' do
    before { get :new, params: { list_import: { user_id: user.id } } }
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    let(:list) do
      fixture_file_upload "#{Rails.root}/spec/files/list.xml", 'application/xml'
    end

    before do
      post :create, params: {
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
    before { get :show, params: { id: list_import.id } }

    it { expect(response).to have_http_status :success }
  end
end
