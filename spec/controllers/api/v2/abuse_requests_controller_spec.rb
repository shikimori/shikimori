describe Api::V2::AbuseRequestsController, :show_in_doc do
  include_context :authenticated, :user

  before do
    allow(AbuseRequestsService)
      .to receive(:new)
      .and_return abuse_requests_service
  end
  let(:comment) { create :comment }

  describe '#offtopic' do
    subject! do
      post :offtopic,
        params: {
          comment_id: comment.id
        },
        format: :json
    end
    let(:abuse_requests_service) { double offtopic: [comment.id] }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, reporter: user
      expect(abuse_requests_service).to have_received(:offtopic).with(nil)

      expect(json).to eq(
        kind: 'offtopic',
        value: false,
        affected_ids: [comment.id]
      )
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#convert_review' do
    subject! do
      post :convert_review,
        params: (
          comment ? { comment_id: comment.id } : { topic_id: topic.id }
        )
    end
    let(:reason) { 'zxcv' }
    let(:abuse_requests_service) { double convert_review: nil }
    let(:comment) do
      [
        create(:comment),
        nil
      ].sample
    end
    let(:topic) { create :topic unless comment }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, topic: topic, reporter: user
      expect(abuse_requests_service).to have_received(:convert_review).with(nil)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#abuse' do
    subject! do
      post :abuse,
        params: {
          comment_id: comment.id,
          reason: reason
        }
    end
    let(:reason) { 'zxcv' }
    let(:abuse_requests_service) { double abuse: [comment.id] }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, topic: nil, reporter: user
      expect(abuse_requests_service).to have_received(:abuse).with(reason)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#spoiler' do
    subject! do
      post :spoiler,
        params: {
          comment_id: comment.id,
          reason: reason
        }
    end
    let(:reason) { 'zxcv' }
    let(:abuse_requests_service) { double spoiler: [comment.id] }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, topic: nil, reporter: user
      expect(abuse_requests_service).to have_received(:spoiler).with(reason)
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end
end
