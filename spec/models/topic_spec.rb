describe Topic, :type => :model do
  context '#validations' do
    it { should validate_presence_of :title }
  end

  let (:user) { create :user }
  let (:topic) { create :topic, :user => user }

  it 'creation subscribes author to self' do
    expect { topic }.to change(Subscription, :count).by 1
    expect(user.subscribed?(topic)).to be_truthy
  end

  describe 'permissions' do
    let (:user2) { create :user }

    describe "with owner" do
      it "can be edited" do
        expect(topic.can_be_edited_by?(user)).to be_truthy
      end

      it "can be deleted" do
        expect(topic.can_be_deleted_by?(user)).to be_truthy
      end
    end

    describe "with admin" do
      let (:admin_user) { create :user }

      before (:each) do
        allow(admin_user).to receive(:admin?).and_return(true)
        allow(admin_user).to receive(:moderator?).and_return(true)
      end

      it "can be edited" do
        expect(topic.can_be_edited_by?(admin_user)).to be_truthy
      end

      it "can be deleted" do
        expect(topic.can_be_deleted_by?(admin_user)).to be_truthy
      end
    end
  end
end
