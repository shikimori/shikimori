require 'cancan/matchers'

describe Contest do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :links }
    it { is_expected.to have_many :rounds }
    it { is_expected.to have_many :suggestions }
    it { is_expected.to have_one :topic }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :strategy_type }
    it { is_expected.to validate_presence_of :member_type }
    it { is_expected.to validate_presence_of :started_on }
    it { is_expected.to validate_presence_of :user_vote_key }
  end

  describe 'state machine' do
    let(:contest) { create :contest, :with_5_members }

    it 'full cycle' do
      expect(contest.created?).to be_truthy
      contest.propose!
      contest.start!
      contest.finish!
    end

    describe 'can_propose?' do
      subject { contest.can_propose? }
      it { is_expected.to be_truthy }
    end

    describe '#can_start?' do
      subject { contest.can_start? }

      context 'normal count' do
        before { allow(contest.links).to receive(:count).and_return Contest::MINIMUM_MEMBERS + 1 }
        it { is_expected.to be_truthy }
      end

      context 'Contest::MINIMUM_MEMBERS' do
        before { allow(contest.links).to receive(:count).and_return Contest::MINIMUM_MEMBERS - 1 }
        it { is_expected.to be_falsy }
      end

      context 'Contest::MAXIMUM_MEMBERS' do
        before { allow(contest.links).to receive(:count).and_return Contest::MAXIMUM_MEMBERS + 1 }
        it { is_expected.to be_falsy }
      end
    end

    context 'before started' do
      it 'builds rounds' do
        contest.start!
        expect(contest.rounds).not_to be_empty
      end

      it 'fills first contest matches' do
        contest.start!
        expect(contest.rounds.first.matches).not_to be_empty
      end

      context 'when started_on expired' do
        before { contest.update_attribute :started_on, Time.zone.yesterday }

        it 'updates started_on' do
          contest.start!
          expect(contest.started_on).to eq Time.zone.today
        end

        it 'rebuilds matches' do
          contest.prepare
          expect(contest).to receive :prepare
          contest.start!
        end
      end
    end

    context 'after propose' do
      let(:contest) { create :contest, :with_5_members, :with_topic }

      it 'creates topic' do
        contest.propose!
        expect(contest.topic).to be_present
      end
    end

    context 'after start' do
      it 'starts first round' do
        contest.start!
        expect(contest.rounds.first.started?).to be_truthy
      end

      let(:contest) { create :contest, :with_5_members, :with_topic }
      it 'creates topic' do
        contest.start!
        expect(contest.topic).to be_present
      end
    end

    context 'after finished' do
      let(:contest) { create :contest, :started }
      before { allow(FinalizeContest).to receive :perform_async }
      before { contest.finish }

      it { expect(FinalizeContest).to have_received(:perform_async).with contest.id }
    end
  end

  describe 'instance methods' do
    describe '#prepare' do
      let(:contest) { create :contest, :with_5_members }

      it 'deletes existing rounds' do
        round = create :contest_round, contest_id: contest.id
        contest.rounds << round
        contest.prepare

        expect {
          round.reload
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'create_rounds' do
        expect(contest.strategy).to receive :create_rounds
        contest.prepare
      end
    end

    describe '#cleanup_suggestions' do
      let(:contest) { create :contest, :proposing }
      let!(:contest_suggestion_1) { create :contest_suggestion, contest: contest, user: contest.user }
      let!(:contest_suggestion_2) { create :contest_suggestion, contest: contest, user: create(:user, sign_in_count: 999) }

      before { contest.cleanup_suggestions! }
      it { expect(contest.suggestions).to eq [contest_suggestion_2] }
    end

    describe '#progress!' do
      let(:contest) { create :contest, :with_5_members }
      let(:round) { contest.current_round }
      before { contest.start! }

      it 'starts matches' do
        round.matches.last.state = 'created'
        contest.progress!
        expect(round.matches.last.started?).to be_truthy
      end

      it 'finishes matches' do
        round.matches.last.finished_on = Time.zone.yesterday
        contest.progress!
        expect(round.matches.last.finished?).to be_truthy
      end

      it 'finishes round' do
        round.matches.each {|v| v.finished_on = Time.zone.yesterday }
        contest.progress!
        expect(round.finished?).to be_truthy
      end

      context 'something was changed' do
        before do
          @updated_at = contest.updated_at = Time.zone.now - 1.day
          round.matches.each { |v| v.finished_on = Time.zone.yesterday }
          contest.progress!
        end

        it { expect(contest.updated_at).not_to eq @updated_at }
      end

      context 'nothing was changed' do
        before do
          @updated_at = contest.updated_at = Time.zone.now - 1.day
          contest.progress!
        end

        it { expect(contest.updated_at).to eq @updated_at }
      end
    end

    describe '#current_round' do
      let(:contest) { create :contest, :with_5_members }
      before { contest.prepare }

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

  context '#class_methods' do
    describe 'current' do
      subject { Contest.current.map(&:id) }

      context 'nothing' do
        let!(:contest) { create :contest }
        it { is_expected.to eq [] }
      end

      context 'finished not so long ago' do
        let!(:contest) { create :contest, state: 'finished', finished_on: Time.zone.today - 6.days }
        it { is_expected.to eq [contest.id] }

        context 'new one started' do
          let!(:contest2) { create :contest, state: 'started' }
          it { is_expected.to eq [contest.id, contest2.id] }

          context 'and one more started' do
            let!(:contest3) { create :contest, state: 'started' }
            it { is_expected.to eq [contest.id, contest2.id, contest3.id] }
          end
        end
      end

      context 'finished long ago' do
        let!(:contest) { create :contest, state: 'finished', finished_on: Time.zone.today - 9.days }
        it { is_expected.to be_empty }

        context 'new one started' do
          let!(:contest) { create :contest, state: 'started' }
          it { is_expected.to eq [contest.id] }
        end
      end
    end
  end

  describe 'permissions' do
    let(:contest) { build_stubbed :contest }

    context 'contests_moderator' do
      subject { Ability.new build_stubbed(:user, :contests_moderator) }
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
end
