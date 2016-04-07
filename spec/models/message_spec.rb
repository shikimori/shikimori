require 'cancan/matchers'

describe Message do
  describe 'relations' do
    it { is_expected.to belong_to :from }
    it { is_expected.to belong_to :to }
    it { is_expected.to belong_to :linked }

    it { is_expected.to validate_presence_of :from }
    it { is_expected.to validate_presence_of :to }
  end

  before(:all) { Message.antispam = false }
  after(:all) { Message.antispam = true }

  describe 'callbacks' do
    let(:user) { build_stubbed :user, :user }

    describe 'antispam' do
      before { Message.antispam = true }
      after { Message.antispam = false }

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
        create :message, to: user, from: user, kind: MessageType::ClubRequest

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

      it 'is_expected.to be on quote' do
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

      #it 'is_expected.to not be on quote if notification is already exists' do
        #create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
        #expect {
          #Comment.wo_antispam do
            #create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote]"
          #end
        #}.to_not change Message, :count
      #end

      it 'is_expected.to not be on nested quote' do
        expect {
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=test][quote=morr]\r\nrte[/quote]\r\ntest[/quote]\r\ntest"
        }.to change(Message, :count).by 1
      end

      it '2.times is_expected.to be on multiple quote' do
        user22 = create :user
        expect {
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote][quote=#{user22.nickname}]test[/quote]"
        }.to change(Message, :count).by 2
      end

      it '1.time is_expected.to be on multiple quote for one user' do
        expect {
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user2.nickname}]test[/quote][quote=#{user2.nickname}]test[/quote]"
        }.to change(Message, :count).by 1
      end

      it 'is_expected.to not be on non existed user' do
        expect {
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=zxc]test[/quote]"
        }.to_not change(Message, :count)
      end

      it 'is_expected.to not be on nested quote' do
        expect {
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=zxc][quote=#{user2.nickname}]test[/quote]asd[quote=#{user2.nickname}]test[/quote][/quote]"
        }.to_not change(Message, :count)
      end

      it 'is_expected.to not be on self quote' do
        expect {
          create :comment, :with_notify_quotes, user: user, commentable: topic, body: "[quote=#{user.nickname}]test[/quote]"
        }.to_not change(Message, :count)
      end

      describe 'RepliedByUser' do
        it 'is_expected.to be on reply' do
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

    describe 'after_create' do
      describe '#send_email' do
        let(:message) { build :message, kind: kind }

        before { allow(EmailNotifier.instance).to receive :private_message }
        before { message.save! }

        context 'private message' do
          let(:kind) { MessageType::Private }
          it { expect(EmailNotifier.instance)
            .to have_received(:private_message).with message }
        end

        context 'common message' do
          let(:kind) { MessageType::Notification }
          it { expect(EmailNotifier.instance)
            .to_not have_received(:private_message) }
        end
      end

      describe '#send_push_notifications' do
        let(:message) { build :message, :with_push_notifications, to: user }
        let(:user) { build :user, devices: devices }

        before { allow(PushNotification).to receive :perform_async }
        before { message.save! }

        context 'no devices' do
          let(:devices) { [] }
          it { expect(PushNotification).to_not have_received :perform_async }
        end

        context 'with devices' do
          let(:devices) { [device_1, device_2] }
          let(:device_1) { build :device }
          let(:device_2) { build :device }
          it do
            expect(PushNotification).to have_received(:perform_async)
              .with(message.id, device_1.id).ordered
            expect(PushNotification).to have_received(:perform_async)
              .with(message.id, device_2.id).ordered
          end
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#delete_by' do
      let(:message) { create :message, to: build_stubbed(:user), from: build_stubbed(:user) }
      before { message.delete_by user }

      context 'private message' do
        context 'by from' do
          let(:user) { message.from }

          it { expect(message).to be_persisted }
          it { expect(message.is_deleted_by_from).to be_truthy }
          it { expect(message.is_deleted_by_to).to be_falsy }
          it { expect(message).to_not be_read }
        end

        context 'by to' do
          let(:user) { message.to }

          it { expect(message).to be_persisted }
          it { expect(message.is_deleted_by_to).to be_truthy }
          it { expect(message.is_deleted_by_from).to be_falsy }
          it { expect(message).to be_read }
        end
      end

      context 'other messages' do
        let(:message) { create :message, :notification }
        let(:user) { nil }
        it { expect(message).to be_destroyed }
      end
    end
  end

  describe 'permissions' do
    let(:message) { build_stubbed :message, from: from_user, to: to_user, kind: kind, created_at: created_at }
    let(:from_user) { build_stubbed :user, :user }
    let(:to_user) { build_stubbed :user, :user }
    let(:created_at) { 1.minute.ago }
    let(:kind) { MessageType::Private }

    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      it { is_expected.to_not be_able_to :read, message }
      it { is_expected.to_not be_able_to :mark_read, message }
      it { is_expected.to_not be_able_to :create, message }
      it { is_expected.to_not be_able_to :edit, message }
      it { is_expected.to_not be_able_to :update, message }
      it { is_expected.to_not be_able_to :destroy, message }

      context 'message to admin' do
        let(:message) { build_stubbed :message, from_id: User::GUEST_ID, to_id: User::ADMINS.first, kind: MessageType::Private }
        it { is_expected.to be_able_to :create, message }
      end
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }

      it { is_expected.to be_able_to :mark_read, message }
      it { is_expected.to_not be_able_to :read, message }
      it { is_expected.to_not be_able_to :create, message }
      it { is_expected.to_not be_able_to :edit, message }
      it { is_expected.to_not be_able_to :update, message }
      it { is_expected.to_not be_able_to :destroy, message }

      context 'message owner' do
        let(:user) { from_user }

        it { is_expected.to be_able_to :read, message }

        context 'private message' do
          let(:kind) { MessageType::Private }

          context 'not banned forever' do
            let(:from_user) { build_stubbed :user, :user, :banned }
            it { is_expected.to be_able_to :create, message }
          end

          context 'banned forever' do
            let(:from_user) { build_stubbed :user, :user, :forever_banned }
            it { is_expected.to_not be_able_to :create, message }
          end

          it { is_expected.to be_able_to :edit, message }
          it { is_expected.to be_able_to :update, message }
          it { is_expected.to be_able_to :destroy, message }

          #context 'new message' do
            #let(:created_at) { 1.minute.ago }
            #it { is_expected.to be_able_to :destroy, message }
          #end

          #context 'old message' do
            #let(:created_at) { 11.minute.ago }
            #it { is_expected.to_not be_able_to :destroy, message }
          #end
        end

        context 'other type messages' do
          let(:kind) { MessageType::Notification }
          it { is_expected.to_not be_able_to :create, message }
          it { is_expected.to_not be_able_to :edit, message }
          it { is_expected.to_not be_able_to :update, message }
          it { is_expected.to be_able_to :destroy, message }
        end

        context '11 minutes ago message' do
          let(:created_at) { 11.minutes.ago }
          it { is_expected.to_not be_able_to :edit, message }
          it { is_expected.to_not be_able_to :update, message }
          it { is_expected.to be_able_to :destroy, message }
        end
      end

      context 'message target' do
        let(:user) { to_user }

        it { is_expected.to be_able_to :read, message }
        it { is_expected.to_not be_able_to :create, message }
        it { is_expected.to_not be_able_to :edit, message }
        it { is_expected.to_not be_able_to :update, message }

        context 'private message' do
          let(:kind) { MessageType::Private }

          context 'new message' do
            let(:created_at) { 1.minute.ago }
            it { is_expected.to be_able_to :destroy, message }
          end

          context 'old message' do
            let(:created_at) { 11.minute.ago }
            it { is_expected.to be_able_to :destroy, message }
          end
        end

        context 'other type message' do
          let(:kind) { MessageType::Notification }
          it { is_expected.to be_able_to :destroy, message }
        end
      end
    end
  end
end
