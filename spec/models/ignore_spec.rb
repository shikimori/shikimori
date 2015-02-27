describe Ignore do
  it { should belong_to :user }
  it { should belong_to :target }

  #it 'should mark as read messages from blocked user' do
    #user = FactoryGirl.create :user
    #blocked = FactoryGirl.create :user
    #message = FactoryGirl.create :message, :src => blocked, :dst => user
    #message.read.should be(false)

    #user.ignored_users << blocked

    #Message.find(message.id).read.should be(true)
  #end
end
