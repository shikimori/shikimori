describe MessagesService do
  subject(:service) { MessagesService.new user }

  let!(:message_1) do
    create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago
  end
  let!(:message_2) do
    create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago
  end
  let!(:message_3) do
    create :message, :private, to: user, from: user
  end

  describe '#read' do
    context 'kind' do
      before { service.read kind: MessageType::PROFILE_COMMENTED }

      it do
        expect(message_1.reload).to be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to_not be_read
      end
    end

    context 'type' do
      before { service.read type: :notifications }

      it do
        expect(message_1.reload).to be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to_not be_read
      end
    end
  end

  describe '#delete' do
    context 'kind' do
      before { service.delete kind: MessageType::PROFILE_COMMENTED }

      it do
        expect { message_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
      end
    end

    context 'type' do
      before { service.delete type: :notifications }

      it do
        expect { message_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
      end
    end
  end
end
