describe Moderations::ForumsController do
  include_context :authenticated, :admin
  let(:forum) { seed :offtopic_forum }

  describe '#index' do
    before { get :index }
    it do
      expect(response).to have_http_status :success
      expect(collection).to have_at_least(6).items
    end
  end

  describe '#edit' do
    before { get :edit, params: { id: forum.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:params) { { position: 5 } }
    before { patch :update, params: { id: forum.id, forum: params } }

    it do
      expect(response).to redirect_to moderations_forums_url
      expect(resource).to have_attributes params
    end
  end
end
