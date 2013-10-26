require 'spec_helper'

describe Comment do
  context :relations do
    it { should belong_to :user }
    it { should belong_to :commentable }
    it { should have_many :messages }
    it { should have_many :views }
    it { should have_many :abuse_requests }
  end

  context :validations do
    it { should validate_presence_of :body }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :commentable_id }
    it { should validate_presence_of :commentable_type }
  end

  let(:user) { build_stubbed :user }
  let(:user2) { build_stubbed :user }
  let(:topic) { build_stubbed :entry, user: user }
  let(:comment) { create :comment, user: user, commentable: topic }

  context :hooks do
    describe :check_access do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :clean }
    end

    describe :forbid_ban_change do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :forbid_ban_change }
    end

    describe :check_access do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :check_access }
    end

    describe :filter_quotes do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :filter_quotes }
    end

    describe :increment_comments do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :increment_comments }
    end

    describe :creation_callbacks do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :creation_callbacks }
    end

    describe :subscribe do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :subscribe }
    end

    describe :notify_quotes do
      let(:comment) { build :comment }
      after { comment.save }
      it { comment.should_receive :notify_quotes }
    end

    describe :decrement_comments do
      let(:comment) { create :comment }
      after { comment.destroy }
      it { comment.should_receive :decrement_comments }
    end

    describe :destruction_callbacks do
      let(:comment) { create :comment }
      after { comment.destroy }
      it { comment.should_receive :destruction_callbacks }
    end
  end

  describe :subscribe do
    let(:user) { create :user }
    let(:topic) { create :entry, user: user }
    subject!(:comment) { create :comment, :with_subscribe, user: user, commentable: topic }
    it { user.subscribed?(comment.commentable).should be_true }
  end

  it 'should set html_body' do
    comment = create :comment
    comment.body = '[b]bold[/b]'
    comment.html_body.should eq '<strong>bold</strong>'
  end

  describe 'notification when quoted' do
    let(:user) { create :user }
    let(:topic) { create :entry, user: user }

    it 'comment' do
      comment2 = nil
      # создаём ответ на комментарий
      expect {
        comment2 = create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[comment=#{comment.id}]ня[/comment]"
      }.to change(Message, :count).by 1

      # должно создаться уведомление о новом комменте
      message = Message.last
      message.read.should be_false
      message.src_id.should eq user2.id
      message.dst_id.should eq user.id
      message.kind.should eq MessageType::QuotedByUser
      message.linked_type.should eq Comment.name
      message.linked_id.should eq comment2.id
    end

    it 'entry' do
      comment2 = nil
      # создаём ответ на комментарий
      expect {
        comment2 = create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[entry=#{topic.id}]ня[/entry]"
      }.to change(Message, :count).by 1

      # должно создаться уведомление о новом комменте
      message = Message.last
      message.read.should be_false
      message.src_id.should eq user2.id
      message.dst_id.should eq user.id
      message.kind.should eq MessageType::QuotedByUser
      message.linked_type.should eq Comment.name
      message.linked_id.should eq comment2.id
    end

    it 'quote old' do
      expect {
        create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[quote=#{user.nickname}]ня[/entry]ня"
      }.to change(Message, :count).by 1
    end

    it 'quote new' do
      expect {
        create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[quote=#{comment.id};#{user.id};#{user.nickname}]ня[/entry]ня"
      }.to change(Message, :count).by 1
    end

    describe 'only once' do
      it 'indeed' do
        create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[comment=#{comment.id}]ня[/comment]"

        expect {
          create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[comment=#{comment.id}]ня[/comment]"
        }.to change(Message, :count).by 0
      end

      it 'indeed' do
        create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[entry=#{topic.id}]ня[/entry]"

        expect {
          create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[entry=#{topic.id}]ня[/entry]"
        }.to change(Message, :count).by 0
      end

      it 'until old message is read' do
        create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[comment=#{comment.id}]ня[/comment]"
        Message.last.update_attribute :read, true

        expect {
          create :comment, :with_notify_quotes, commentable: topic, user: user2, body: "[comment=#{comment.id}]ня[/comment]"
        }.to change(Message, :count).by 1
      end
    end
  end

  describe :notify_quotes do
    let(:user) { create :user }
    let(:user2) { build_stubbed :user }
    let(:topic) { create :topic, user: user }
    let(:user_message) { Message.where(dst_id: user.id, dst_type: User.name, src_id: user2.id, src_type: User.name, kind: MessageType::QuotedByUser) }
    subject { create :comment, :with_notify_quotes, body: text, commentable: topic, user: user2 }

    context 'quote' do
      let(:text) { "[quote=200778;#{user.id};test2]test[/quote]" }
      it { expect{subject}.to change(user_message, :count).by 1 }
    end

    context 'comment' do
      let!(:comment) { create :comment, commentable: topic, user: user }
      let(:text) { "[comment=#{comment.id}]test[/comment]" }
      it { expect{subject}.to change(user_message, :count).by 1 }
    end

    context 'entry' do
      let(:text) { "[entry=#{topic.id}]test[/entry]" }
      it { expect{subject}.to change(user_message, :count).by 1 }
    end

    context 'mention' do
      let(:text) { "[mention=#{user.id}]test[/mention]" }
      it { expect{subject}.to change(user_message, :count).by 1 }
    end

    it 'notification only once' do
      text = "[mention=#{user.id}]test[/mention]"
      expect {
        create :comment, :with_notify_quotes, body: text, commentable: topic, user: user2
        Comment.wo_antispam { create :comment, body: text, commentable: topic, user: user2 }
      }.to change(user_message, :count).by 1
    end

    it 'second notification when first one is read' do
      text = "[mention=#{user.id}]test[/mention]"
      create :comment, :with_notify_quotes, body: text, commentable: topic, user: user2
      Message.last.update_column :read, true

      expect {
        Comment.wo_antispam { create :comment, :with_notify_quotes, body: text, commentable: topic, user: user2 }
      }.to change(user_message, :count).by 1
    end
  end

  describe :forbid_ban_change do
    subject! { build :comment, body: "[ban=1]" }
    before { subject.valid? }
    its(:valid?) { should be_false }

    it { subject.errors.messages[:base].first.should eq I18n.t('activerecord.errors.models.comments.not_a_moderator') }
  end
end
