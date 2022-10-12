describe Contest::SwissStrategy do
  let(:strategy) { contest.strategy }
  let(:contest) { create :contest, :swiss }

  describe '#total_rounds' do
    [[128, 9], [64, 8], [32, 7], [16, 6], [8, 5]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        allow(strategy).to receive :fill_round_with_matches
        expect(strategy.total_rounds).to eq rounds + 1
      end
    end
  end

  describe '#create_rounds' do
    [[128, 9], [64, 8], [32, 7], [16, 6], [8, 5]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        allow(strategy).to receive :fill_round_with_matches
        expect { strategy.create_rounds }.to change(ContestRound, :count).by rounds + 1
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

  describe '#dynamic_rounds?' do
    subject { contest.strategy }
    its(:dynamic_rounds?) { is_expected.to eq true }
  end

  describe '#fill_round_with_matches' do
    let(:contest) { create :contest, :with_5_members, :swiss }
    before { Contest::Start.call contest }

    it 'creates correct rounds' do
      contest.rounds.each { |round| expect(round.matches.size).to eq(3) }
      contest.rounds.first.matches.each { |match| expect(match.left_id).to be_present }
      contest.rounds.second.matches.each { |match| expect(match.left_id).to be_nil }
      contest.rounds.last.matches.each { |match| expect(match.left_id).to be_nil }
    end
  end

  describe '#dates' do
    let(:contest) do
      create :contest, :with_6_members, :swiss
    end
    before { Contests::GenerateRounds.call contest }

    it 'sets correct dates for matches' do
      expect(contest.rounds[0].matches[0].started_on).to eq contest.started_on
      expect(contest.rounds[1].matches[0].started_on).to eq contest.rounds[0].matches[0].finished_on + contest.matches_interval.days
      expect(contest.rounds[2].matches[0].started_on).to eq contest.rounds[1].matches[0].finished_on + contest.matches_interval.days
    end
  end

  context 'contest_with_6_members' do
    let(:contest) { create :contest, :with_6_members, :swiss }

    before do
      Contest::Start.call contest
      contest.rounds.flat_map(&:matches).each do |match|
        match.update(
          started_on: Time.zone.yesterday,
          finished_on: Time.zone.yesterday,
          cached_votes_up: 1,
          cached_votes_down: 0
        )
      end

      ContestRound::Finish.call contest.current_round
    end

    let(:w1) { strategy.statistics.members.values.at 0 }
    let(:w2) { strategy.statistics.members.values.at 2 }
    let(:w3) { strategy.statistics.members.values.at 4 }
    let(:l1) { strategy.statistics.members.values.at 1 }
    let(:l2) { strategy.statistics.members.values.at 3 }
    let(:l3) { strategy.statistics.members.values.at 5 }

    describe '#sorted_scores' do
      subject { strategy.statistics.sorted_scores }
      it do
        is_expected.to eq(
          w1.id => 1,
          w2.id => 1,
          w3.id => 1,
          l1.id => 0,
          l2.id => 0,
          l3.id => 0
        )
      end
    end

    describe '#opponents_of' do
      subject { strategy.statistics.opponents_of l2.id }
      it { is_expected.to eq [w2.id] }
    end

    describe '#advance_members' do
      describe 'I -> II' do
        before { contest.reload }

        it 'sets members for next round' do
          expect(contest.rounds[1].matches[0].left_type).to eq contest.member_klass.name
          expect(contest.rounds[1].matches[0].right_type).to eq contest.member_klass.name

          expect(contest.rounds[1].matches[0].left_id).to eq w1.id
          expect(contest.rounds[1].matches[0].right_id).to eq w2.id
          expect(contest.rounds[1].matches[1].left_id).to eq w3.id
          expect(contest.rounds[1].matches[1].right_id).to eq l1.id
          expect(contest.rounds[1].matches[2].left_id).to eq l2.id
          expect(contest.rounds[1].matches[2].right_id).to eq l3.id
        end
      end

      describe 'II -> III' do
        before { ContestRound::Finish.call contest.reload.current_round }

        it 'choose members which were not opponents in previous matches' do
          expect(contest.rounds[2].matches[0].left_id).to eq w1.id
          expect(contest.rounds[2].matches[0].right_id).to eq w3.id
          expect(contest.rounds[2].matches[1].left_id).to eq w2.id
          expect(contest.rounds[2].matches[1].right_id).to eq l1.id
          expect(contest.rounds[2].matches[2].left_id).to eq l2.id
          expect(contest.rounds[2].matches[2].right_id).to eq l3.id
        end
      end
    end

    # describe 'results' do
    #   subject { strategy.results }

    #   before do
    #     ContestRound::Finish.call contest.reload.current_round
    #     ContestRound::Finish.call contest.reload.current_round

    #     strategy.statistics.users_votes[l2.id] = 7
    #     strategy.statistics.users_votes[w3.id] = 6
    #     strategy.statistics.users_votes[w2.id] = 5
    #     strategy.statistics.users_votes[l3.id] = 2
    #   end

    #   it { is_expected.to eq [w1, l2, w3, w2, l3, l1] }
    # end
  end
end
