require 'spec_helper'

describe Api::V1::CommentsController do
  describe :show do
    let(:comment) { create :comment }
    before { get :show, id: comment.id }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end

  describe :index do
    let(:user) { create :user }
    let!(:comment_1) { create :comment, user: user, commentable: user }
    let!(:comment_2) { create :comment, user: user, commentable: user }

    before { get :index, commentable_type: User.name, commentable_id: user.id, page: 1, limit: 10, desc: '1' }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
