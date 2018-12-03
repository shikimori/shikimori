describe MessagesService do
  subject(:service) { MessagesService.new user }
  let(:user) { build_stubbed :user }

  let!(:message_1) { create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago }
  let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
  let!(:message_3) { create :message, :private, to: user, from: user }

  describe '#read_messages' do
    context 'kind' do
      before { service.read_messages kind: MessageType::PROFILE_COMMENTED }

      it { expect(message_1.reload).to be_read }
      it { expect(message_2.reload).to_not be_read }
      it { expect(message_3.reload).to_not be_read }
    end

    context 'type' do
      before { service.read_messages type: :notifications }

      it { expect(message_1.reload).to be_read }
      it { expect(message_2.reload).to_not be_read }
      it { expect(message_3.reload).to_not be_read }
    end
  end

  describe '#delete_messages' do
    context 'kind' do
      before { service.delete_messages kind: MessageType::PROFILE_COMMENTED }

      it { expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound }
      it { expect(message_2.reload).to be_persisted }
      it { expect(message_3.reload).to be_persisted }
    end

    context 'type' do
      before { service.delete_messages type: :notifications }

      it { expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound }
      it { expect(message_2.reload).to be_persisted }
      it { expect(message_3.reload).to be_persisted }
    end
  end
end
