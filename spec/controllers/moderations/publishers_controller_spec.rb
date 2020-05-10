describe Moderations::PublishersController do
  include_context :authenticated, :admin
  let!(:publisher) { create :publisher }

  describe '#index' do
    subject! { get :index }
    it do
      expect(response).to have_http_status :success
      expect(collection).to have(1).item
    end
  end

  describe '#edit' do
    subject! { get :edit, params: { id: publisher.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:params) { { name: 'new description', desynced: %w[name] } }
    subject { patch :update, params: { id: publisher.id, publisher: params } }

    it do
      expect { subject }.to change(Version, :count).by 1
      expect(response).to redirect_to moderations_publishers_url
      expect(resource).to have_attributes params
    end
  end
end
