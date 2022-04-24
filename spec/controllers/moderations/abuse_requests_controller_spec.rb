describe Moderations::AbuseRequestsController do
  include_context :authenticated, :forum_moderator
  let!(:abuse_request) do
    create :abuse_request, :pending, :offtopic,
      comment: comment,
      reason: reason
  end
  let(:comment) { create :comment, user: user_2 }
  let(:reason) { nil }

  describe '#index' do
    subject! { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    let(:abuse_request) { create :abuse_request }

    describe 'html' do
      subject! { get :show, params: { id: abuse_request.id } }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end

    describe 'json' do
      subject! { get :show, params: { id: abuse_request.id }, format: :json }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end
    end
  end

  describe '#accept' do
    subject! do
      post :accept,
        params: { id: abuse_request.id },
        xhr: true,
        format: :json
    end

    it do
      expect(resource).to be_accepted
      expect(resource.approver).to eq user
      expect(comment.reload).to be_offtopic
      expect(resource).to_not be_changed
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#reject' do
    subject! do
      post :reject,
        params: { id: abuse_request.id },
        xhr: true,
        format: :json
    end

    it do
      expect(resource).to be_rejected
      expect(resource.approver).to eq user
      expect(comment.reload).to_not be_offtopic
      expect(resource).to_not be_changed
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#cleanup' do
    subject! do
      post :cleanup,
        params: { id: abuse_request.id },
        xhr: true,
        format: :json
    end
    let(:reason) { 'zxc' }

    it do
      expect(resource.reason).to be_nil
      expect(resource).to_not be_changed
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
