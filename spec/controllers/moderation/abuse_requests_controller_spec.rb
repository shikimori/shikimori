require 'spec_helper'

describe Moderation::AbuseRequestsController do
  before { sign_in create(:user, id: 1) }

  describe :index do
    before { get :index }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  [:review, :offtopic, :abuse, :spoiler].each do |method|
    describe method do
      let(:comment) { create :comment }

      context :response do
        before { post method, comment_id: comment.id }
        it { should respond_with :success }
        it { should respond_with_content_type :json }
      end

      context :result do
        after { post method, comment_id: comment.id }
        it { AbuseRequestsService.any_instance.should_receive method }
      end
    end
  end
end
