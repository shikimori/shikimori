describe Api::V1::CommentsController do
  describe '#show' do
    let(:comment) { create :comment }
    before { get :show, id: comment.id, format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end

  describe '#index' do
    let(:user) { create :user }
    let!(:comment_1) { create :comment, user: user, commentable: user }
    let!(:comment_2) { create :comment, user: user, commentable: user }

    before { get :index, commentable_type: User.name, commentable_id: user.id, page: 1, limit: 10, desc: '1', format: :json }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
