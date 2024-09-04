describe Api::V1::AppearController do
  let!(:topic) { create :topic }
  let!(:comment) { create :comment, commentable: topic, user_id: user.id }

  describe '#create' do
    let(:submit) { post :create, params: { ids: "comment-#{comment.id}" } }

    before { allow(Viewing::BulkCreate).to receive :call }

    context 'not authorized' do
      subject! { submit }
      it do
        expect(Viewing::BulkCreate).not_to have_received(:call)
        expect(response).to be_redirect
      end
    end

    describe 'user signed in' do
      include_context :authenticated
      subject! { submit }

      context 'success' do
        it { expect(response).to have_http_status :success }
      end

      context '1 viewed id' do
        it 'one view' do
          expect(Viewing::BulkCreate)
            .to have_received(:call)
            .with(
              user:,
              viewed_klass: Comment,
              viewed_ids: [comment.id]
            )
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
          expect(Viewing::BulkCreate)
            .to have_received(:call)
            .with(
              user:,
              viewed_klass: Comment,
              viewed_ids: [comment.id, comment_2.id]
            )
          expect(Viewing::BulkCreate)
            .to have_received(:call)
            .with(
              user:,
              viewed_klass: Topic,
              viewed_ids: [topic.id]
            )
        end
      end

      context '2 same viewed ids' do
        let(:submit) do
          post :create, params: { ids: "comment-#{comment.id}" }
          post :create, params: { ids: "comment-#{comment.id}" }
        end
        it do
          expect(Viewing::BulkCreate)
          .to have_received(:call)
          .with(
            user:,
            viewed_klass: Comment,
            viewed_ids: [comment.id]
          )
          .twice
        end
      end

      context 'not existing viewed id' do
        let(:submit) do
          post :create, params: { ids: 'comment-999999' }
        end
        it 'no views for not existing' do
          expect(Viewing::BulkCreate)
            .to have_received(:call)
            .with(
              user:,
              viewed_klass: Comment,
              viewed_ids: [999_999]
            )
        end
      end
    end
  end
end
