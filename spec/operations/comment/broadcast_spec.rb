describe Comment::Broadcast do
  let(:operation) { Comment::Broadcast.new comment }
  let(:comment) { create :comment, body: 'test' }

  describe '#call' do
    before { allow(Comments::BroadcastNotifications).to receive :perform_async }
    subject! { operation.call }

    it do
      expect(comment).to_not be_changed
      expect(comment.body).to eq "test\n#{Comment::Broadcast::BB_CODE}"
      expect(Comments::BroadcastNotifications)
        .to have_received(:perform_async)
        .with comment.id
    end
  end
end
