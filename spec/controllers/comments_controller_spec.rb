describe CommentsController do
  let(:user) { create :user, :user }
  let(:topic) { seed :topic }
  let(:comment) { create :comment, commentable: topic, user: user }
  let(:comment2) { create :comment, commentable: topic, user: user }
  before { allow(FayePublisher).to receive(:new).and_return double(FayePublisher, publish: true) }

  describe '#show' do
    context 'html' do
      before { get :show, id: comment.id }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/html'
      end
    end

    context 'json' do
      before { get :show, id: comment.id, format: 'json' }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end
  end

  describe '#create' do
    before { sign_in user }

    context 'success' do
      let(:comment_params) {{ commentable_id: topic.id, commentable_type: 'Entry', body: 'x'*Comment::MIN_REVIEW_SIZE, offtopic: true, review: true }}
      before { post :create, comment: comment_params }

      it do
        expect(assigns(:comment)).to be_persisted
        expect(assigns(:comment)).to have_attributes(comment_params)
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'failure' do
      before { post :create, comment: { body: 'test', offtopic: false, review: false } }

      it do
        expect(response).to have_http_status 422
        expect(response.content_type).to eq 'application/json'
      end
    end
  end

  describe '#edit' do
    before { sign_in user }
    before { get :edit, id: comment.id }

    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    before { sign_in user }
    let(:make_request) { patch :update, id: comment.id, comment: { body: 'testzxc' } }

    context 'success' do
      before { make_request }

      it do
        expect(assigns(:comment).body).to eq 'testzxc'
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'forbidden' do
      let(:comment) { create :comment, commentable: topic }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#destroy' do
    before { sign_in user }
    let(:make_request) { delete :destroy, id: comment.id }

    context 'success' do
      before { make_request }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'forbidden' do
      let(:comment) { create :comment, commentable: topic }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#fetch' do
    let(:user) { build_stubbed :user }
    let(:topic) { create :entry, user: user }

    it do
      get :fetch, comment_id: comment.id, topic_type: Entry.name, topic_id: topic.id, skip: 1, limit: 10
      expect(response).to be_success
    end

    it 'not_found for wrong comment' do
      expect {
        get :fetch, comment_id: comment.id+1, topic_type: Entry.name, topic_id: topic.id, skip: 1, limit: 10
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'not_found for wrong topic' do
      expect {
        get :fetch, comment_id: comment.id, topic_type: Entry.name, topic_id: topic.id+1, skip: 1, limit: 10
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'forbidden for mismatched comment and topic' do
      get :fetch, comment_id: create(:comment).id, topic_type: Entry.name, topic_id: topic.id, skip: 1, limit: 10
      expect(response).to be_forbidden

      get :fetch, comment_id: comment.id, topic_type: Entry.name, topic_id: create(:entry).id, skip: 1, limit: 10
      expect(response).to be_forbidden
    end
  end

  describe '#chosen' do
    describe 'one' do
      before { get :chosen, ids: "#{comment.id}" }
      it { expect(response).to have_http_status :success }
    end

    describe 'multiple' do
      before { get :chosen, ids: "#{comment.id},#{comment2.id}" }
      it { expect(response).to have_http_status :success }
    end

    describe 'unexisted' do
      before { get :chosen, ids: "#{comment2.id+1}" }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#postload' do
    let(:user) { build_stubbed :user }
    before { get :postloader, commentable_type: topic.class.name, commentable_id: topic.id, offset: 0, limit: 1 }
    it { expect(response).to have_http_status :success }
  end
end
