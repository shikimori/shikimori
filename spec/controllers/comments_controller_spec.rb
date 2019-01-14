describe CommentsController do
  let(:comment) { create :comment, commentable: offtopic_topic, user: user }
  let(:comment2) { create :comment, commentable: offtopic_topic, user: user }
  before do
    allow(FayePublisher)
      .to receive(:new)
      .and_return faye_publisher
  end
  let(:faye_publisher) { double FayePublisher, publish: true }

  describe '#show' do
    context 'html' do
      subject! { get :show, params: { id: comment.id } }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/html'
      end
    end

    context 'json' do
      subject! { get :show, params: { id: comment.id }, format: 'json' }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context "comment of censored club's topic" do
      let(:comment) { create :comment, commentable: topic }
      let(:topic) { create :topic, linked: club }
      let(:club) { create :club, is_censored: true }

      subject { get :show, params: { id: comment.id } }

      context 'guest' do
        it { expect { subject }.to raise_error ActiveRecord::RecordNotFound }
      end

      context 'user' do
        include_context :authenticated, :user
        before { subject }
        it { expect(response).to have_http_status :success }
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
      subject! { get :chosen, params: { ids: comment.id.to_s } }
      it { expect(response).to have_http_status :success }
    end

    describe 'multiple' do
      subject! { get :chosen, params: { ids: "#{comment.id},#{comment2.id}" } }
      it { expect(response).to have_http_status :success }
    end

    describe 'unexisted' do
      subject! { get :chosen, params: { ids: (comment2.id + 1).to_s } }
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
