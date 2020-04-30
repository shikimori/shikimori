describe OldMessagesCleaner do
  let(:worker) { OldMessagesCleaner.new }
  let(:message_1) do
    create :message,
      kind: MessageType::EPISODE,
      created_at: 3.month.ago - 1.day,
      from: user_2,
      to: user_3
  end
  let(:message_2) do
    create :message,
      kind: MessageType::EPISODE,
      created_at: 3.month.ago + 1.day,
      from: user_2,
      to: user_3
  end
  subject! { worker.perform }

  it { expect(Message.all).to eq [message_1] }
end
