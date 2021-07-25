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
    it { is_expected.to validate_presence_of :title_en }
    it { is_expected.to validate_length_of(:description_ru).is_at_most(32768) }
    it { is_expected.to validate_length_of(:description_en).is_at_most(32768) }
    it { is_expected.to validate_presence_of :user }
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

  describe 'state machine' do
    let(:contest) { create :contest, :with_5_members, :created }

    describe 'can_propose?' do
      subject { contest.can_propose? }
      it { is_expected.to eq true }
    end

    describe '#can_start?' do
      subject { contest.can_start? }

      context 'normal count' do
        before { allow(contest.links).to receive(:count).and_return Contest::MINIMUM_MEMBERS + 1 }
        it { is_expected.to eq true }
      end

      context 'Contest::MINIMUM_MEMBERS' do
        before { allow(contest.links).to receive(:count).and_return Contest::MINIMUM_MEMBERS - 1 }
        it { is_expected.to eq false }
      end

      context 'Contest::MAXIMUM_MEMBERS' do
        before { allow(contest.links).to receive(:count).and_return Contest::MAXIMUM_MEMBERS + 1 }
        it { is_expected.to eq false }
      end
    end

    context 'after propose' do
      subject! { contest.propose! }

      it 'creates 2 topics' do
        expect(contest.topics).to have(2).items
      end
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
