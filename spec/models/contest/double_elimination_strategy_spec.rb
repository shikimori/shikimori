describe Contest::DoubleEliminationStrategy do
  let(:strategy) { contest.strategy }
  let(:contest) { create :contest, :double_elimination }

  describe '#total_rounds' do
    [
      [128, 14],
      [65, 14],
      [64, 12],
      [50, 12],
      [33, 12],
      [32, 10],
      [16, 8],
      [9, 8],
      [8, 6],
      [7, 6]
    ].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        expect(strategy.total_rounds).to eq rounds
      end
    end
  end

  describe '#create_rounds' do
    [[128, 14], [64, 12], [32, 10], [16, 8], [8, 6]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        allow(strategy).to receive :fill_round_with_matches

        expect { strategy.create_rounds }
          .to change(ContestRound, :count).by(rounds)
      end
    end

    it 'sets correct number&additional' do
      allow(contest.members).to receive(:count).and_return 16
      allow(strategy).to receive :fill_round_with_matches
      strategy.create_rounds

      expect(contest.rounds[0].number).to eq 1
      expect(contest.rounds[0].additional).to eq false

      expect(contest.rounds[1].number).to eq 2
      expect(contest.rounds[1].additional).to eq false
      expect(contest.rounds[2].number).to eq 2
      expect(contest.rounds[2].additional).to eq true

      expect(contest.rounds[3].number).to eq 3
      expect(contest.rounds[3].additional).to eq false
      expect(contest.rounds[4].number).to eq 3
      expect(contest.rounds[4].additional).to eq true

      expect(contest.rounds[5].number).to eq 4
      expect(contest.rounds[5].additional).to eq false
      expect(contest.rounds[6].number).to eq 4
      expect(contest.rounds[6].additional).to eq true

      expect(contest.rounds[7].number).to eq 5
      expect(contest.rounds[7].additional).to eq false
    end
  end

  describe '#advance_members' do
    let(:contest) { create :contest, :with_5_members, :double_elimination }

    let(:w1) { contest.rounds[0].matches[0].left }
    let(:w2) { contest.rounds[0].matches[1].left }
    let(:w3) { contest.rounds[0].matches[2].left }
    let(:l1) { contest.rounds[0].matches[0].right }
    let(:l2) { contest.rounds[0].matches[1].right }

    before { Contest::Start.call contest }

    context 'I -> II' do
      before do
        contest.rounds[0].matches.each do |contest_match|
          contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
        end
        ContestRound::Finish.call contest.current_round
      end

      it 'winners&losers' do
        expect(contest.current_round.matches[0].left).to eq w1
        expect(contest.current_round.matches[0].right).to eq w2

        expect(contest.current_round.matches[1].left).to eq w3
        expect(contest.current_round.matches[1].right).to be_nil

        expect(contest.current_round.matches[2].left).to eq l1
        expect(contest.current_round.matches[2].right).to eq l2
      end
    end

    context 'II -> IIa, II -> III' do
      before do
        2.times do |i|
          contest.rounds[i].matches.each do |contest_match|
            contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
          end
        end
        2.times { ContestRound::Finish.call contest.current_round }
      end

      it 'winners&losers' do
        expect(contest.current_round.matches[0].left).to eq l1
        expect(contest.current_round.matches[0].right).to eq w2

        expect(contest.current_round.next_round.matches[0].left).to eq w1
        expect(contest.current_round.next_round.matches[0].right).to eq w3
      end
    end

    context 'IIa -> III' do
      before do
        3.times do |i|
          contest.rounds[i].matches.each do |contest_match|
            contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
          end
        end
        3.times { ContestRound::Finish.call contest.current_round }
      end

      it 'winners' do
        expect(contest.current_round.matches[1].left).to eq l1
        expect(contest.current_round.matches[1].right).to be_nil
      end
    end

    context 'III -> IIIa, III -> IV' do
      before do
        4.times do |i|
          contest.rounds[i].matches.each do |contest_match|
            contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
          end
        end
        4.times { ContestRound::Finish.call contest.current_round }
      end

      it 'winners&losers' do
        expect(contest.current_round.matches[0].left).to eq w3
        expect(contest.current_round.matches[0].right).to eq l1

        expect(contest.current_round.next_round.matches[0].left).to eq w1
        expect(contest.current_round.next_round.matches[0].right).to be_nil
      end
    end

    context 'III -> IV' do
      before do
        5.times do |i|
          contest.rounds[i].matches.each do |contest_match|
            contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
          end
        end
        5.times { ContestRound::Finish.call contest.current_round }
      end

      it 'winners' do
        expect(contest.current_round.matches[0].right).to eq w3
      end
    end
  end

  describe '#create_matches' do
    let(:strategy) { round.contest.strategy }
    let(:round) do
      create :contest_round,
        contest: create(:contest, matches_per_round: 4, match_duration: 4)
    end
    let(:animes) { 1.upto(11).map { create :anime } }

    subject(:create_matches) { strategy.create_matches round, animes, group: ContestRound::W }

    it 'creates animes/2 matches' do
      expect { subject }
        .to change(ContestMatch, :count)
        .by((animes.size.to_f / 2).ceil)
    end

    it 'create_matchess left&right correctly' do
      strategy.create_matches round, animes, shuffle: false

      expect(round.matches[0].left_id).to eq animes[0].id
      expect(round.matches[0].right_id).to eq animes[1].id

      expect(round.matches[1].left_id).to eq animes[2].id
      expect(round.matches[1].right_id).to eq animes[3].id

      expect(round.matches[5].left_id).to eq animes[10].id
      expect(round.matches[5].right_id).to be_nil
    end

    describe 'dates' do
      before { strategy.create_matches round, animes, shuffle: false }
      let(:matches_per_round) { round.contest.matches_per_round }

      it 'first of first round' do
        expect(round.matches[0].started_on).to eq round.contest.started_on
        expect(round.matches[0].finished_on).to eq(
          round.contest.started_on + (round.contest.match_duration - 1).days
        )
      end

      it 'last of first round' do
        expect(round.matches[matches_per_round - 1].started_on).to eq(
          round.contest.started_on
        )
        expect(round.matches[matches_per_round - 1].finished_on).to eq(
          round.contest.started_on + (round.contest.match_duration - 1).days
        )
      end

      it 'first of second round' do
        expect(round.matches[matches_per_round].started_on).to eq(
          round.contest.started_on + round.contest.matches_interval.days
        )
        expect(round.matches[matches_per_round].finished_on).to eq(
          round.contest.started_on + (round.contest.matches_interval - 1).days +
            round.contest.match_duration.days
        )
      end

      context 'additional create_matches' do
        before do
          @prior_last_vote = round.matches.last
          @prior_count = round.matches.count
          strategy.create_matches round, animes, shuffle: false
        end

        it 'continues from last vote' do
          expect(round.matches[@prior_count].started_on).to eq @prior_last_vote.started_on
        end
      end
    end

    describe 'shuffle' do
      let(:ordered?) { round.matches[0].left_id == animes[0].id && round.matches[0].right_id == animes[1].id && round.matches[1].left_id == animes[2].id && round.matches[1].right_id == animes[3].id }

      context 'false' do
        before { strategy.create_matches round, animes, shuffle: false }

        it 'create_matchess matches with ordered animes' do
          expect(ordered?).to eq true
        end
      end

      context 'true' do
        before { strategy.create_matches round, animes, shuffle: true }

        it 'create_matchess matches with shuffled animes' do
          expect(ordered?).to eq false
        end
      end
    end
  end

  describe '#with_additional_rounds?' do
    subject { contest.strategy }
    its(:with_additional_rounds?) { should eq true }
  end

  describe '#dynamic_rounds?' do
    subject { contest.strategy }
    its(:dynamic_rounds?) { should eq false }
  end

  describe '#results' do
    let(:contest) { create :contest, :with_8_members, :character }
    let(:scores) { contest.strategy.statistics.scores }
    let(:average_votes) { contest.strategy.statistics.average_votes }
    before do
      Contest::Start.call contest
      contest.rounds.each do |_round|
        contest.current_round.matches.each do |contest_match|
          contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
        end
        Contest::Progress.call contest
      end

      scores[contest.rounds[2].matches.first.loser.id] = 2
      scores[contest.rounds[2].matches.last.loser.id] = 2

      average_votes[contest.rounds[2].matches.first.loser.id] = 2
      average_votes[contest.rounds[2].matches.last.loser.id] = 1

      scores[contest.rounds[1].matches[2].loser.id] = 1
      scores[contest.rounds[1].matches[3].loser.id] = 0
    end

    context 'final' do
      let(:results) { strategy.results }
      it 'has expected results' do
        # count
        expect(results.size).to eq(contest.members.size)

        # final
        expect(results[0].id).to eq contest.rounds[5].matches.first.winner.id
        expect(results[1].id).to eq contest.rounds[5].matches.first.loser.id

        # semifinal
        expect(results[2].id).to eq contest.rounds[4].matches.first.loser.id
        expect(results[3].id).to eq contest.rounds[3].matches.last.loser.id

        # other
        expect(results[4].id).to eq contest.rounds[2].matches.first.loser.id
        expect(results[5].id).to eq contest.rounds[2].matches.last.loser.id

        expect(results[6].id).to eq contest.rounds[1].matches[2].loser.id
        expect(results[7].id).to eq contest.rounds[1].matches[3].loser.id
      end
    end

    context 'intermediate_main_round' do
      let(:results) { strategy.results round }
      let(:round) { contest.rounds[3] }

      it 'has expected results' do
        # count
        expect(results.size).to eq(contest.members.size)

        expect(results[0].id).to eq contest.rounds[3].matches.first.winner.id
        expect(results[1].id).to eq contest.rounds[3].matches.last.winner.id

        expect(results[2].id).to eq contest.rounds[3].matches.first.loser.id
        expect(results[3].id).to eq contest.rounds[3].matches.last.loser.id

        expect(results[4].id).to eq contest.rounds[2].matches.first.loser.id
        expect(results[5].id).to eq contest.rounds[2].matches.last.loser.id

        expect(results[6].id).to eq contest.rounds[1].matches[2].loser.id
        expect(results[7].id).to eq contest.rounds[1].matches[3].loser.id
      end
    end

    context 'intermediate_additional_round' do
      let(:results) { strategy.results round }
      let(:round) { contest.rounds[4] }

      it 'has expected results' do
        expect(results[0].id).to eq contest.rounds[3].matches.first.winner.id
        expect(results[1].id).to eq contest.rounds[4].matches.first.winner.id

        expect(results[2].id).to eq contest.rounds[4].matches.first.loser.id

        expect(results[3].id).to eq contest.rounds[3].matches.last.loser.id

        expect(results[4].id).to eq contest.rounds[2].matches.first.loser.id
        expect(results[5].id).to eq contest.rounds[2].matches.last.loser.id
      end
    end
  end

  describe '#fill_round_with_matches' do
    context '19 members' do
      let(:contest) { create :contest, :with_19_members, matches_per_round: 3 }
      before { strategy.create_rounds }

      it 'should not left last vote for next day' do
        expect(contest.rounds.first.matches.map(&:started_on).map(&:to_s).uniq.size).to eq(3)
        expect(contest.rounds.second.matches.map(&:started_on).map(&:to_s).uniq.size).to eq(3)
      end
    end

    context '5 members' do
      let(:contest) { create :contest, :with_5_members }
      before { strategy.create_rounds }

      context 'I' do
        let(:round) { contest.rounds.first }

        it 'valid' do
          expect(round.matches.size).to eq(3)
          round.matches.each { |vote| expect(vote.group).to eq ContestRound::S }
          expect(round.matches.first.started_on).to eq contest.started_on
          expect(round.matches.first.right_type).not_to be_nil
          expect(round.matches.last.right_type).to be_nil
        end
      end

      context 'II' do
        let(:round) { contest.rounds[1] }

        it 'valid' do
          expect(round.matches.size).to eq(3)
          round.matches[0..1].each { |vote| expect(vote.group).to eq ContestRound::W }
          round.matches[2..2].each { |vote| expect(vote.group).to eq ContestRound::L }
          expect(round.matches.first.started_on).to eq(
            round.prior_round.matches.last.finished_on +
              contest.matches_interval.days
          )
          expect(round.matches.first.right_type).not_to be_nil
        end
      end

      context 'IIa' do
        let(:round) { contest.rounds[2] }

        it 'valid' do
          expect(round.matches.size).to eq(1)
          round.matches.each { |vote| expect(vote.group).to eq ContestRound::L }
          expect(round.matches.first.started_on).to eq(
            round.prior_round.matches.last.finished_on +
              contest.matches_interval.days
          )
          expect(round.matches.first.right_type).not_to be_nil
        end
      end

      context 'III' do
        let(:round) { contest.rounds[3] }

        it 'valid' do
          expect(round.matches.size).to eq(2)
          expect(round.matches.first.group).to eq ContestRound::W
          expect(round.matches.last.group).to eq ContestRound::L
          expect(round.matches.first.started_on).to eq(
            round.prior_round.matches.last.finished_on +
              contest.matches_interval.days
          )
          expect(round.matches.first.right_type).not_to be_nil
        end
      end

      context 'IIIa' do
        let(:round) { contest.rounds[4] }

        it 'valid' do
          expect(round.matches.size).to eq(1)
          expect(round.matches.first.group).to eq ContestRound::L
          expect(round.matches.first.right_type).not_to be_nil
        end
      end

      context 'IV' do
        let(:round) { contest.rounds.last }

        it 'valid' do
          expect(round.matches.size).to eq(1)
          expect(round.matches.first.group).to eq ContestRound::F
          expect(round.matches.first.started_on).to eq(
            round.prior_round.matches.last.finished_on +
              contest.matches_interval.days
          )
          expect(round.matches.first.right_type).not_to be_nil
        end
      end
    end
  end
end
