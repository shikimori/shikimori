describe MessagesService do
  subject(:service) { MessagesService.new user }

  let!(:message_1) do
    create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago
  end
  let!(:message_2) do
    create :message, :profile_commented,
      to: create(:user),
      from: user,
      created_at: 30.minutes.ago
  end
  let!(:message_3) { create :message, :private, to: user, from: user }

  describe '#read_by' do
    subject! do
      service.read_by(
        kind: kind,
        type: type,
        is_read: is_read,
        ids: ids
      )
    end
    let(:kind) { nil }
    let(:type) { nil }
    let(:is_read) { true }
    let(:ids) { nil }

    context 'kind' do
      let(:kind) { MessageType::PROFILE_COMMENTED }

      it do
        expect(message_1.reload).to be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to_not be_read
      end
    end

    context 'type' do
      let(:type) { :notifications }

      it do
        expect(message_1.reload).to be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to_not be_read
      end
    end

    context 'ids' do
      let(:ids) { [message_3.id] }

      it do
        expect(message_1.reload).to_not be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to be_read
      end

      context 'is_read' do
        let(:is_read) { false }
        let!(:message_3) { create :message, :private, to: user, from: user, read: true }

        it do
          expect(message_1.reload).to_not be_read
          expect(message_2.reload).to_not be_read
          expect(message_3.reload).to_not be_read
        end
      end
    end
  end

  describe '#delete_by' do
    subject! do
      service.delete_by(
        kind: kind,
        type: type
      )
    end
    let(:kind) { nil }
    let(:type) { nil }

    context 'kind' do
      let(:kind) { MessageType::PROFILE_COMMENTED }

      it do
        expect { message_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
      end
    end

    context 'type' do
      let(:type) { :notifications }

      it do
        expect { message_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
      end
    end
  end
end
