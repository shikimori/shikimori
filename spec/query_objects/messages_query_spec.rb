describe MessagesQuery do
  before { Message.antispam = false }
  let(:query) { MessagesQuery.new user, messages_type }

  let(:user) { build_stubbed :user }
  let(:user_2) { build_stubbed :user }
  let!(:private) { create :message, kind: MessageType::Private, to: user, from: user_2 }
  let!(:sent) { create :message, kind: MessageType::Private, to: user_2, from: user }
  let!(:news) { create :message, kind: MessageType::Anons, to: user, from: user_2 }
  let!(:notification) { create :message, kind: MessageType::FriendRequest, to: user, from: user_2, read: true }

  describe '#fetch' do
    subject { query.fetch 1, 1 }

    context 'inbox' do
      let!(:private_2) { create :message, kind: MessageType::Private, to: user, from: user_2, is_deleted_by_to: true, read: false }
      let!(:private_3) { create :message, kind: MessageType::Private, to: user, from: user_2, read: true }
      let(:messages_type) { :inbox }

      it { expect(subject).to have(2).items }
      its(:first) { should eq private }
    end

    context 'private' do
      let!(:private_2) { create :message, kind: MessageType::Private, to: user, from: user_2, is_deleted_by_to: true, read: false }
      let!(:private_3) { create :message, kind: MessageType::Private, to: user, from: user_2, read: true }
      let(:messages_type) { :private }

      it { expect(subject).to have(1).item }
      its(:first) { should eq private }
    end

    context 'sent' do
      let!(:sent_2) { create :message, kind: MessageType::Private, to: user_2, from: user, is_deleted_by_from: true }
      let(:messages_type) { :sent }

      it { expect(subject).to have(1).item }
      its(:first) { should eq sent }
    end

    context 'news' do
      let(:messages_type) { :news }
      it { expect(subject).to have(1).item }
      its(:first) { should eq news }
    end

    context 'notifications' do
      let!(:notification_2) { create :message, kind: MessageType::GroupRequest, to: user, from: user_2, id: notification.id * 10 }
      let!(:notification_3) { create :message, kind: MessageType::GroupRequest, to: user, from: user_2, id: notification.id * 100 }
      let(:messages_type) { :notifications }

      it { expect(subject).to have(2).items }
      its(:first) { should eq notification_3 }
    end
  end

  describe '#postload' do
    let!(:notification_2) { create :message, kind: MessageType::GroupRequest, to: user, from: user_2, id: notification.id * 10 }
    let!(:notification_3) { create :message, kind: MessageType::GroupRequest, to: user, from: user_2, id: notification.id * 100 }
    let(:messages_type) { :notifications }

    subject { query.postload 2, 1 }

    its(:first) { should eq [notification_2] }
    its(:second) { should be_truthy }
  end
end
