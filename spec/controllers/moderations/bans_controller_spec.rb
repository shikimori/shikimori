describe Moderations::BansController do
  include_context :authenticated, :forum_moderator

  let!(:comment) { create :comment }
  let!(:abuse_request) { create :abuse_request, user: user, comment: comment }

  describe '#index' do
    subject! { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    let(:ban) do
      create :ban,
        reason: 'test',
        duration: '1h',
        comment: comment,
        abuse_request: abuse_request,
        moderator: user
    end
    subject! { get :show, params: { id: ban.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    subject! do
      get :new,
        params: {
          ban: {
            comment_id: comment.id,
            user_id: comment.user_id,
            abuse_request_id: abuse_request&.id
          }
        }
    end

    context 'with abuse_request' do
      it { expect(response).to have_http_status :success }
    end

    context 'w/o abuse_request' do
      let(:abuse_request) { nil }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#create' do
    subject! do
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
      expect(json.keys).to eq %i[id abuse_request_id comment_id notice html JS_EXPORTS]
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#destroy' do
    include_context :authenticated, :super_moderator
    include_context :timecop

    let!(:ban) do
      create :ban,
        reason: 'test',
        duration: '1h',
        comment: comment,
        abuse_request: abuse_request,
        user: user_admin,
        moderator: user
    end

    subject! { delete :destroy, params: { id: ban.id } }

    it do
      expect { ban.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(user_admin.reload.read_only_at).to be_within(0.1).of Time.zone.now
      expect(response).to redirect_to moderation_profile_url(user_admin)
    end
  end
end
