# frozen_string_literal: true

describe Contest do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:links).dependent :destroy }
    it { is_expected.to have_many(:rounds).dependent :destroy }
    it { is_expected.to have_many(:winners).dependent :destroy }

    it { is_expected.to have_many :anime_winners }
    it { is_expected.to have_many :character_winners }

    it { is_expected.to have_many(:suggestions).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title_ru }
    # it { is_expected.to validate_presence_of :title_en }
    it { is_expected.to validate_length_of(:description_ru).is_at_most(32768) }
    it { is_expected.to validate_length_of(:description_en).is_at_most(32768) }
    it { is_expected.to validate_presence_of :strategy_type }
    it { is_expected.to validate_presence_of :member_type }
    it { is_expected.to validate_presence_of :started_on }
    it { is_expected.to validate_presence_of :user_vote_key }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:member_type)
        .in(*Types::Contest::MemberType.values)
      is_expected
        .to enumerize(:strategy_type)
        .in(*Types::Contest::StrategyType.values)
      is_expected
        .to enumerize(:user_vote_key)
        .in(*Types::Contest::UserVoteKey.values)
    end
  end

  describe 'aasm' do
    subject { build :contest, state, rounds: rounds }

    let(:rounds) { [] }
    let(:contest_round_created) { build :contest_round, :created }
    let(:contest_round_started) { build :contest_round, :started }
    let(:contest_round_finished) { build :contest_round, :finished }

    before { allow(subject).to receive :generate_missing_topics }

    context 'created' do
      let(:state) { Types::Contest::State[:created] }

      it { is_expected.to have_state state }

      describe 'transition to proposing' do
        it { is_expected.to transition_from(state).to(:proposing).on_event(:propose) }

        context 'generate_missing_topics callback' do
          before { subject.propose! }
          it do
            is_expected.to have_state :proposing
            expect(subject).to have_received :generate_missing_topics
          end
        end
      end

      describe 'transition to started' do
        before { allow(subject.links).to receive(:count).and_return links_count }

        context 'allowed count' do
          let(:links_count) do
            [
              Contest::MINIMUM_MEMBERS,
              Contest::MINIMUM_MEMBERS + 1,
              Contest::MAXIMUM_MEMBERS - 1,
              Contest::MAXIMUM_MEMBERS
            ].sample
          end

          it { is_expected.to allow_transition_to :started }
          it { is_expected.to transition_from(state).to(:started).on_event(:start) }

          context 'generate_missing_topics callback' do
            before { subject.start! }
            it do
              is_expected.to have_state :started
              expect(subject).to have_received :generate_missing_topics
            end
          end
        end

        context 'less than MINIMUM_MEMBERS' do
          let(:links_count) { Contest::MINIMUM_MEMBERS - 1 }
          it { is_expected.to_not allow_transition_to :started }
        end

        context 'Contest::MAXIMUM_MEMBERS' do
          let(:links_count) { Contest::MAXIMUM_MEMBERS + 1 }
          it { is_expected.to_not allow_transition_to :started }
        end
      end

      it { is_expected.to_not allow_transition_to :finished }
    end

    context 'proposing' do
      let(:state) { Types::Contest::State[:proposing] }

      it { is_expected.to have_state state }
      it { is_expected.to transition_from(state).to(:created).on_event(:stop_propose) }
      it { is_expected.to_not allow_transition_to :started }
      it { is_expected.to_not allow_transition_to :finished }
    end

    context 'started' do
      let(:state) { Types::Contest::State[:started] }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :created }
      it { is_expected.to_not allow_transition_to :proposing }

      describe 'transition to finished' do
        context 'all rounds are finished' do
          let(:rounds) { [contest_round_finished] }
          it { is_expected.to allow_transition_to :finished }
          it { is_expected.to transition_from(state).to(:finished).on_event(:finish) }
        end

        context 'not all rounds are finished' do
          let(:rounds) do
            [
              contest_round_finished,
              [contest_round_created, contest_round_started].sample
            ]
          end
          it { is_expected.to_not allow_transition_to :finished }
        end
      end
    end

    context 'finished' do
      let(:state) { Types::Contest::State[:finished] }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :created }
      it { is_expected.to_not allow_transition_to :proposing }
      it { is_expected.to_not allow_transition_to :started }
    end
  end

  describe 'instance methods' do
    describe '#current_round' do
      let(:contest) { create :contest, :with_5_members }
      before { Contests::GenerateRounds.call contest }

      it 'first round' do
        expect(contest.current_round).to eq contest.rounds.first
      end

      it 'started round' do
        allow(contest.rounds[1]).to receive(:started?).and_return true
        expect(contest.current_round).to eq contest.rounds.second
      end

      it 'first created' do
        allow(contest.rounds[0]).to receive(:finished?).and_return true
        expect(contest.current_round).to eq contest.rounds.second
      end

      it 'last round' do
        contest.state = 'finished'
        expect(contest.current_round).to eq contest.rounds.last
      end
    end

    describe '#defeated_by' do
      let(:contest) { create :contest }
      let(:round1) { create :contest_round, contest_id: contest.id }
      let(:round2) { create :contest_round, contest_id: contest.id }
      let!(:members) { create_list :anime, 5 }

      before do
        create :contest_match, round: round1, left: members[0], right: members[1], winner_id: members[1].id, state: 'finished'
        create :contest_match, round: round1, left: members[0], right: members[2], winner_id: members[0].id, state: 'finished'
        create :contest_match, round: round1, left: members[0], right: members[3], winner_id: members[3].id, state: 'finished'
        create :contest_match, round: round1, left: members[0], right: members[4], winner_id: members[0].id, state: 'finished'
        create :contest_match, round: round2, left: members[0], right: members[3], winner_id: members[0].id, state: 'finished'
      end

      it 'returns defeated entries' do
        expect(contest.defeated_by(members[0], round1).map(&:id)).to eq [members[2].id, members[4].id]
        expect(contest.defeated_by(members[0], round2).map(&:id)).to eq [members[2].id, members[4].id, members[3].id]
      end
    end

    describe '#user_vote_key' do
      subject { contest.user_vote_key }
      let(:contest) { create :contest, user_vote_key: vote_key }

      describe 'can_vote_1' do
        let(:vote_key) { 'can_vote_1' }
        it { is_expected.to eq 'can_vote_1' }
      end

      describe 'can_vote_2' do
        let(:vote_key) { 'can_vote_2' }
        it { is_expected.to eq 'can_vote_2' }
      end

      describe 'can_vote_3' do
        let(:vote_key) { 'can_vote_3' }
        it { is_expected.to eq 'can_vote_3' }
      end

      describe 'wrong key' do
        let(:vote_key) { 'can_vote_2' }
        before { contest.user_vote_key = 'login' }
        it { is_expected.to be_nil }
      end
    end

    describe '#strategy' do
      subject { create :contest, strategy_type: strategy_type }

      context 'double_elimination' do
        let(:strategy_type) { :double_elimination }
        its(:strategy) { is_expected.to be_kind_of Contest::DoubleEliminationStrategy }
      end

      context 'play_off' do
        let(:strategy_type) { :play_off }
        its(:strategy) { is_expected.to be_kind_of Contest::PlayOffStrategy }
      end
    end

    describe '#member_klass' do
      let(:contest) { create :contest, member_type: member_type }
      subject { contest.member_klass }

      context Anime do
        let(:member_type) { :anime }
        it { is_expected.to eq Anime }
      end

      context Character do
        let(:member_type) { :character }
        it { is_expected.to eq Character }
      end
    end

    describe '#generate_missing_topics' do
      before do
        allow(subject.topics).to receive(:none?).and_return is_none
        allow(subject).to receive :generate_topics
        subject.send :generate_missing_topics
      end

      context 'no topics' do
        let(:is_none) { true }
        it do
          expect(subject)
            .to have_received(:generate_topics)
            .with Shikimori::DOMAIN_LOCALES
        end
      end

      context 'has topics' do
        let(:is_none) { false }
        it { expect(subject).to_not have_received :generate_topics }
      end
    end
  end

  describe 'permissions' do
    let(:contest) { build_stubbed :contest }

    context 'contest_moderator' do
      subject { Ability.new build_stubbed(:user, :contest_moderator) }
      it { is_expected.to be_able_to :manage, contest }
    end

    context 'guest' do
      subject { Ability.new nil }
      it { is_expected.to be_able_to :see_contest, contest }
      it { is_expected.to_not be_able_to :manage, contest }
    end

    context 'user' do
      subject { Ability.new build_stubbed(:user, :user) }
      it { is_expected.to be_able_to :see_contest, contest }
      it { is_expected.to_not be_able_to :manage, contest }
    end
  end

  it_behaves_like :topics_concern, :collection
end
