describe CommentsController do
  let(:comment) { create :comment, commentable: offtopic_topic, user: user }
  let(:comment_2) { create :comment, commentable: offtopic_topic, user: user }
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
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end

    context 'json' do
      subject! { get :show, params: { id: comment.id }, format: 'json' }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end
    end

    context "comment of censored club's topic" do
      let(:comment) { create :comment, commentable: topic }
      let(:topic) { create :topic, linked: club }
      let(:club) { create :club, is_censored: true }

      subject { get :show, params: { id: comment.id } }

      context 'guest' do
        before { subject }
        it do
          expect(resource).to_not be NoComment
          expect(response).to have_http_status :success
        end
      end

      context 'user' do
        include_context :authenticated, :user
        before { subject }
        it do
          expect(resource).to_not be NoComment
          expect(response).to have_http_status :success
        end
      end
    end
  end

  describe '#tooltip' do
    subject! { get :tooltip, params: { id: comment.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#fetch' do
    subject do
      get :fetch,
        params: {
          comment_id: comment_id,
          topic_type: Topic.name,
          topic_id: topic_id,
          skip: 1,
          limit: 10
        }
    end
    let(:comment_id) { comment.id }
    let(:topic_id) { offtopic_topic.id }

    describe do
      before { subject }
      it { expect(response).to have_http_status :success }
    end

    context 'non existing comment' do
      let(:comment_id) { comment.id + 999 }
      it { expect { subject }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'non existing topic' do
      let(:topic_id) { offtopic_topic.id + 999 }
      it { expect { subject }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'comment of another topic' do
      let(:comment_id) { comment_2.id }
      let(:comment_2) { create :comment, topic: create(:topic) }
      it { expect { subject }.to raise_error CanCan::AccessDenied }
    end

    context 'topic of another comment' do
      let(:topic_id) { topic_2.id }
      let(:topic_2) { create :topic }
      it { expect { subject }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#replies' do
    subject do
      get :replies,
        params: {
          comment_id: comment_id,
          skip: 1,
          limit: 10
        }
    end
    let(:comment_id) { comment.id }

    describe do
      before { subject }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#chosen' do
    describe 'one' do
      subject! { get :chosen, params: { ids: comment.id.to_s } }
      it { expect(response).to have_http_status :success }
    end

    describe 'multiple' do
      subject! { get :chosen, params: { ids: "#{comment.id},#{comment_2.id}" } }
      it { expect(response).to have_http_status :success }
    end

    describe 'unexisted' do
      subject! { get :chosen, params: { ids: (comment_2.id + 1).to_s } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#edit' do
    include_context :authenticated, :forum_moderator
    subject! { get :edit, params: { id: comment.id } }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end
  end
end
