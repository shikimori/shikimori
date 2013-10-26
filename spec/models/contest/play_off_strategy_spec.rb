require 'spec_helper'

describe Contest::PlayOffStrategy do
  let(:strategy_type) { :play_off }
  let(:strategy) { contest.strategy }

  describe :total_rounds do
    let(:contest) { build_stubbed :contest, strategy_type: strategy_type }

    [[128,7], [64,6], [32,5], [16,4]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        contest.members.stub(:count).and_return members
        contest.total_rounds.should eq rounds
      end
    end
  end

  describe :create_rounds do
    let(:contest) { create :contest, strategy_type: strategy_type }

    [[128,7], [64,6], [32,5], [16,4], [8,3]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        contest.members.stub(:count).and_return members
        strategy.stub :fill_round_with_matches
        expect { strategy.create_rounds }.to change(ContestRound, :count).by rounds
      end
    end

    it 'sets correct number&additional' do
      contest.members.stub(:count).and_return 16
      strategy.stub :fill_round_with_matches
      strategy.create_rounds

      contest.rounds[0].number.should eq 1
      contest.rounds.any? {|v| v.additional }.should be_false

      contest.rounds[1].number.should eq 2
      contest.rounds[2].number.should eq 3
      contest.rounds[3].number.should eq 4
    end
  end

  describe :advance_members do
    let(:contest) { create :contest_with_5_members, strategy_type: strategy_type }
    let(:w1) { contest.rounds[0].matches[0].left }
    let(:w2) { contest.rounds[0].matches[1].left }
    let(:w3) { contest.rounds[0].matches[2].left }

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

        contest.current_round.matches[2].should be_nil
      end
    end

    context 'II -> III' do
      before do
        2.times { |i| contest.rounds[i].matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday } }
        2.times do |i|
          contest.current_round.reload
          contest.current_round.finish!
        end
      end

      it 'winners&losers' do
        contest.current_round.matches[0].left.should eq w1
        contest.current_round.matches[0].right.should eq w3

        contest.current_round.matches[1].should be_nil
      end
    end
  end

  describe :with_additional_rounds? do
    subject { build_stubbed(:contest, strategy_type: strategy_type).strategy }
    its(:with_additional_rounds?) { should be_false }
  end

  describe :dynamic_rounds? do
    subject { build_stubbed(:contest, strategy_type: strategy_type).strategy }
    its(:dynamic_rounds?) { should be_false }
  end

  describe :results do
    let(:contest) { create :contest_with_8_members, :anime, strategy_type: strategy_type }
    let(:results) { contest.results }
    let(:scores) { contest.strategy.statistics.scores }
    let(:statistics) { contest.strategy.statistics }
    before do
      contest.start!
      contest.rounds.each do |round|
        contest.current_round.matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday }
        contest.process!
        contest.reload
      end

      scores[contest.rounds[1].matches.first.loser.id] = 2
      scores[contest.rounds[1].matches.last.loser.id] = 2

      statistics.average_votes[contest.rounds[1].matches[0].loser.id] = 2
      statistics.average_votes[contest.rounds[1].matches[1].loser.id] = 1

      scores[contest.rounds[0].matches[3].loser.id] = 1
      scores[contest.rounds[0].matches[1].loser.id] = 1
      scores[contest.rounds[0].matches[2].loser.id] = 0
      scores[contest.rounds[0].matches[0].loser.id] = 0

      statistics.average_votes(contest.rounds[0])[contest.rounds[0].matches[3].loser.id] = 4
      statistics.average_votes(contest.rounds[0])[contest.rounds[0].matches[1].loser.id] = 3
      statistics.average_votes(contest.rounds[0])[contest.rounds[0].matches[2].loser.id] = 2
      statistics.average_votes(contest.rounds[0])[contest.rounds[0].matches[0].loser.id] = 1
    end

    it 'has expected results' do
      # count
      results.should have(contest.members.size).items

      # final
      results[0].id.should eq contest.rounds[2].matches.first.winner.id
      results[1].id.should eq contest.rounds[2].matches.first.loser.id

      # semifinal
      results[2].id.should eq contest.rounds[1].matches.first.loser.id
      results[3].id.should eq contest.rounds[1].matches.last.loser.id

      # other
      results[4].id.should eq contest.rounds[0].matches[3].loser.id
      results[5].id.should eq contest.rounds[0].matches[1].loser.id
      results[6].id.should eq contest.rounds[0].matches[2].loser.id
      results[7].id.should eq contest.rounds[0].matches[0].loser.id
    end
  end
end
