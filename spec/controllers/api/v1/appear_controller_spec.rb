describe Api::V1::AppearController do
  let!(:topic) { create :topic }
  let!(:comment) { create :comment, commentable: topic, user_id: user.id }

  describe '#create' do
    let(:user) { create :user }
    let(:submit) { post :create, params: {ids: "comment-#{comment.id}"} }

    let(:bulk_create_viewings) { double call: nil }
    before do
      allow(controller)
        .to receive(:bulk_create_viewings)
        .and_return bulk_create_viewings
    end

    context 'not authorized' do
      before { submit }
      it do
        expect(bulk_create_viewings).not_to have_received(:call)
        expect(response).to be_redirect
      end
    end

    describe 'user signed in' do
      before { sign_in user }
      before { submit }

      context 'success' do
        it { expect(response).to have_http_status :success }
      end

      context '1 viewed id' do
        it 'one view' do
          expect(bulk_create_viewings)
            .to have_received(:call)
            .with(user, Comment, [comment.id])
        end
      end

      context 'multiple viewed ids' do
        let(:comment_2) { create :comment, commentable: topic }
        let(:submit) do
          post :create, params: {
ids: [
            "comment-#{comment.id}",
            "comment-#{comment_2.id}",
            "topic-#{topic.id}"
          ].join(',')
}
        end

        it 'multiple views', :show_in_doc do
          expect(bulk_create_viewings)
            .to have_received(:call)
            .with(user, Comment, [comment.id, comment_2.id])
          expect(bulk_create_viewings)
            .to have_received(:call)
            .with(user, Topic, [topic.id])
        end
      end

      context '2 same viewed ids' do
        let(:submit) do
          post :create, params: {ids: "comment-#{comment.id}"}
          post :create, params: {ids: "comment-#{comment.id}"}
        end
        it do
          expect(bulk_create_viewings)
          .to have_received(:call)
          .with(user, Comment, [comment.id])
          .twice
        end
      end

      context 'not existing viewed id' do
        let(:submit) do
          post :create, params: { ids: 'comment-999999' }
        end
        it 'no views for not existing' do
          expect(bulk_create_viewings)
            .to have_received(:call)
            .with(user, Comment, [999_999])
        end
      end
    end
  end
end
