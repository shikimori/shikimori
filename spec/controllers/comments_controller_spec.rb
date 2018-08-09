describe CommentsController do
  let(:user) { create :user, :user }
  let(:comment) { create :comment, commentable: offtopic_topic, user: user }
  let(:comment2) { create :comment, commentable: offtopic_topic, user: user }
  before { allow(FayePublisher).to receive(:new).and_return double(FayePublisher, publish: true) }

  describe '#show' do
    context 'html' do
      before { get :show, params: { id: comment.id } }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/html'
      end
    end

    context 'json' do
      before { get :show, params: { id: comment.id }, format: 'json' }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end
  end

  describe '#fetch' do
    it do
      get :fetch, params: { comment_id: comment.id, topic_type: Topic.name, topic_id: offtopic_topic.id, skip: 1, limit: 10 }
      expect(response).to have_http_status :success
    end

    it 'not_found for wrong comment' do
      expect do
        get :fetch, params: { comment_id: (comment.id + 1), topic_type: Topic.name, topic_id: offtopic_topic.id, skip: 1, limit: 10 }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it 'not_found for wrong topic' do
      expect do
        get :fetch, params: { comment_id: comment.id, topic_type: Topic.name, topic_id: (offtopic_topic.id + 1), skip: 1, limit: 10 }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it 'forbidden for mismatched comment and topic' do
      comment = create :comment, topic: create(:topic)
      get :fetch, params: { comment_id: comment.id, topic_type: Topic.name, topic_id: offtopic_topic.id, skip: 1, limit: 10 }
      expect(response).to be_forbidden

      get :fetch, params: { comment_id: comment.id, topic_type: Topic.name, topic_id: create(:topic).id, skip: 1, limit: 10 }
      expect(response).to be_forbidden
    end
  end

  describe '#chosen' do
    describe 'one' do
      before { get :chosen, params: { ids: comment.id.to_s } }
      it { expect(response).to have_http_status :success }
    end

    describe 'multiple' do
      before { get :chosen, params: {ids: "#{comment.id},#{comment2.id}"} }
      it { expect(response).to have_http_status :success }
    end

    describe 'unexisted' do
      before { get :chosen, params: {ids: "#{comment2.id + 1}"} }
      it { expect(response).to have_http_status :success }
    end
  end

  # describe '#postload' do
    # let(:user) { build_stubbed :user }
    # before do
      # get :postloader,
        # commentable_type: offtopic_topic.class.name,
        # commentable_id: offtopic_topic.id,
        # offset: 0,
        # limit: 1
    # end
    # it { expect(response).to have_http_status :success }
  # end
end
