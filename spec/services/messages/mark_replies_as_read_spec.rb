describe Messages::MarkRepliesAsRead do
  let(:body) do
    [
      "[message=#{reply_message.id};#{user_2.id}], test",
      "[message=#{reply_message.id}], test"
    ].sample
  end
  let(:user_id) { user_3.id }
  let!(:reply_message) { create :message, to: user_3, from: user_2 }

  subject! { described_class.call body: body, user_id: user_id }

  it { expect(reply_message.reload.read).to eq true }

  context 'replied messages belongs to another user' do
    let!(:reply_message) { create :message, to: user_1, from: user_2 }
    it { expect(reply_message.reload.read).to_not eq true }
  end
end
