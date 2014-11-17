describe Contest::SwissStrategy do
  let(:strategy_type) { :swiss }
  let(:strategy) { contest.strategy }

  describe 'total_rounds' do
    let(:contest) { build_stubbed :contest, strategy_type: strategy_type }

    [[128,9], [64,8], [32,7], [16,6], [8,5]].each do |members, rounds|
      it "#{members} -> #{rounds}" do
        allow(contest.members).to receive(:count).and_return members
        allow(strategy).to receive :fill_round_with_matches
        expect(contest.total_rounds).to eq rounds
      end
    end
  end

  describe 'create_rounds' do
    let(:contest) { create :contest, strategy_type: strategy_type }

    [[128,9], [64,8], [32,7], [16,6], [8,5]].each do |members, rounds|
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
      expect(contest.rounds.any? {|v| v.additional }).to be_falsy

      expect(contest.rounds[1].number).to eq 2
      expect(contest.rounds[2].number).to eq 3
      expect(contest.rounds[3].number).to eq 4
    end
  end

  describe 'dynamic_rounds?' do
    subject { build_stubbed(:contest, strategy_type: strategy_type).strategy }
    its(:dynamic_rounds?) { should be_truthy }
  end

  describe 'fill_round_with_matches' do
    let(:contest) { create :contest, :with_5_members, strategy_type: strategy_type }
    before { contest.start! }

    it 'creates correct rounds' do
      contest.rounds.each {|v| expect(v.matches.size).to eq(3) }
      contest.rounds.first.matches.each {|v| expect(v.left_id).to be_present }
      contest.rounds.second.matches.each {|v| expect(v.left_id).to be_nil }
      contest.rounds.last.matches.each {|v| expect(v.left_id).to be_nil }
    end
  end

  describe 'dates' do
    let(:contest) { create :contest, :with_6_members, strategy_type: strategy_type }
    before { contest.prepare }

    it 'sets correct dates for matches' do
      expect(contest.rounds[0].matches[0].started_on).to eq contest.started_on
      expect(contest.rounds[1].matches[0].started_on).to eq contest.rounds[0].matches[0].finished_on + contest.matches_interval.days
      expect(contest.rounds[2].matches[0].started_on).to eq contest.rounds[1].matches[0].finished_on + contest.matches_interval.days
    end
  end

  context 'contest_with_6_members' do
    let(:contest) { create :contest, :with_6_members, strategy_type: strategy_type }
    before do
      contest.start!
      contest.rounds.map(&:matches).flatten.each do |v|
        v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday
      end
      contest.current_round.finish!
    end
    let(:w1) { strategy.statistics.members.values.at 0 }
    let(:w2) { strategy.statistics.members.values.at 2 }
    let(:w3) { strategy.statistics.members.values.at 4 }
    let(:l1) { strategy.statistics.members.values.at 1 }
    let(:l2) { strategy.statistics.members.values.at 3 }
    let(:l3) { strategy.statistics.members.values.at 5 }

    describe 'sorted_scores' do
      subject { strategy.statistics.sorted_scores }
      it { should eq(w1.id => 1, w2.id => 1, w3.id => 1, l1.id => 0, l2.id => 0, l3.id => 0) }
    end

    describe 'opponents_of' do
      subject { strategy.statistics.opponents_of l2.id }
      it { should eq [w2.id] }
    end

    describe 'advance_members' do
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
        before { contest.reload.current_round.finish! }

        it 'should pick up members which were not opponents in previous matches' do
          expect(contest.rounds[2].matches[0].left_id).to eq w1.id
          expect(contest.rounds[2].matches[0].right_id).to eq w3.id
          expect(contest.rounds[2].matches[1].left_id).to eq w2.id
          expect(contest.rounds[2].matches[1].right_id).to eq l1.id
          expect(contest.rounds[2].matches[2].left_id).to eq l2.id
          expect(contest.rounds[2].matches[2].right_id).to eq l3.id
        end
      end
    end

    describe 'results' do
      subject { strategy.results }
      before do
        contest.reload.current_round.finish!
        contest.reload.current_round.finish!

        strategy.statistics.users_votes[l2.id] = 7
        strategy.statistics.users_votes[w3.id] = 6
        strategy.statistics.users_votes[w2.id] = 5
        strategy.statistics.users_votes[l3.id] = 2
      end

      it { should eq [w1, l2, w3, w2, l3, l1] }
    end
  end
end
