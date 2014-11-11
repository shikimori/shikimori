
describe SubscriptionsController, :type => :controller do
  before (:each) do
    @user = FactoryGirl.create :user
    @topic = FactoryGirl.create :topic
    sign_in @user
  end

  describe "POST 'create'" do
    it "should be successful" do
      post 'create', :id => @topic.id, :type => @topic.class.name
      expect(response).to be_success

      expect(User.find(@user.id).subscribed?(@topic)).to be_truthy
    end
  end

  describe "DELETE 'destroy'" do
    it "should be successful" do
      @user.subscribe(@topic)

      delete 'destroy', :id => @topic.id, :type => @topic.class.name
      expect(response).to be_success

      expect(User.find(@user.id).subscribed?(@topic)).to be_falsy
    end
  end
end
