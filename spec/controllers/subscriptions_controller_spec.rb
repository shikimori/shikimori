
describe SubscriptionsController do
  before (:each) do
    @user = FactoryGirl.create :user
    @topic = FactoryGirl.create :topic
    sign_in @user
  end

  describe "POST 'create'" do
    it "should be successful" do
      post 'create', :id => @topic.id, :type => @topic.class.name
      response.should be_success

      User.find(@user.id).subscribed?(@topic).should be_true
    end
  end

  describe "DELETE 'destroy'" do
    it "should be successful" do
      @user.subscribe(@topic)

      delete 'destroy', :id => @topic.id, :type => @topic.class.name
      response.should be_success

      User.find(@user.id).subscribed?(@topic).should be_false
    end
  end
end
