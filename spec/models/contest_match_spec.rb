describe ContestMatch do
  describe 'relations' do
    it { is_expected.to belong_to :round }
    it { is_expected.to belong_to :left }
    it { is_expected.to belong_to :right }
    it { is_expected.to have_many :votes }
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

    describe '#can_vote?' do
      subject { match.can_vote? }

      context 'created' do
        let(:match) { build_stubbed :contest_match, :created }
        it { is_expected.to eq false }
      end

      context 'started' do
        let(:match) { build_stubbed :contest_match, :started }
        it { is_expected.to eq true }
      end

      context 'finished' do
        let(:match) { build_stubbed :contest_match, :finished }
        it { is_expected.to eq false }
      end
    end

    describe '#vote_for' do
      let(:match) { create :contest_match, state: 'started' }

      it 'creates ContestUserVote' do
        expect(proc do
          match.vote_for 'left', user, '123'
        end).to change(ContestUserVote, :count).by 1
      end

      context 'no match' do
        context 'left' do
          before { match.vote_for 'left', user, '123' }
          it { expect(match.votes.first.item_id).to eq match.left_id }
        end

        context 'right' do
          before { match.vote_for 'right', user, '123' }
          it { expect(match.votes.first.item_id).to eq match.right_id }
        end

        context 'none' do
          before { match.vote_for 'none', user, '123' }
          it { expect(match.votes.first.item_id).to eq 0 }
        end

        context 'user' do
          before { match.vote_for 'right', user, '123' }
          it { expect(match.votes.first.user_id).to eq user.id }
        end

        context 'ip' do
          before { match.vote_for 'right', user, '123' }
          it { expect(match.votes.first.ip).to eq '123' }
        end
      end

      context 'has match' do
        before do
          match.vote_for 'left', user, '123'
          match.vote_for 'right', user, '123'
        end

        it { expect(match.votes.first.item_id).to eq match.right_id }
        it { expect(match.votes.count).to eq 1 }
      end
    end

    describe '#voted_id' do
      let!(:match) { create :contest_match, state: 'started', round: build_stubbed(:contest_round) }
      let(:vote_with_user_vote) { ContestMatch.with_user_vote(user, '').first }
      subject { vote_with_user_vote.voted_id }

      context 'not_voted' do
        it { is_expected.to be_nil }
      end

      context 'voted' do
        context 'really_voted' do
          context 'left' do
            before { match.vote_for(:left, user, '') }
            it { is_expected.to eq match.left_id }
          end

          context 'right' do
            before { match.vote_for(:right, user, '') }
            it { is_expected.to eq match.right_id }
          end
        end

        context 'right_type_is_nil' do
          before { vote_with_user_vote.right_type = nil }
          it { is_expected.to be_nil }
        end
      end
    end

    describe '#voted?' do
      let!(:match) { create :contest_match, state: 'started', round: build_stubbed(:contest_round) }
      let(:vote_with_user_vote) { ContestMatch.with_user_vote(user, '').first }
      subject { vote_with_user_vote.voted? }

      context 'not_voted' do
        it { is_expected.to eq false }
      end

      context 'voted' do
        context 'really_voted' do
          context 'left' do
            before { match.vote_for(:left, user, '') }
            it { is_expected.to eq true }
          end

          context 'right' do
            before { match.vote_for(:right, user, '') }
            it { is_expected.to eq true }
          end
        end

        context 'right_type_is_nil' do
          before { vote_with_user_vote.right_type = nil }
          it { is_expected.to eq true }
        end
      end
    end

    describe '#update_user' do
      let(:round) { create :contest_round, state: 'started' }
      subject { user.can_vote_1? }
      before do
        create :contest_match, state: 'started', left_type: 'Anime', right_type: 'Anime', left_id: 1, right_id: 2, round_id: round.id, round: build_stubbed(:contest_round)
        create :contest_match, state: 'started', left_type: 'Anime', right_type: 'Anime', left_id: 3, right_id: 4, round_id: round.id, round: build_stubbed(:contest_round)
      end

      describe 'not updated' do
        let(:user) { create :user, can_vote_1: true }
        before do
          round.matches.last.vote_for 'left', user, 'z'
          ContestMatch.first.update_user user, 'z'
        end

        it { is_expected.to eq true }
      end

      describe 'updated' do
        let(:user) { create :user, can_vote_1: true }
        before do
          round.matches.first.vote_for 'left', user, 'z'
          round.matches.last.vote_for 'left', user, 'z'
          round.matches.first.update_user user, 'z'
        end

        it { is_expected.to eq false }
      end
    end

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
