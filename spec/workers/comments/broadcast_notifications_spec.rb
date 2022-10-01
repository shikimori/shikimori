describe Comments::BroadcastNotifications do
  subject { described_class.new.perform comment }
  let(:club) { create :club, :with_topics }
  let(:comment) do
    create :comment,
      user: user_2,
      commentable: club.decorate.maybe_topic
  end
  let!(:club_member) { create :club_role, club: club, user: user_3 }

  let(:messages_scope) do
    Message.where(
      from: comment.user,
      kind: MessageType::CLUB_BROADCAST,
      linked: comment
    )
  end
  it do
    expect { subject }.to change(messages_scope, :count).by 1
  end
end
