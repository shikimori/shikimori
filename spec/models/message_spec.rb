require 'cancan/matchers'

describe Message do
  describe 'relations' do
    it { should belong_to :from }
    it { should belong_to :to }
    it { should belong_to :linked }

    it { should validate_presence_of :from }
    it { should validate_presence_of :to }
  end

  describe 'callbacks' do
    let(:user) { build_stubbed :user }

    it 'should filter nested quotes in body' do
      message = create :message, body: '[quote][quote=test][quote][/quote][/quote][/quote]', from: user, to: user
      expect(message.body).to eq('[quote][quote=test][/quote][/quote]')
    end

    describe 'antispam' do
      it 'works' do
        create :message, to: user, from: user

        expect {
          expect {
            create :message, to: user, from: user
          }.to raise_error ActiveRecord::RecordNotSaved
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
      let(:user) { create :user, nickname: 'morr' }
      let(:user2) { create :user, nickname: 'test' }
      let(:topic) { create :topic }
      let!(:comment) { create :comment, user: user2, commentable: topic }

      it 'should be on quote' do
        new_comment = nil
        expect {
          new_comment = create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
        }.to change(Message, :count).by 1

        created_message = Message.last
        expect(created_message.from_id).to eq user.id
        expect(created_message.to_id).to eq user2.id
        expect(created_message.kind).to eq MessageType::QuotedByUser
        expect(created_message.linked_id).to eq new_comment.id
        expect(created_message.linked_type).to eq new_comment.class.name
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
            new_comment = create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[comment=#{comment.id}]test[/comment]"
          }.to change(Message, :count).by 1

          created_message = Message.last
          expect(created_message.from_id).to eq user.id
          expect(created_message.to_id).to eq user2.id
          expect(created_message.kind).to eq MessageType::QuotedByUser
          expect(created_message.linked_id).to eq new_comment.id
          expect(created_message.linked_type).to eq new_comment.class.name
        end
      end
    end
  end

  describe 'instance methods' do
    let(:message) { create :message }
    before { message.delete_by user }

    context 'by from' do
      let(:user) { message.from }
      it { expect(message.src_del).to be_truthy }
      it { expect(message.dst_del).to be_falsy }
    end

    context 'by to' do
      let(:user) { message.to }
      it { expect(message.dst_del).to be_truthy }
      it { expect(message.src_del).to be_falsy }
    end
  end

  describe 'permissions' do
    let(:message) { build_stubbed :message, from: from_user, to: to_user, created_at: created_at }
    let(:from_user) { build_stubbed :user }
    let(:to_user) { build_stubbed :user }
    let(:created_at) { 1.minute.ago }
    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      it { should_not be_able_to :read, message }
      it { should_not be_able_to :create, message }
      it { should_not be_able_to :edit, message }
      it { should_not be_able_to :update, message }
      it { should_not be_able_to :destroy, message }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }

      it { should_not be_able_to :read, message }
      it { should_not be_able_to :create, message }
      it { should_not be_able_to :edit, message }
      it { should_not be_able_to :update, message }
      it { should_not be_able_to :destroy, message }

      context 'message owner' do
        let(:user) { from_user }

        it { should be_able_to :read, message }
        it { should be_able_to :create, message }
        it { should be_able_to :edit, message }
        it { should be_able_to :update, message }
        it { should be_able_to :destroy, message }

        context '11 minutes ago message' do
          let(:created_at) { 11.minutes.ago }
          it { should_not be_able_to :edit, message }
          it { should_not be_able_to :update, message }
        end
      end

      context 'message target' do
        let(:user) { to_user }

        it { should be_able_to :read, message }
        it { should_not be_able_to :create, message }
        it { should_not be_able_to :edit, message }
        it { should_not be_able_to :update, message }
        it { should be_able_to :destroy, message }
      end
    end
  end
end
