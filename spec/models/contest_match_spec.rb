describe ContestMatch do
  describe 'relations' do
    it { is_expected.to belong_to :round }
    it { is_expected.to belong_to :left }
    it { is_expected.to belong_to :right }
  end

  describe 'state_machine' do
    it { is_expected.to have_states :created, :started, :finished }

    it { is_expected.to reject_events :finish, when: :created }
    it { is_expected.to reject_events :start, when: :started }
    it { is_expected.to reject_events :start, :finish, when: :finished }

    context 'match.started_on <= Time.zone.today' do
      before { subject.started_on = Time.zone.yesterday }
      it { is_expected.to handle_events :start, when: :created }
    end
    context 'match.started_on < Time.zone.today' do
      before { subject.started_on = Time.zone.tomorrow }
      it { is_expected.to reject_events :start, when: :created }
    end

    context 'match.finished_on < Time.zone.today' do
      before { subject.finished_on = Time.zone.yesterday }
      it { is_expected.to handle_events :finish, when: :started }
    end
    context 'match.finished_on >= Time.zone.today' do
      before { subject.finished_on = Time.zone.today }
      it { is_expected.to reject_events :finish, when: :started }
    end

    let(:match) do
      create :contest_match,
        started_on: Time.zone.yesterday,
        finished_on: Time.zone.yesterday
    end

    describe 'can_finish?' do
      subject { match.can_finish? }
      before { match.start! }

      context 'true' do
        before { match.finished_on = Time.zone.yesterday }
        it { is_expected.to eq true }
      end

      context 'false' do
        before { match.finished_on = Time.zone.today }
        it { is_expected.to eq false }
      end
    end

    context 'can_start?' do
      subject { match.can_start? }

      context 'true' do
        before { match.started_on = Time.zone.today }
        it { is_expected.to eq true }
      end

      context 'false' do
        before { match.started_on = Time.zone.tomorrow }
        it { is_expected.to eq false }
      end
    end
  end

  describe 'instance_methods' do
    include_context :seeds

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
        it { expect(match.loser).to be_nil }
      end
    end
  end
end
