require 'spec_helper'

describe Moderation::BansController do
  before { sign_in user }

  let(:user) { create :user, id: 1 }
  let(:comment) { create :comment, user: user }
  let(:abuse_request) { create :abuse_request, user: user, comment: comment }

  describe :index do
    before { get :index }
    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :new do
    context :moderator do
      context :with_abuse_request do
        before { get :new, comment_id: comment.id, abuse_request_id: abuse_request.id }

        it { should respond_with :success }
        it { should respond_with_content_type :html }
      end

      context :wo_abuse_request do
        before { get :new, comment_id: comment.id }

        it { should respond_with :success }
      end
    end
  end

  describe :create do
    context :moderator do
      before { post :create, ban: { reason: 'test', duration: '1h', comment_id: comment.id, abuse_request_id: abuse_request.id } }

      it { should respond_with :success }
      it { should respond_with_content_type :json }
    end
  end
end
