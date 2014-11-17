describe Moderation::AbuseRequestsController do
  let(:user) { create :user, :admin }
  before { sign_in user }

  describe '#index' do
    before { get :index }
    it { should respond_with :success }
  end

  [:review, :offtopic, :abuse, :spoiler].each do |method|
    describe method.to_s do
      let(:comment) { create :comment, user: user }

      describe 'response' do
        before { post method, comment_id: comment.id }
        it { should respond_with :success }
        it { expect(response.content_type).to eq 'application/json' }
      end

      describe 'result' do
        after { post method, comment_id: comment.id }
        it { expect_any_instance_of(AbuseRequestsService).to receive method }
      end
    end
  end
end
