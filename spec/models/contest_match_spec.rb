describe ContestMatch do
  describe 'relations' do
    it { is_expected.to belong_to :round }
    it { is_expected.to belong_to(:left).optional }
    it { is_expected.to belong_to(:right).optional }
  end

  describe 'aasm' do
    context 'created' do
      it { is_expected.to have_state :created }

      context 'started_on <= Time.zone.today' do
        before { subject.started_on = Time.zone.yesterday }
        it { is_expected.to allow_transition_to :started }
        it { is_expected.to transition_from(:created).to(:started).on_event(:start) }
      end

      context 'started_on < Time.zone.today' do
        before { subject.started_on = Time.zone.tomorrow }
        it { is_expected.to_not allow_transition_to :started }
      end

      it { is_expected.to_not allow_transition_to :finished }
    end

    context 'started' do
      before { subject.state = :started }
      it { is_expected.to have_state :started }
      it { is_expected.to_not allow_transition_to :created }

      context 'finished_on < Time.zone.today' do
        before { subject.finished_on = Time.zone.yesterday }
        it { is_expected.to allow_transition_to :finished }
        it { is_expected.to transition_from(:started).to(:finished).on_event(:finish) }
      end

      context 'finished_on >= Time.zone.today' do
        before { subject.finished_on = Time.zone.today }
        it { is_expected.to_not allow_transition_to :finished }
      end
    end

    context 'finished' do
      before { subject.state = :finished }
      it { is_expected.to have_state :finished }
      it { is_expected.to_not allow_transition_to :created }
      it { is_expected.to_not allow_transition_to :started }
    end
  end

  describe 'instance_methods' do
    describe '#winner' do
      let(:match) { build_stubbed :contest_match, state: 'finished' }
      subject { match.winner }

      describe 'left' do
        before { match.winner_id = match.left_id }
        its(:id) { is_expected.to eq match.left.id }
      end

      describe 'right' do
        before { match.winner_id = match.right_id }
        its(:id) { is_expected.to eq match.right.id }
      end

      describe 'no winner' do
        before { match.winner_id = nil }
        it { is_expected.to be_nil }
      end
    end

    describe '#loser' do
      let(:match) { build_stubbed :contest_match, state: 'finished' }
      subject { match.loser }

      describe 'left' do
        before { match.winner_id = match.left_id }
        its(:id) { is_expected.to eq match.right.id }
      end

      describe 'right' do
        before { match.winner_id = match.right_id }
        its(:id) { is_expected.to eq match.left.id }
      end

      describe 'no loser' do
        before do
          match.winner_id = match.left_id
          match.right = nil
        end
        it { is_expected.to be_nil }
      end
    end

    describe '#draw?' do
      context 'not finished' do
        subject { build :contest_match, %i[created started].sample }
        it { is_expected.to_not be_draw }
      end

      context 'finished' do
        subject do
          build :contest_match, :finished,
            left_id: left_id,
            right_id: right_id,
            winner_id: winner_id
        end
        let(:left_id) { 1 }
        let(:right_id) { 1 }

        context 'has winner' do
          let(:winner_id) { [left_id, right_id].sample }
          it { is_expected.to_not be_draw }
        end

        context 'no winner' do
          let(:winner_id) { nil }
          it { is_expected.to be_draw }
        end
      end
    end
  end
end
