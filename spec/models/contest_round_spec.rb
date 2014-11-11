describe ContestRound, :type => :model do
  context :relations do
    it { should belong_to :contest }
    it { should have_many :matches }
  end

  describe :state_machine do
    let(:contest) { create :contest, :with_5_members, state: 'started' }
    let(:round) { create :contest_round, contest: contest }

    it 'full cycle' do
      expect(round.created?).to be_truthy

      contest.strategy.fill_round_with_matches round
      round.start!
      expect(round.started?).to be_truthy

      round.matches.each {|v| v.state = 'finished' }
      round.finish!
      expect(round.finished?).to be_truthy
    end

    describe :can_start? do
      subject { round.can_start? }

      context 'no matches' do
        it { should be_falsy }
      end

      context 'has matches' do
        before { allow(round.matches).to receive(:any?).and_return true }
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
            before { round.matches.each {|v| allow(v).to receive(:can_finish?).and_return true } }
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
          expect(vote.started?).to be_truthy
        end
      end

      it 'does not start matches in future' do
        round.matches.each {|v| v.started_on = Date.tomorrow }
        round.start!

        round.matches.each do |vote|
          expect(vote.started?).to be_falsy
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
        it { round.matches.each {|v| expect(v.finished?).to be_truthy } }
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
        allow(round).to receive(:next_round).and_return next_round

        expect(next_round).to receive :start!
        expect(round.strategy).to receive(:advance_members).with next_round, round

        round.finish!
      end

      it 'finishes contest' do
        round.finish!
        expect(round.contest.finished?).to be_truthy
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
        expect(round1.next_round).to eq round2
        expect(round2.next_round).to eq round3
        expect(round3.next_round).to be_nil
      end
    end

    describe :prior_round do
      it 'should be valid' do
        expect(round1.prior_round).to be_nil
        expect(round2.prior_round).to eq round1
        expect(round3.prior_round).to eq round2
      end
    end

    describe :first? do
      it 'should be valid' do
        expect(round1.first?).to be_truthy
        expect(round2.first?).to be_falsy
        expect(round3.first?).to be_falsy
      end
    end

    describe :last? do
      it 'should be valid' do
        expect(round1.last?).to be_falsy
        expect(round2.last?).to be_falsy
        expect(round3.last?).to be_truthy
      end
    end
  end

  describe :strategy do
    subject(:contest_round) { build_stubbed :contest_round }
    its(:strategy) { should eq contest_round.contest.strategy }
  end
end
