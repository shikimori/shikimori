describe ContestRound do
  context :relations do
    it { should belong_to :contest }
    it { should have_many :matches }
  end

  describe :state_machine do
    let(:contest) { create :contest, :with_5_members, state: 'started' }
    let(:round) { create :contest_round, contest: contest }

    it 'full cycle' do
      round.created?.should be_truthy

      contest.strategy.fill_round_with_matches round
      round.start!
      round.started?.should be_truthy

      round.matches.each {|v| v.state = 'finished' }
      round.finish!
      round.finished?.should be_truthy
    end

    describe :can_start? do
      subject { round.can_start? }

      context 'no matches' do
        it { should be_falsy }
      end

      context 'has matches' do
        before { round.matches.stub(:any?).and_return true }
        it { should be_truthy }
      end
    end

    describe :can_finish? do
      subject { round.can_finish? }

      context 'not finished matches' do
        before { contest.strategy.fill_round_with_matches round }
        before { round.start! }

        it { should be_falsy }

        context 'finished matches' do
          context 'all finished' do
            before { round.matches.each {|v| v.state = 'finished' } }
            it { should be_truthy }
          end

          context 'all can_finish' do
            before { round.matches.each {|v| v.stub(:can_finish?).and_return true } }
            it { should be_truthy }
          end
        end
      end
    end

    context 'after started' do
      before { contest.strategy.fill_round_with_matches round }

      it 'starts today matches' do
        round.start!
        round.matches.each do |vote|
          vote.started?.should be_truthy
        end
      end

      it 'does not start matches in future' do
        round.matches.each {|v| v.started_on = Date.tomorrow }
        round.start!

        round.matches.each do |vote|
          vote.started?.should be_falsy
        end
      end
    end

    context 'before finished' do
      before do
        contest.strategy.fill_round_with_matches round
        round.start!
        round.matches.each {|v| v.finished_on = Date.yesterday }
      end

      describe 'finishes unfinished matches' do
        before { round.finish! }
        it { round.matches.each {|v| v.finished?.should be_truthy } }
      end
    end

    context 'after finished' do
      before do
        contest.strategy.fill_round_with_matches round
        round.start!
        round.matches.each {|v| v.finished_on = Date.yesterday }
      end
      let(:next_round) { create :contest_round }

      it 'starts&fills next round' do
        round.stub(:next_round).and_return next_round

        next_round.should_receive :start!
        round.strategy.should_receive(:advance_members).with next_round, round

        round.finish!
      end

      it 'finishes contest' do
        round.finish!
        round.contest.finished?.should be_truthy
      end
    end
  end

  context :navigation do
    let!(:contest) { create :contest }
    let!(:round1) { create :contest_round, contest: contest }
    let!(:round2) { create :contest_round, contest: contest }
    let!(:round3) { create :contest_round, contest: contest }

    describe :next_round do
      it 'should be valid' do
        round1.next_round.should eq round2
        round2.next_round.should eq round3
        round3.next_round.should be_nil
      end
    end

    describe :prior_round do
      it 'should be valid' do
        round1.prior_round.should be_nil
        round2.prior_round.should eq round1
        round3.prior_round.should eq round2
      end
    end

    describe :first? do
      it 'should be valid' do
        round1.first?.should be_truthy
        round2.first?.should be_falsy
        round3.first?.should be_falsy
      end
    end

    describe :last? do
      it 'should be valid' do
        round1.last?.should be_falsy
        round2.last?.should be_falsy
        round3.last?.should be_truthy
      end
    end
  end

  describe :strategy do
    subject(:contest_round) { build_stubbed :contest_round }
    its(:strategy) { should eq contest_round.contest.strategy }
  end
end
