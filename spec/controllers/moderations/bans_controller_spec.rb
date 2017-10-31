describe Moderations::BansController do
  include_context :authenticated, :forum_moderator

  let!(:comment) { create :comment }
  let!(:abuse_request) { create :abuse_request, user: user, comment: comment }

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    context 'moderator' do
      context 'with abuse_request' do
        before do
          get :new,
            params: {
              comment_id: comment.id,
              abuse_request_id: abuse_request.id
            }
        end
        it { expect(response).to have_http_status :success }
      end

      context 'wo abuse_request' do
        before { get :new, params: { comment_id: comment.id } }
        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#create' do
    context 'moderator' do
      before do
        post :create,
          params: {
            ban: {
              reason: 'test',
              duration: '1h',
              comment_id: comment.id,
              abuse_request_id: abuse_request.id
            }
          }
      end

      it do
        expect(response).to have_http_status :success
        expect(json.keys).to eq %i[id abuse_request_id comment_id notice html]
        expect(response.content_type).to eq 'application/json'
      end
    end
  end
end
