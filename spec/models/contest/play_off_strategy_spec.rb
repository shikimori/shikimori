describe Contest::PlayOffStrategy do
  let(:strategy) { contest.strategy }
  let(:contest) { build_stubbed :contest, :play_off }

  describe '#total_rounds' do
    [[128, 7], [64, 6], [32, 5], [16, 4]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        expect(strategy.total_rounds).to eq rounds
      end
    end
  end

  describe '#create_rounds' do
    let(:contest) { create :contest, :play_off }

    [[128, 7], [64, 6], [32, 5], [16, 4], [8, 3]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        allow(strategy).to receive :fill_round_with_matches
        expect { strategy.create_rounds }.to change(ContestRound, :count).by rounds
      end
    end

    it 'sets correct number&additional' do
      allow(contest.members).to receive(:count).and_return 16
      allow(strategy).to receive :fill_round_with_matches
      strategy.create_rounds

      expect(contest.rounds[0].number).to eq 1
      expect(contest.rounds.any?(&:additional)).to eq false

      expect(contest.rounds[1].number).to eq 2
      expect(contest.rounds[2].number).to eq 3
      expect(contest.rounds[3].number).to eq 4
    end
  end

  describe '#advance_members' do
    let(:contest) { create :contest, :with_5_members, :play_off }
    let(:w1) { contest.rounds[0].matches[0].left }
    let(:w2) { contest.rounds[0].matches[1].left }
    let(:w3) { contest.rounds[0].matches[2].left }

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

        expect(contest.current_round.matches[2]).to be_nil
      end
    end

    context 'II -> III' do
      before do
        2.times do |i|
          contest.rounds[i].matches.each do |contest_match|
            contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
          end
        end
        2.times { ContestRound::Finish.call contest.current_round }
      end

      it 'winners&losers' do
        expect(contest.current_round.matches[0].left).to eq w1
        expect(contest.current_round.matches[0].right).to eq w3

        expect(contest.current_round.matches[1]).to be_nil
      end
    end
  end

  describe '#with_additional_rounds?' do
    subject { contest.strategy }
    its(:with_additional_rounds?) { is_expected.to eq false }
  end

  describe '#dynamic_rounds?' do
    subject { contest.strategy }
    its(:dynamic_rounds?) { is_expected.to eq false }
  end

  describe '#results' do
    let(:contest) { create :contest, :with_8_members, :anime, :play_off }
    let(:results) { strategy.results }
    let(:scores) { contest.strategy.statistics.scores }
    let(:statistics) { contest.strategy.statistics }
    before do
      Contest::Start.call contest
      contest.rounds.each do |_round|
        contest.current_round.matches.each do |contest_match|
          contest_match.update started_on: Time.zone.yesterday, finished_on: Time.zone.yesterday
        end
        Contest::Progress.call contest
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
      expect(results.size).to eq(contest.members.size)

      # final
      expect(results[0].id).to eq contest.rounds[2].matches.first.winner.id
      expect(results[1].id).to eq contest.rounds[2].matches.first.loser.id

      # semifinal
      expect(results[2].id).to eq contest.rounds[1].matches.first.loser.id
      expect(results[3].id).to eq contest.rounds[1].matches.last.loser.id

      # other
      expect(results[4].id).to eq contest.rounds[0].matches[3].loser.id
      expect(results[5].id).to eq contest.rounds[0].matches[1].loser.id
      expect(results[6].id).to eq contest.rounds[0].matches[2].loser.id
      expect(results[7].id).to eq contest.rounds[0].matches[0].loser.id
    end
  end
end
