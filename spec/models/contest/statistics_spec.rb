describe Contest::Statistics do
  let(:contest) { build_stubbed :contest }
  let(:statistics) { contest.strategy.statistics }

  let(:round1) { build_stubbed :contest_round, contest: contest, matches: [match1, match2] }
  let(:round2) { build_stubbed :contest_round, contest: contest, matches: [match3, match4] }
  let(:round3) { build_stubbed :contest_round, contest: contest, matches: [match5, match6] }

  let(:match1) { build_stubbed :contest_match, :no_round, :finished, left: anime1, right: anime2, winner_id: anime1.id }
  let(:match2) { build_stubbed :contest_match, :no_round, :finished, left: anime3, right: anime4, winner_id: anime3.id }
  let(:match3) { build_stubbed :contest_match, :no_round, :finished, left: anime1, right: anime3, winner_id: anime1.id }
  let(:match4) { build_stubbed :contest_match, :no_round, :finished, left: anime2, right: anime4, winner_id: anime2.id }
  let(:match5) { build_stubbed :contest_match, :no_round, :finished, left: anime1, right: anime2, winner_id: anime1.id }
  let(:match6) { build_stubbed :contest_match, :no_round, left: anime3, right: anime4 }

  let(:anime1) { build_stubbed :anime }
  let(:anime2) { build_stubbed :anime }
  let(:anime3) { build_stubbed :anime }
  let(:anime4) { build_stubbed :anime }

  before { allow(statistics).to receive(:rounds).and_return [round1, round2, round3] }
  before do
    statistics.rounds.each do |round|
      allow(round.matches).to receive_message_chain(:includes).and_return round.matches

      round.matches.each do |match|
        allow(match).to receive(:left_votes).and_return 0
        allow(match).to receive(:right_votes).and_return 0
      end
    end

    allow(match1).to receive(:left_votes).and_return 2
    allow(match1).to receive(:right_votes).and_return 1
    allow(match3).to receive(:left_votes).and_return 1
    allow(match5).to receive(:left_votes).and_return 1
  end

  describe 'committed_matches' do
    context 'without_round' do
      subject { statistics.committed_matches }
      it { should eq [match1, match2, match3, match4, match5] }
    end

    context 'with_round' do
      subject { statistics.committed_matches round2 }
      it { should eq [match1, match2, match3, match4] }
    end
  end

  describe 'prior_rounds' do
    subject { statistics.prior_rounds round2 }
    it { should eq [round1, round2] }
  end

  describe 'members' do
    subject { statistics.members }
    it { should eq(anime1.id => anime1, anime2.id => anime2, anime3.id => anime3, anime4.id => anime4) }
  end

  describe 'scores' do
    context 'without_round' do
      subject { statistics.scores }
      it { should eq(anime1.id => 3, anime2.id => 1, anime3.id => 1, anime4.id => 0) }
    end

    context 'with_round' do
      subject { statistics.scores round2 }
      it { should eq(anime1.id => 2, anime2.id => 1, anime3.id => 1, anime4.id => 0) }
    end
  end

  describe 'users_votes' do
    context 'without_round' do
      subject { statistics.users_votes }
      it { should eq(anime1.id => 4, anime2.id => 1, anime3.id => 0, anime4.id => 0) }
    end

    context 'with_round' do
      subject { statistics.users_votes round2 }
      it { should eq(anime1.id => 3, anime2.id => 1, anime3.id => 0, anime4.id => 0) }
    end
  end

  describe 'average_votes' do
    context 'without_round' do
      subject { statistics.average_votes }
      it { should eq(anime1.id => 1.33, anime2.id => 0.33, anime3.id => 0, anime4.id => 0) }
    end

    context 'with_round' do
      subject { statistics.average_votes round2 }
      it { should eq(anime1.id => 1.5, anime2.id => 0.5, anime3.id => 0, anime4.id => 0) }
    end
  end

  describe 'member_matches' do
    context 'without_round' do
      subject { statistics.member_matches anime1.id }
      it { should eq [match1, match3, match5] }
    end

    context 'with_round' do
      subject { statistics.member_matches anime1.id, round2 }
      it { should eq [match1, match3] }
    end
  end
end
