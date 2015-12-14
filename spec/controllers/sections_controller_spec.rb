describe SectionsController do
  include_context :authenticated, :admin
  let(:section) { seed :offtopic_section }

  describe '#index' do
    before { get :index }
    it do
      expect(response).to have_http_status :success
      expect(collection).to have(4).items
    end
  end

  describe '#edit' do
    before { get :edit, id: section.id }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:params) {{ position: 5 }}
    before { patch :update, id: section.id, section: params }

    it do
      expect(response).to redirect_to sections_url
      expect(resource).to have_attributes params
    end
  end
end
