describe Api::V2::AbuseRequestsController, :show_in_doc do
  include_context :authenticated, :user

  before { allow(AbuseRequestsService).to receive(:new).and_return abuse_requests_service }
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
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#summary' do
    subject! do
      post :summary,
        params: {
          comment_id: comment.id
        },
        format: :json
    end
    let(:abuse_requests_service) { double summary: [comment.id] }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, reporter: user
      expect(abuse_requests_service).to have_received(:summary).with(nil)

      expect(json).to eq(
        kind: 'summary',
        value: false,
        affected_ids: [comment.id]
      )
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#abuse' do
    subject! do
      post :abuse,
        params: {
          comment_id: comment.id,
          reason: reason
        },
        format: :json
    end
    let(:reason) { 'zxcv' }
    let(:abuse_requests_service) { double abuse: [comment.id] }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, review: nil, topic: nil, reporter: user
      expect(abuse_requests_service).to have_received(:abuse).with(reason)

      expect(json).to eq(
        kind: 'abuse',
        value: false,
        affected_ids: [comment.id]
      )
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#spoiler' do
    subject! do
      post :spoiler,
        params: {
          comment_id: comment.id,
          reason: reason
        },
        format: :json
    end
    let(:reason) { 'zxcv' }
    let(:abuse_requests_service) { double spoiler: [comment.id] }

    it do
      expect(AbuseRequestsService)
        .to have_received(:new)
        .with comment: comment, review: nil, topic: nil, reporter: user
      expect(abuse_requests_service).to have_received(:spoiler).with(reason)

      expect(json).to eq(
        kind: 'spoiler',
        value: false,
        affected_ids: [comment.id]
      )
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
