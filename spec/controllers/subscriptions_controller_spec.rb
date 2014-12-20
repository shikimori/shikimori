describe SubscriptionsController do
  include_context :authenticated, :user
  let(:topic) { create :topic }

  #describe '#create' do
    #before { post :create, id: topic.id, type: topic.class.name }

    #it { should respond_with :success }
    #it { expect(user.reload.subscribed?(topic)).to be_truthy }
  #end

  describe '#destroy' do
    let!(:subscription) { create :subscription, user: user, target: topic }
    before { delete :destroy, id: topic.id, type: topic.class.name }

    it { should respond_with :success }
    it { expect(user.reload.subscribed?(topic)).to be_falsy }
  end
end
