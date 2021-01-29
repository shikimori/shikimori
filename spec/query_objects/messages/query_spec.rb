describe Messages::Query do

  let!(:private) do
    create :message,
      kind: MessageType::PRIVATE,
      to: user,
      from: user_2
  end
  let!(:sent) do
    create :message,
      kind: MessageType::PRIVATE,
      to: user_2,
      from: user
  end
  let!(:news) do
    create :message,
      kind: MessageType::ANONS,
      to: user,
      from: user_2
  end
  let!(:notification) do
    create :message,
      kind: MessageType::FRIEND_REQUEST,
      to: user,
      from: user_2,
      read: true
  end

  describe '.fetch' do
    let(:query) { described_class.fetch user, messages_type }
    subject { query.paginate 1, 1 }

    context 'inbox' do
      let!(:private_2) do
        create :message,
          kind: MessageType::PRIVATE,
          to: user,
          from: user_2,
          is_deleted_by_to: true,
          read: false
      end
      let!(:private_3) do
        create :message,
          kind: MessageType::PRIVATE,
          to: user,
          from: user_2,
          read: true
      end
      let(:messages_type) { :inbox }

      it { is_expected.to eq [private_3] }
    end

    context 'private' do
      let!(:private_2) do
        create :message,
          kind: MessageType::PRIVATE,
          to: user,
          from: user_2,
          is_deleted_by_to: true,
          read: false
      end
      let!(:private_3) do
        create :message,
          kind: MessageType::PRIVATE,
          to: user,
          from: user_2,
          read: true
      end
      let(:messages_type) { :private }

      it { is_expected.to eq [private] }
    end

    context 'sent' do
      let!(:sent_2) do
        create :message,
          kind: MessageType::PRIVATE,
          to: user_2,
          from: user
      end
      let(:messages_type) { :sent }

      it { is_expected.to eq [sent_2] }
    end

    context 'news' do
      let(:messages_type) { :news }
      it { is_expected.to eq [news] }
    end

    context 'notifications' do
      let!(:notification_2) do
        create :message,
          kind: MessageType::CLUB_REQUEST,
          to: user,
          from: user_2,
          id: notification.id * 10
      end
      let!(:notification_3) do
        create :message,
          kind: MessageType::CLUB_REQUEST,
          to: user,
          from: user_2,
          id: notification.id * 100
      end
      let(:messages_type) { :notifications }

      it { is_expected.to eq [notification_3] }
    end
  end
end
