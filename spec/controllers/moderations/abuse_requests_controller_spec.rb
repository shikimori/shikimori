describe Moderations::AbuseRequestsController do
  let(:user) { create :user, :moderator }
  before { sign_in user }

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    let(:abuse_request) { create :abuse_request }
    before { get :show, id: abuse_request.id }
    it { expect(response).to have_http_status :success }
  end

  [:summary, :offtopic, :abuse, :spoiler].each do |method|
    describe method.to_s do
      let(:comment) { create :comment }

      describe 'response' do
        before { post method, comment_id: comment.id, reason: 'zxcv', format: :json }

        it { expect(response).to have_http_status :success }
        it { expect(response.content_type).to eq 'application/json' }
      end

      describe 'result' do
        after { post method, comment_id: comment.id, format: :json }
        it { expect_any_instance_of(AbuseRequestsService).to receive method }
      end
    end
  end
end
