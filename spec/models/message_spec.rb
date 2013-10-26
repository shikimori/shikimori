require 'spec_helper'

describe Message do
  it { should belong_to :src }
  it { should belong_to :dst }
  it { should belong_to :linked }

  it { should validate_presence_of :src }
  it { should validate_presence_of :dst }

  let(:user) { build_stubbed :user }

  it 'should filter nested quotes in body' do
    message = create :message, body: '[quote][quote=test][quote][/quote][/quote][/quote]', src: user, dst: user
    message.body.should == '[quote][quote=test][/quote][/quote]'
  end

  describe 'antispam' do
    it 'works' do
      create :message, dst: user, src: user

      expect {
        lambda {
          create :message, dst: user, src: user
        }.should raise_error ActiveRecord::RecordNotSaved
      }.to_not change(Message, :count)
    end

    it 'can be disabled' do
      create :message, dst: user, src: user

      expect {
        Message.wo_antispam do
          create :message, dst: user, src: user
        end
      }.to change(Message, :count).by(1)
    end

    it 'disabled for MessageType::Notification' do
      create :message, dst: user, src: user, kind: MessageType::Notification

      expect {
        create :message, dst: user, src: user, kind: MessageType::Notification
      }.to change(Message, :count).by(1)
    end

    it 'disabled for MessageType::GroupRequest' do
      create :message, dst: user, src: user, kind: MessageType::GroupRequest

      expect {
        create :message, dst: user, src: user, kind: MessageType::Notification
      }.to change(Message, :count).by(1)
    end
  end

  describe MessageType::QuotedByUser do
    let (:user) { create :user, nickname: 'morr' }
    let (:user2) { create :user, nickname: 'test' }
    let (:topic) { create :topic }
    before(:each) do
      @comment = create :comment, user: user2, commentable: topic
    end

    it 'should be on quote' do
      new_comment = nil
      expect {
        new_comment = create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
      }.to change(Message, :count).by(1)

      created_message = Message.last
      created_message.src_id.should eq(user.id)
      created_message.src_type.should  == user.class.name
      created_message.dst_id.should eq(user2.id)
      created_message.dst_type.should  == user2.class.name
      created_message.kind.should == MessageType::QuotedByUser
      created_message.linked_id.should eq(new_comment.id)
      created_message.linked_type.should == new_comment.class.name
    end

    it 'should not be on quote if notification is already exists' do
      create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
      expect {
        Comment.wo_antispam do
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
        end
      }.to_not change(Message, :count)
    end

    it 'should not be on nested quote' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=test][quote=morr]\r\nrte[/quote]\r\ntest[/quote]\r\ntest"
      }.to change(Message, :count).by(1)
    end

    it '2.times should be on multiple quote' do
      user22 = create :user
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote][quote=#{user22.nickname}]test[/quote]"
      }.to change(Message, :count).by(2)
    end

    it '1.time should be on multiple quote for one user' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote][quote=#{user2.nickname}]test[/quote]"
      }.to change(Message, :count).by(1)
    end

    it 'should not be on non existed user' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=zxc]test[/quote]"
      }.to_not change(Message, :count)
    end

    it 'should not be on nested quote' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=zxc][quote=#{user2.nickname}]test[/quote]asd[quote=#{user2.nickname}]test[/quote][/quote]"
      }.to_not change(Message, :count)
    end

    it 'should not be on self quote' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user.nickname}]test[/quote]"
      }.to_not change(Message, :count)
    end

    describe 'RepliedByUser' do
      it 'should be on reply' do
        new_comment = nil
        expect {
          new_comment = create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[comment=#{@comment.id}]test[/comment]"
        }.to change(Message, :count).by(1)

        created_message = Message.last
        created_message.src_id.should eq(user.id)
        created_message.src_type.should  == user.class.name
        created_message.dst_id.should eq(user2.id)
        created_message.dst_type.should  == user2.class.name
        created_message.kind.should == MessageType::QuotedByUser
        created_message.linked_id.should eq(new_comment.id)
        created_message.linked_type.should == new_comment.class.name
      end
    end
  end

  #describe MessageType::SubscriptionCommented do
    #let (:user) { create :user, nickname: 'morr' }
    #let (:user2) { create :user, nickname: 'test' }
    #let (:topic) { create :topic }
    #before(:each) do
      #user.subscribe(topic)
    #end

    #it 'should be on comment' do
      #expect {
        #create :comment, user: user2, commentable: topic
      #}.to change(Message, :count).by(1)

      #created_message = Message.last
      #created_message.src_id.should eq(user2.id)
      #created_message.src_type.should  == user2.class.name
      #created_message.dst_id.should eq(user.id)
      #created_message.dst_type.should  == user.class.name
      #created_message.kind.should == MessageType::SubscriptionCommented
      #created_message.linked_id.should eq(topic.id)
      #created_message.linked_type.should == topic.class.name
    #end

    #it 'should be 1.time on two comments' do
      #expect {
        #Comment.wo_antispam do
          #create :comment, user: user2, commentable: topic
          #create :comment, user: user2, commentable: topic
        #end
      #}.to change(Message, :count).by(1)
    #end

    #it 'should be 2.times on two comments if first was read' do
      #expect {
        #Comment.wo_antispam do
          #create :comment, user: user2, commentable: topic
          #Message.last.update_attribute(:read, true)
          #create :comment, user: user2, commentable: topic
          #create :comment, user: user2, commentable: topic
        #end
      #}.to change(Message, :count).by(2)
    #end

    #it 'should be 2.times for 2 users' do
      #user3 = create :user
      #user3.subscribe(topic)

      #expect {
        #create :comment, user: user2, commentable: topic
      #}.to change(Message, :count).by(2)
    #end

    #it 'should not be for unsubscribed user' do
      #user.unsubscribe(topic)
      #expect {
        #create :comment, user: user2, commentable: topic
      #}.to_not change(Message, :count)
    #end

    #it 'should not be on own comment' do
      #expect {
        #create :comment, user: user, commentable: topic
      #}.to_not change(Message, :count)
    #end
  #end
end
