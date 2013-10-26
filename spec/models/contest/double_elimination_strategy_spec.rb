require 'spec_helper'

describe Contest::DoubleEliminationStrategy do
  let(:strategy_type) { :double_elimination }
  let(:strategy) { contest.strategy }

  describe :total_rounds do
    let(:contest) { build_stubbed :contest, strategy_type: strategy_type }

    [[128,14], [65,14], [64,12], [50,12], [33,12], [32,10], [16,8], [9,8], [8,6], [7,6]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        contest.members.stub(:count).and_return members
        contest.total_rounds.should eq rounds
      end
    end
  end

  describe :create_rounds do
    let(:contest) { create :contest, strategy_type: strategy_type }

    [[128,14], [64,12], [32,10], [16,8], [8,6]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        contest.members.stub(:count).and_return members
        strategy.stub :fill_round_with_matches

        expect{strategy.create_rounds}.to change(ContestRound, :count).by rounds
      end
    end

    it 'sets correct number&additional' do
      contest.members.stub(:count).and_return 16
      strategy.stub :fill_round_with_matches
      strategy.create_rounds

      contest.rounds[0].number.should eq 1
      contest.rounds[0].additional.should be_false

      contest.rounds[1].number.should eq 2
      contest.rounds[1].additional.should be_false
      contest.rounds[2].number.should eq 2
      contest.rounds[2].additional.should be_true

      contest.rounds[3].number.should eq 3
      contest.rounds[3].additional.should be_false
      contest.rounds[4].number.should eq 3
      contest.rounds[4].additional.should be_true

      contest.rounds[5].number.should eq 4
      contest.rounds[5].additional.should be_false
      contest.rounds[6].number.should eq 4
      contest.rounds[6].additional.should be_true

      contest.rounds[7].number.should eq 5
      contest.rounds[7].additional.should be_false
    end
  end

  describe :advance_members do
    let(:contest) { create :contest_with_5_members, strategy_type: strategy_type }
    let(:w1) { contest.rounds[0].matches[0].left }
    let(:w2) { contest.rounds[0].matches[1].left }
    let(:w3) { contest.rounds[0].matches[2].left }
    let(:l1) { contest.rounds[0].matches[0].right }
    let(:l2) { contest.rounds[0].matches[1].right }

    before { contest.start! }

    context 'I -> II' do
      before do
        1.times { |i| contest.rounds[i].matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday } }
        1.times do
          contest.current_round.reload
          contest.current_round.finish!
        end
      end

      it 'winners&losers' do
        contest.current_round.matches[0].left.should eq w1
        contest.current_round.matches[0].right.should eq w2

        contest.current_round.matches[1].left.should eq w3
        contest.current_round.matches[1].right.should be_nil

        contest.current_round.matches[2].left.should eq l1
        contest.current_round.matches[2].right.should eq l2
      end
    end

    context 'II -> IIa, II -> III' do
      before do
        2.times { |i| contest.rounds[i].matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday } }
        2.times do |i|
          contest.current_round.reload
          contest.current_round.finish!
        end
      end

      it 'winners&losers' do
        contest.current_round.matches[0].left.should eq l1
        contest.current_round.matches[0].right.should eq w2

        contest.current_round.next_round.matches[0].left.should eq w1
        contest.current_round.next_round.matches[0].right.should eq w3
      end
    end

    context 'IIa -> III' do
      before do
        3.times { |i| contest.rounds[i].matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday } }
        3.times do |i|
          contest.current_round.reload
          contest.current_round.finish!
        end
      end

      it 'winners' do
        contest.current_round.matches[1].left.should eq l1
        contest.current_round.matches[1].right.should be_nil
      end
    end

    context 'III -> IIIa, III -> IV' do
      before do
        4.times { |i| contest.rounds[i].matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday } }
        4.times do |i|
          contest.current_round.reload
          contest.current_round.finish!
        end
      end

      it 'winners&losers' do
        contest.current_round.matches[0].left.should eq w3
        contest.current_round.matches[0].right.should eq l1

        contest.current_round.next_round.matches[0].left.should eq w1
        contest.current_round.next_round.matches[0].right.should be_nil
      end
    end

    context 'III -> IV' do
      before do
        5.times { |i| contest.rounds[i].matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday } }
        5.times do |i|
          contest.current_round.reload
          contest.current_round.finish!
        end
      end

      it 'winners' do
        contest.current_round.matches[0].right.should eq w3
      end
    end
  end

  describe :create_matches do
    let(:strategy) { round.contest.strategy }
    let(:round) { create :contest_round, contest: create(:contest, matches_per_round: 4, match_duration: 4) }
    let(:animes) { 1.upto(11).map { create :anime } }

    it 'creates animes/2 matches' do
      expect { strategy.create_matches round, animes, group: ContestRound::W }.to change(ContestMatch, :count).by (animes.size.to_f / 2).ceil
    end

    it 'create_matchess left&right correctly' do
      strategy.create_matches round, animes, shuffle: false

      round.matches[0].left_id.should eq animes[0].id
      round.matches[0].right_id.should eq animes[1].id

      round.matches[1].left_id.should eq animes[2].id
      round.matches[1].right_id.should eq animes[3].id

      round.matches[5].left_id.should eq animes[10].id
      round.matches[5].right_id.should be_nil
    end

    describe 'dates' do
      before { strategy.create_matches round, animes, shuffle: false }
      let(:matches_per_round) { round.contest.matches_per_round }

      it 'first of first round' do
        round.matches[0].started_on.should eq round.contest.started_on
        round.matches[0].finished_on.should eq round.contest.started_on + (round.contest.match_duration-1).days
      end

      it 'last of first round' do
        round.matches[matches_per_round - 1].started_on.should eq round.contest.started_on
        round.matches[matches_per_round - 1].finished_on.should eq round.contest.started_on + (round.contest.match_duration-1).days
      end

      it 'first of second round' do
        round.matches[matches_per_round].started_on.should eq round.contest.started_on + round.contest.matches_interval.days
        round.matches[matches_per_round].finished_on.should eq round.contest.started_on + (round.contest.matches_interval-1).days + round.contest.match_duration.days
      end

      context 'additional create_matches' do
        before do
          @prior_last_vote = round.matches.last
          @prior_count = round.matches.count
          strategy.create_matches round, animes, shuffle: false
        end

        it 'continues from last vote' do
          round.matches[@prior_count].started_on.should eq @prior_last_vote.started_on
        end
      end
    end

    describe :shuffle do
      let(:ordered?) { round.matches[0].left_id == animes[0].id && round.matches[0].right_id == animes[1].id && round.matches[1].left_id == animes[2].id && round.matches[1].right_id == animes[3].id }

      context 'false' do
        before { strategy.create_matches round, animes, shuffle: false }

        it 'create_matchess matches with ordered animes' do
          ordered?.should be_true
        end
      end

      context 'true' do
        before { strategy.create_matches round, animes, shuffle: true }

        it 'create_matchess matches with shuffled animes' do
          ordered?.should be_false
        end
      end
    end
  end

  describe :with_additional_rounds? do
    subject { build_stubbed(:contest, strategy_type: strategy_type).strategy }
    its(:with_additional_rounds?) { should be_true }
  end

  describe :dynamic_rounds? do
    subject { build_stubbed(:contest, strategy_type: strategy_type).strategy }
    its(:dynamic_rounds?) { should be_false }
  end

  describe :results do
    let(:contest) { create :contest_with_8_members, :character }
    let(:scores) { contest.strategy.statistics.scores }
    let(:average_votes) { contest.strategy.statistics.average_votes }
    before do
      contest.start!
      contest.rounds.each do |round|
        contest.current_round.matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday }
        contest.process!
        contest.reload
      end

      scores[contest.rounds[2].matches.first.loser.id] = 2
      scores[contest.rounds[2].matches.last.loser.id] = 2

      average_votes[contest.rounds[2].matches.first.loser.id] = 2
      average_votes[contest.rounds[2].matches.last.loser.id] = 1

      scores[contest.rounds[1].matches[2].loser.id] = 1
      scores[contest.rounds[1].matches[3].loser.id] = 0
    end

    context :final do
      let(:results) { contest.results }
      it 'has expected results' do
        # count
        results.should have(contest.members.size).items

        # final
        results[0].id.should eq contest.rounds[5].matches.first.winner.id
        results[1].id.should eq contest.rounds[5].matches.first.loser.id

        # semifinal
        results[2].id.should eq contest.rounds[4].matches.first.loser.id
        results[3].id.should eq contest.rounds[3].matches.last.loser.id

        # other
        results[4].id.should eq contest.rounds[2].matches.first.loser.id
        results[5].id.should eq contest.rounds[2].matches.last.loser.id

        results[6].id.should eq contest.rounds[1].matches[2].loser.id
        results[7].id.should eq contest.rounds[1].matches[3].loser.id
      end
    end

    context :intermediate_main_round do
      let(:results) { contest.results round }
      let(:round) { contest.rounds[3] }

      it 'has expected results' do
        # count
        results.should have(contest.members.size).items

        results[0].id.should eq contest.rounds[3].matches.first.winner.id
        results[1].id.should eq contest.rounds[3].matches.last.winner.id

        results[2].id.should eq contest.rounds[3].matches.first.loser.id
        results[3].id.should eq contest.rounds[3].matches.last.loser.id

        results[4].id.should eq contest.rounds[2].matches.first.loser.id
        results[5].id.should eq contest.rounds[2].matches.last.loser.id

        results[6].id.should eq contest.rounds[1].matches[2].loser.id
        results[7].id.should eq contest.rounds[1].matches[3].loser.id
      end
    end

    context :intermediate_additional_round do
      let(:results) { contest.results round }
      let(:round) { contest.rounds[4] }

      it 'has expected results' do
        results[0].id.should eq contest.rounds[3].matches.first.winner.id
        results[1].id.should eq contest.rounds[4].matches.first.winner.id

        results[2].id.should eq contest.rounds[4].matches.first.loser.id

        results[3].id.should eq contest.rounds[3].matches.last.loser.id

        results[4].id.should eq contest.rounds[2].matches.first.loser.id
        results[5].id.should eq contest.rounds[2].matches.last.loser.id
      end
    end
  end

  describe :fill_round_with_matches do
    context '19 members' do
      let(:contest) { create :contest_with_19_members, matches_per_round: 3 }
      before { strategy.create_rounds }

      it 'should not left last vote for next day' do
        contest.rounds.first.matches.map(&:started_on).map(&:to_s).uniq.should have(3).items
        contest.rounds.second.matches.map(&:started_on).map(&:to_s).uniq.should have(3).items
      end
    end

    context '5 members' do
      let(:contest) { create :contest_with_5_members }
      before { strategy.create_rounds }

      context 'I' do
        let(:round) { contest.rounds.first }

        it 'valid' do
          round.matches.should have(3).items
          round.matches.each {|vote| vote.group.should eq ContestRound::S }
          round.matches.first.started_on.should eq contest.started_on
          round.matches.first.right_type.should_not be_nil
          round.matches.last.right_type.should be_nil
        end
      end

      context 'II' do
        let(:round) { contest.rounds[1] }

        it 'valid' do
          round.matches.should have(3).items
          round.matches[0..1].each {|vote| vote.group.should eq ContestRound::W }
          round.matches[2..2].each {|vote| vote.group.should eq ContestRound::L }
          round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          round.matches.first.right_type.should_not be_nil
        end
      end

      context 'IIa' do
        let(:round) { contest.rounds[2] }

        it 'valid' do
          round.matches.should have(1).item
          round.matches.each {|vote| vote.group.should eq ContestRound::L }
          round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          round.matches.first.right_type.should_not be_nil
        end
      end

      context 'III' do
        let(:round) { contest.rounds[3] }

        it 'valid' do
          round.matches.should have(2).items
          round.matches.first.group.should eq ContestRound::W
          round.matches.last.group.should eq ContestRound::L
          round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          round.matches.first.right_type.should_not be_nil
        end
      end

      context 'IIIa' do
        let(:round) { contest.rounds[4] }

        it 'valid' do
          round.matches.should have(1).item
          round.matches.first.group.should eq ContestRound::L
          round.matches.first.right_type.should_not be_nil
        end
      end

      context 'IV' do
        let(:round) { contest.rounds.last }

        it 'valid' do
          round.matches.should have(1).item
          round.matches.first.group.should eq ContestRound::F
          round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          round.matches.first.right_type.should_not be_nil
        end
      end
    end
  end
end
