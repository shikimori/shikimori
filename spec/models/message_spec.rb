describe Message do
  it { should belong_to :from }
  it { should belong_to :to }
  it { should belong_to :linked }

  it { should validate_presence_of :from }
  it { should validate_presence_of :to }

  let(:user) { build_stubbed :user }

  it 'should filter nested quotes in body' do
    message = create :message, body: '[quote][quote=test][quote][/quote][/quote][/quote]', from: user, to: user
    message.body.should == '[quote][quote=test][/quote][/quote]'
  end

  describe 'antispam' do
    it 'works' do
      create :message, to: user, from: user

      expect {
        lambda {
          create :message, to: user, from: user
        }.should raise_error ActiveRecord::RecordNotSaved
      }.to_not change Message, :count
    end

    it 'can be disabled' do
      create :message, to: user, from: user

      expect {
        Message.wo_antispam do
          create :message, to: user, from: user
        end
      }.to change(Message, :count).by 1
    end

    it 'disabled for MessageType::Notification' do
      create :message, to: user, from: user, kind: MessageType::Notification

      expect {
        create :message, to: user, from: user, kind: MessageType::Notification
      }.to change(Message, :count).by 1
    end

    it 'disabled for MessageType::GroupRequest' do
      create :message, to: user, from: user, kind: MessageType::GroupRequest

      expect {
        create :message, to: user, from: user, kind: MessageType::Notification
      }.to change(Message, :count).by 1
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
      }.to change(Message, :count).by 1

      created_message = Message.last
      created_message.from_id.should eq user.id
      created_message.to_id.should eq user2.id
      created_message.kind.should eq MessageType::QuotedByUser
      created_message.linked_id.should eq new_comment.id
      created_message.linked_type.should eq new_comment.class.name
    end

    it 'should not be on quote if notification is already exists' do
      create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
      expect {
        Comment.wo_antispam do
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
        end
      }.to_not change Message, :count
    end

    it 'should not be on nested quote' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=test][quote=morr]\r\nrte[/quote]\r\ntest[/quote]\r\ntest"
      }.to change(Message, :count).by 1
    end

    it '2.times should be on multiple quote' do
      user22 = create :user
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote][quote=#{user22.nickname}]test[/quote]"
      }.to change(Message, :count).by 2
    end

    it '1.time should be on multiple quote for one user' do
      expect {
        create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote][quote=#{user2.nickname}]test[/quote]"
      }.to change(Message, :count).by 1
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
        }.to change(Message, :count).by 1

        created_message = Message.last
        created_message.from_id.should eq user.id
        created_message.to_id.should eq user2.id
        created_message.kind.should eq MessageType::QuotedByUser
        created_message.linked_id.should eq new_comment.id
        created_message.linked_type.should eq new_comment.class.name
      end
    end
  end
end
