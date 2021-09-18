describe Votable::Vote do
  subject do
    Votable::Vote.call(
      votable: votable,
      vote: vote,
      voter: voter
    )
  end

  let(:vote) { 'yes' }
  let(:voter) { seed :user }

  context 'review' do
    let(:votable) { create :critique }

    it do
      expect { subject }.to change(ActsAsVotable::Vote, :count).by 1
      expect(voter.liked? votable).to eq true
    end

    context 'unknown vote' do
      let(:vote) { 'zxc' }
      it { expect { subject }.to raise_error ArgumentError, vote }
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

      describe 'update user_vote key' do
        let(:votable) { create :contest_match, state, round: contest_round }
        let!(:contet_match_2) do
          create :contest_match, :started, round: contest_round
        end
        let!(:contet_match_3) do
          create :contest_match, %i[created finished].sample,
            round: contest_round
        end
        let(:contest_round) { create :contest_round, contest: contest }
        let(:contest) { create :contest, user_vote_key: user_vote_key }
        let(:user_vote_key) { :can_vote_1 }
        let(:voter) { create :user, user_vote_key => true }

        context "last round's not voted match" do
          let!(:vote_2) { create :vote, votable: contet_match_2, voter: voter }
          it do
            expect { subject }.to change(ActsAsVotable::Vote, :count).by 1
            expect(voter.liked? votable).to eq true
            expect(voter.reload[user_vote_key]).to eq false
          end
        end

        context "not last round's not voted match" do
          it do
            expect { subject }.to change(ActsAsVotable::Vote, :count).by 1
            expect(voter.liked? votable).to eq true
            expect(voter.reload[user_vote_key]).to eq true
          end
        end
      end

      describe 'abstain' do
        let(:vote) { 'abstain' }

        it do
          expect { subject }.to change(ActsAsVotable::Vote, :count).by 1
          expect(voter.liked? votable).to eq false
          expect(voter.abstained? votable).to eq true
        end
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
