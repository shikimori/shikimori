describe ContestRound do
  describe 'relations' do
    it { is_expected.to belong_to :contest }
    it { is_expected.to have_many :matches }
  end

  describe 'aasm', :focus do
    subject { build :contest_round, state, matches: matches }
    let(:matches) { [] }
    let(:contest_match_created) { build :contest_match, :created }
    let(:contest_match_finished) { build :contest_match, :finished }
    let(:contest_match_may_finish) do
      build :contest_match, :started, finished_on: Time.zone.yesterday
    end
    let(:contest_match_may_not_finish) do
      build :contest_match, :started, finished_on: Time.zone.today
    end

    context 'created' do
      let(:state) { :created }

      it { is_expected.to have_state state }

      context 'has matches' do
        let(:matches) { [contest_match_created] }
        it { is_expected.to allow_transition_to :started }
        it { is_expected.to transition_from(:created).to(:started).on_event(:start) }
      end

      context 'no matches' do
        it { is_expected.to_not allow_transition_to :started }
      end

      it { is_expected.to_not allow_transition_to :finished }
    end

    context 'started' do
      let(:state) { :started }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :created }

      context 'all matches may be finished' do
        let(:matches) { [contest_match_finished, contest_match_may_finish] }
        it { is_expected.to allow_transition_to :finished }
        it { is_expected.to transition_from(:started).to(:finished).on_event(:finish) }
      end

      context 'not all matches may be finished' do
        let(:matches) do
          [
            contest_match_finished,
            [contest_match_created, contest_match_may_not_finish].sample
          ]
        end
        let(:finished_on) { Time.zone.today }
        it { is_expected.to_not allow_transition_to :finished }
      end
    end

    context 'finished' do
      let(:state) { :finished }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :created }
      it { is_expected.to_not allow_transition_to :started }
    end
  end

  describe 'instance methods' do
    describe '#next_round, #prior_round, #first?, #last?' do
      let!(:contest) { create :contest }
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
