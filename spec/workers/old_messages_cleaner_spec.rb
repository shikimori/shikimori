describe OldMessagesCleaner do
  let(:worker) { OldMessagesCleaner.new }
  let(:message_1) { create :message, kind: MessageType::EPISODE, created_at: 3.month.ago - 1.day, from: build_stubbed(:user), to: build_stubbed(:user) }
  let(:message_2) { create :message, kind: MessageType::EPISODE, created_at: 3.month.ago + 1.day, from: build_stubbed(:user), to: build_stubbed(:user) }
  before { worker.perform }

  specify { expect(Message.all).to eq [message_1] }
end
