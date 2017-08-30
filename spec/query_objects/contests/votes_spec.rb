describe Contests::Votes do
  subject { Contests::Votes.call(contest).order(:id) }

  let(:contest) { create :contest }
  let(:contest_round) { create :contest_round, contest: contest }
  let(:contest_match) { create :contest_match, round: contest_round }

  let!(:vote_1) { create :vote, votable: contest_match }
  let!(:vote_2) { create :vote, votable: contest_match }

  context 'associations cached' do
    before { contest.rounds.includes(:matches).to_a }
    it { is_expected.to eq [vote_1, vote_2] }
  end

  context 'associations not cached' do
    it { is_expected.to eq [vote_1, vote_2] }
  end

  context 'vote from another user' do
    let!(:vote_2) { create :vote, votable: contest_match, voter: create(:user) }
    it { is_expected.to eq [vote_1, vote_2] }
  end

  context 'vote for another round' do
    let(:contest_round_2) { create :contest_round, contest: contest }
    let(:contest_match_2) { create :contest_match, round: contest_round_2 }
    let!(:vote_2) { create :vote, votable: contest_match_2, voter: create(:user) }
    it { is_expected.to eq [vote_1, vote_2] }
  end

  context 'vote for another contest' do
    let(:contest_match_2) { create :contest_match }
    let!(:vote_2) { create :vote, votable: contest_match_2, voter: create(:user) }
    it { is_expected.to eq [vote_1] }
  end
end
