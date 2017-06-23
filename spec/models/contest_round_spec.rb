describe ContestRound do
  describe 'relations' do
    it { is_expected.to belong_to :contest }
    it { is_expected.to have_many :matches }
  end

  describe 'state_machine' do
    let(:contest) { create :contest, :with_5_members, state: 'started' }
    let(:round) { create :contest_round, contest: contest }

    it 'full cycle' do
      expect(round.created?).to eq true

      contest.strategy.fill_round_with_matches round
      ContestRound::Start.call round
      expect(round.started?).to eq true

      round.matches.each {|v| v.state = 'finished' }
      round.finish!
      expect(round.finished?).to eq true
    end

    describe '#can_start?' do
      subject { round.can_start? }

      context 'no matches' do
        it { is_expected.to eq false }
      end

      context 'has matches' do
        before { allow(round.matches).to receive(:any?).and_return true }
        it { is_expected.to eq true }
      end
    end

    describe '#can_finish?' do
      subject { round.can_finish? }

      context 'not finished matches' do
        before do
          contest.strategy.fill_round_with_matches round
          ContestRound::Start.call round
        end

        it { is_expected.to eq false }

        context 'finished matches' do
          context 'all finished' do
            before { round.matches.each {|v| v.state = 'finished' } }
            it { is_expected.to eq true }
          end

          context 'all can_finish' do
            before { round.matches.each {|v| allow(v).to receive(:can_finish?).and_return true } }
            it { is_expected.to eq true }
          end
        end
      end
    end

    context 'before finished' do
      before do
        contest.strategy.fill_round_with_matches round
        ContestRound::Start.call round
        round.matches.each {|v| v.finished_on = Time.zone.yesterday }
      end

      describe 'finishes unfinished matches' do
        before { round.finish! }
        it { round.matches.each {|v| expect(v.finished?).to eq true } }
      end
    end

    context 'after finished' do
      before do
        allow(Messages::CreateNotification)
          .to receive(:new)
          .and_return notification_service
      end

      let(:next_round) { create :contest_round }
      let(:notification_service) do
        double round_finished: true, contest_finished: true
      end

      before do
        contest.strategy.fill_round_with_matches round
        ContestRound::Start.call round
        round.matches.each { |v| v.finished_on = Time.zone.yesterday }
      end

      it 'starts&fills next round' do
        allow(round).to receive(:next_round).and_return next_round

        expect(next_round).to receive :start!
        expect(round.strategy).to receive(:advance_members).with next_round, round
        expect(notification_service).to receive :round_finished
        # expect(notification_service).to_not receive :contest_finished

        round.finish!
      end

      it 'finishes contest' do
        round.finish!
        expect(round.contest).to be_finished
        expect(notification_service).to_not receive :round_finished
        # expect(notification_service).to receive :contest_finished
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
    its(:strategy) { is_expected.to eq contest_round.contest.strategy }
  end

  describe '#title' do
    let(:round) { build :contest_round, number: 5, additional: true }
    it { expect(round.title).to eq 'Раунд #5a' }
  end
end
