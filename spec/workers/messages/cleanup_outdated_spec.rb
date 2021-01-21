describe Messages::CleanupOutdated do
  let(:message_1) do
    create :message,
      kind: MessageType::EPISODE,
      created_at: described_class::EXPIRE_INTERVAL.ago - 1.day,
      from: user_2,
      to: user_3
  end
  let(:message_2) do
    create :message,
      kind: MessageType::EPISODE,
      created_at: described_class::EXPIRE_INTERVAL + 1.day,
      from: user_2,
      to: user_3
  end
  subject! { described_class.new.perform }

  it { expect(Message.all).to eq [message_1] }
end
