describe Api::V1::CommentsController do
  let(:user) { create :user, :user }
  let(:topic) { create :entry, user: user }
  let(:comment) { create :comment, commentable: topic, user: user }

  describe '#show', :show_in_doc do
    before { get :show, id: comment.id, format: :json }

    it do
      expect(json).to have_key :user
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#index', :show_in_doc do
    let!(:comment_1) { create :comment, user: user, commentable: user }
    let!(:comment_2) { create :comment, user: user, commentable: user }

    before { get :index, commentable_type: User.name, commentable_id: user.id, page: 1, limit: 10, desc: '1', format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  shared_examples_for :created_or_updated_comment do
    it do
      expect(assigns(:comment)).to be_persisted
      expect(assigns(:comment)).to have_attributes(comment_params)
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  shared_examples_for :frontend_response do
    it { expect(response.body).to include '"html"' }
    it { expect(response.body).not_to include '"review"' }
  end

  shared_examples_for :api_response do
    it { expect(response.body).not_to include '"html"' }
    it { expect(response.body).to include '"review"' }
  end

  describe '#create' do
    before { sign_in user }

    context 'success' do
      let(:comment_params) do
        {
          commentable_id: topic.id,
          commentable_type: 'Entry',
          body: 'x' * Comment::MIN_SUMMARY_SIZE,
          is_offtopic: true,
          is_summary: true
        }
      end

      context 'frontend' do
        before { post :create, frontend: true, comment: comment_params, format: :json }
        it_behaves_like :created_or_updated_comment
        it_behaves_like :frontend_response
      end

      context 'api', :show_in_doc do
        before { post :create, comment: comment_params, format: :json }
        it_behaves_like :created_or_updated_comment
        it_behaves_like :api_response
      end
    end

    context 'failure' do
      before do
        post :create,
          comment: { body: 'test', is_offtopic: false, is_summary: false },
          format: :json
      end

      it do
        expect(response).to have_http_status 422
        expect(response.content_type).to eq 'application/json'
      end
    end
  end

  describe '#update' do
    before { sign_in user }

    context 'success' do
      let(:comment_params) { { body: 'blablabla' } }

      context 'frontend' do
        before { patch :update, id: comment.id, frontend: true, comment: comment_params, format: :json }
        it_behaves_like :created_or_updated_comment
        it_behaves_like :frontend_response
      end

      context 'api', :show_in_doc do
        before { patch :update, id: comment.id, comment: comment_params, format: :json }
        it_behaves_like :created_or_updated_comment
        it_behaves_like :api_response
      end
    end

    context 'forbidden' do
      let(:request) { patch :update, id: comment.id, comment: { body: 'a' } }
      let(:comment) { create :comment, commentable: topic }

      it { expect{request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#destroy' do
    before { sign_in user }
    let(:make_request) { delete :destroy, id: comment.id, format: :json }

    context 'success', :show_in_doc do
      before { make_request }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
        expect(json[:notice]).to eq 'Комментарий удален'
      end
    end

    context 'forbidden' do
      let(:comment) { create :comment, commentable: topic }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end
end
