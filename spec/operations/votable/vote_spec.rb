describe Votable::Vote do
  subject do
    Votable::Vote.call(
      votable: votable,
      vote: vote,
      voter: voter
    )
  end

  let(:vote) { true }
  let(:voter) { seed :user }

  context 'review' do
    let(:votable) { create :review }

    it do
      expect { subject }.to change(ActsAsVotable::Vote, :count).by 1
      expect(voter.liked? votable).to eq true
    end
  end

  context 'poll' do
    let(:votable) { poll_variant_2 }

    let!(:poll) { create :poll }
    let!(:poll_variant_1) { create :poll_variant, poll: poll }
    let!(:poll_variant_2) { create :poll_variant, poll: poll }

    let! :current_user_vote do
      ActsAsVotable::Vote.create!(
        votable: poll_variant_1,
        voter: voter,
        vote_flag: true,
        vote_weight: 1
      )
    end
    let! :another_user_vote do
      ActsAsVotable::Vote.create!(
        votable: poll_variant_1,
        voter: create(:user),
        vote_flag: true,
        vote_weight: 1
      )
    end

    it do
      expect { subject }.to_not change ActsAsVotable::Vote, :count

      expect(voter.liked? poll_variant_1).to eq false
      expect(voter.liked? poll_variant_2).to eq true

      expect { current_user_vote.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(another_user_vote.reload).to be_persisted
    end
  end
end
