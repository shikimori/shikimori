describe Moderations::AbuseRequestsController do
  include_context :authenticated, :forum_moderator

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    let(:abuse_request) { create :abuse_request }

    describe 'html' do
      before { get :show, params: { id: abuse_request.id } }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      before { get :show, params: { id: abuse_request.id }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end
end
