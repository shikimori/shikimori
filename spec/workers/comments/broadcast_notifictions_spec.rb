describe Comments::BroadcastNotifications do
  let(:worker) { Comments::BroadcastNotifications.new }

  describe '#perform' do
    let!(:club) { create :club, :with_topics }
    let!(:comment) do
      create :comment,
        user: user_1,
        commentable: club.topic
    end

    let!(:user_1) { create :user }
    let!(:user_2) { create :user }

    let!(:author_role) { create :club_role, :member, user: user_1, club: club }
    let!(:member_role) { create :club_role, :member, user: user_2, club: club }

    subject { worker.perform comment.id }

    it do
      expect(subject.ids).to have(1).item
      expect(subject.num_inserts).to eq 1

      expect(Message.find(subject.ids.first)).to have_attributes(
        from: user_1,
        to: user_2,
        kind: MessageType::CLUB_BROADCAST,
        linked: comment,
        body: nil
      )
    end
  end
end
