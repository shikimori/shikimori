describe ContestRound do
  describe 'relations' do
    it { should belong_to :contest }
    it { should have_many :matches }
  end

  describe 'state_machine' do
    let(:contest) { create :contest, :with_5_members, state: 'started' }
    let(:round) { create :contest_round, contest: contest }

    it 'full cycle' do
      expect(round.created?).to eq true

      contest.strategy.fill_round_with_matches round
      round.start!
      expect(round.started?).to eq true

      round.matches.each {|v| v.state = 'finished' }
      round.finish!
      expect(round.finished?).to eq true
    end

    describe '#can_start?' do
      subject { round.can_start? }

      context 'no matches' do
        it { should eq false }
      end

      context 'has matches' do
        before { allow(round.matches).to receive(:any?).and_return true }
        it { should eq true }
      end
    end

    describe '#can_finish?' do
      subject { round.can_finish? }

      context 'not finished matches' do
        before { contest.strategy.fill_round_with_matches round }
        before { round.start! }

        it { should eq false }

        context 'finished matches' do
          context 'all finished' do
            before { round.matches.each {|v| v.state = 'finished' } }
            it { should eq true }
          end

          context 'all can_finish' do
            before { round.matches.each {|v| allow(v).to receive(:can_finish?).and_return true } }
            it { should eq true }
          end
        end
      end
    end

    context 'after started' do
      before { contest.strategy.fill_round_with_matches round }

      it 'starts today matches' do
        round.start!
        round.matches.each do |vote|
          expect(vote.started?).to eq true
        end
      end

      it 'does not start matches in future' do
        round.matches.each {|v| v.started_on = Date.tomorrow }
        round.start!

        round.matches.each do |vote|
          expect(vote.started?).to eq false
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
        it { round.matches.each {|v| expect(v.finished?).to eq true } }
      end
    end

    context 'after finished' do
      before { allow(NotificationsService).to receive(:new).with(round).and_return notification_service }
      before do
        contest.strategy.fill_round_with_matches round
        round.start!
        round.matches.each {|v| v.finished_on = Date.yesterday }
      end
      let(:next_round) { create :contest_round }
      let(:notification_service) { double round_finished: true }

      it 'starts&fills next round' do
        allow(round).to receive(:next_round).and_return next_round

        expect(next_round).to receive :start!
        expect(round.strategy).to receive(:advance_members).with next_round, round
        expect(notification_service).to receive :round_finished

        round.finish!
      end

      it 'finishes contest' do
        round.finish!
        expect(round.contest.finished?).to eq true
      end
    end
  end

  describe 'instance methods' do
    describe '#next_round, #prior_round, #first?, #last?' do
      let!(:contest) { build_stubbed :contest }
      let!(:round_1) { create :contest_round, contest: contest }
      let!(:round_2) { create :contest_round, contest: contest }
      let!(:round_3) { create :contest_round, contest: contest }

      it do
        expect(round_1.next_round).to eq round_2
        expect(round_2.next_round).to eq round_3
        expect(round_3.next_round).to be_nil

        expect(round_1.prior_round).to be_nil
        expect(round_2.prior_round).to eq round_1
        expect(round_3.prior_round).to eq round_2

        expect(round_1.first?).to eq true
        expect(round_2.first?).to eq false
        expect(round_3.first?).to eq false

        expect(round_1.last?).to eq false
        expect(round_2.last?).to eq false
        expect(round_3.last?).to eq true
      end
    end
  end

  describe '#strategy' do
    subject(:contest_round) { build_stubbed :contest_round }
    its(:strategy) { should eq contest_round.contest.strategy }
  end

  describe '#title' do
    let(:round) { build :contest_round, number: 5, additional: true }
    it { expect(round.title).to eq 'Раунд #5a' }
  end
end
