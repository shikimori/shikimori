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

  context 'contest_match' do
    let(:votable) { create :contest_match, state }

    context 'started' do
      let(:state) { :started }

      it do
        expect { subject }.to change(ActsAsVotable::Vote, :count).by 1
        expect(voter.liked? votable).to eq true
      end
    end

    context 'created/finished' do
      let(:state) { %i[created finished].sample }

      it do
        expect { subject }.to_not change ActsAsVotable::Vote, :count
        expect(voter.liked? votable).to eq false
      end
    end
  end

  context 'poll' do
    let!(:poll) { create :poll, poll_state }
    let(:poll_state) { :started }
    let!(:poll_variant_1) { create :poll_variant, poll: poll }
    let!(:poll_variant_2) { create :poll_variant, poll: poll }

    let(:voted_votable) { [poll, poll_variant_1, poll_variant_2].sample }
    let! :current_user_vote do
      ActsAsVotable::Vote.create!(
        votable: voted_votable,
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

    context 'poll variant' do
      let(:votable) { poll_variant_2 }

      it do
        expect { subject }.to_not change ActsAsVotable::Vote, :count

        expect(voter.liked? poll).to eq false
        expect(voter.liked? poll_variant_1).to eq false
        expect(voter.liked? poll_variant_2).to eq true

        expect { current_user_vote.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(another_user_vote.reload).to be_persisted
      end
    end

    context 'poll' do
      let(:votable) { poll }

      it do
        expect { subject }.to_not change ActsAsVotable::Vote, :count

        expect(voter.liked? poll).to eq true
        expect(voter.liked? poll_variant_1).to eq false
        expect(voter.liked? poll_variant_2).to eq false

        expect { current_user_vote.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(another_user_vote.reload).to be_persisted
      end
    end

    context 'not started poll' do
      let(:poll_state) { %i[pending stopped].sample }
      let(:votable) { [poll, poll_variant_1, poll_variant_2].sample }
      let(:voted_votable) { poll_variant_1 }

      it do
        expect { subject }.to_not change ActsAsVotable::Vote, :count

        expect(voter.liked? poll).to eq false
        expect(voter.liked? poll_variant_1).to eq true
        expect(voter.liked? poll_variant_2).to eq false

        expect(current_user_vote.reload).to be_persisted
        expect(another_user_vote.reload).to be_persisted
      end
    end
  end
end
