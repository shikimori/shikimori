require 'spec_helper'

describe ContestMatch do
  context '#relations' do
    it { should belong_to :round }
    it { should belong_to :left }
    it { should belong_to :right }
    it { should have_many :votes }
  end

  let(:user) { create :user }

  describe 'states' do
    let(:match) { create :contest_match, started_on: Date.yesterday, finished_on: Date.yesterday }

    it 'full cycle' do
      match.created?.should be_true
      match.start!
      match.started?.should be_true
      match.finish!
      match.finished?.should be_true
    end

    describe :can_vote? do
      subject { match.can_vote? }

      context 'created' do
        it { should be_false }
      end

      context 'started' do
        before { match.start! }
        it { should be_true }
      end
    end

    describe :can_finish? do
      subject { match.can_finish? }
      before { match.start! }

      context 'true' do
        before { match.finished_on = Date.yesterday }
        it { should be_true }
      end

      context 'false' do
        before { match.finished_on = Date.today }
        it { should be_false }
      end
    end

    context :can_start? do
      subject { match.can_start? }

      context 'true' do
        before { match.started_on = Date.today }
        it { should be_true }
      end

      context 'false' do
        before { match.started_on = Date.tomorrow }
        it { should be_false }
      end
    end

    context 'after started' do
      [:can_vote_1, :can_vote_2, :can_vote_3].each do |user_vote_key|
        describe user_vote_key do
          before do
            match.round.contest.update_attribute :user_vote_key, user_vote_key
            match.reload

            create_list :user, 2

            match.round.contest.stub(:started?).and_return true
            match.start!
          end

          it { User.all.all? {|v| v.can_vote?(match.round.contest) }.should be true }
        end
      end

      describe 'right_id = nil, right_type = Anime' do
        let(:match) { create :contest_match, started_on: Date.yesterday, finished_on: Date.yesterday, right_id: nil, right_type: Anime.name }
        before { match.start! }
        it { match.right_type.should be_nil }
      end

      describe 'left_id = nil, right_id != nil' do
        let(:match) { create :contest_match, started_on: Date.yesterday, finished_on: Date.yesterday, left_id: nil, left_type: Anime.name }
        before { match.start! }
        it { match.left_type.should_not be_nil }
        it { match.left_id.should_not be_nil }
        it { match.right_type.should be_nil }
        it { match.right_id.should be_nil }
      end
    end

    context 'after finished' do
      before { match.start! }

      it 'should be false' do
        match.finish!
        match.can_vote?.should be_false
      end

      context 'no right variant' do
        before do
          match.right = nil
          match.finish!
        end

        it { match.winner_id.should eq match.left_id }
      end

      context 'left_votes > right_votes' do
        before do
          match.votes.create user_id: user.id, ip: '1', item_id: match.left_id
          match.finish!
        end

        it { match.winner_id.should eq match.left_id }
      end

      context 'right_votes > left_votes' do
        before do
          match.votes.create user_id: user.id, ip: '1', item_id: match.right_id
          match.finish!
        end

        it { match.winner_id.should eq match.right_id }
      end

      context 'left_votes == right_votes' do
        context 'left.score > right.score' do
          before do
            match.left.update_attribute :score, 2
            match.right.update_attribute :score, 1
            match.finish!
          end

          it { match.winner_id.should eq match.left_id }
        end

        context 'right.score > left.score' do
          before do
            match.left.update_attribute :score, 1
            match.right.update_attribute :score, 2
            match.finish!
          end

          it { match.winner_id.should eq match.right_id }
        end

        context 'left.score == right.score' do
          before do
            match.left.update_attribute :score, 2
            match.right.update_attribute :score, 2
            match.finish!
          end

          it { match.winner_id.should eq match.left_id }
        end
      end
    end
  end

  describe :vote_for do
    let(:match) { create :contest_match, state: 'started' }

    it 'creates ContestUserVote' do
      expect {
        match.vote_for 'left', user, "123"
      }.to change(ContestUserVote, :count).by 1
    end

    context 'no match' do
      context 'left' do
        before { match.vote_for 'left', user, "123" }
        it { match.votes.first.item_id.should eq match.left_id }
      end

      context 'right' do
        before { match.vote_for 'right', user, "123" }
        it { match.votes.first.item_id.should eq match.right_id }
      end

      context 'none' do
        before { match.vote_for 'none', user, "123" }
        it { match.votes.first.item_id.should eq 0 }
      end

      context 'user' do
        before { match.vote_for 'right', user, "123" }
        it { match.votes.first.user_id.should eq user.id }
      end

      context 'ip' do
        before { match.vote_for 'right', user, "123" }
        it { match.votes.first.ip.should eq '123' }
      end
    end

    context 'has match' do
      before do
        match.vote_for 'left', user, "123"
        match.vote_for 'right', user, "123"
      end

      it { match.votes.first.item_id.should eq match.right_id }
      it { match.votes.count.should eq 1 }
    end
  end

  describe :voted_id do
    let!(:match) { create :contest_match, state: 'started', round: build_stubbed(:contest_round) }
    let(:vote_with_user_vote) { ContestMatch.with_user_vote(user, '').first }
    subject { vote_with_user_vote.voted_id }

    context :not_voted do
      it { should be_nil }
    end

    context :voted do
      context :really_voted do
        context :left do
          before { match.vote_for(:left, user, '') }
          it { should eq match.left_id }
        end

        context :right do
          before { match.vote_for(:right, user, '') }
          it { should eq match.right_id }
        end
      end

      context :right_type_is_nil do
        before { vote_with_user_vote.right_type = nil }
        it { should be_nil }
      end
    end
  end

  describe :voted? do
    let!(:match) { create :contest_match, state: 'started', round: build_stubbed(:contest_round) }
    let(:vote_with_user_vote) { ContestMatch.with_user_vote(user, '').first }
    subject { vote_with_user_vote.voted? }

    context :not_voted do
      it { should be_false }
    end

    context :voted do
      context :really_voted do
        context :left do
          before { match.vote_for(:left, user, '') }
          it { should be_true }
        end

        context :right do
          before { match.vote_for(:right, user, '') }
          it { should be_true }
        end
      end

      context :right_type_is_nil do
        before { vote_with_user_vote.right_type = nil }
        it { should be_false }
      end
    end
  end

  describe :update_user do
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

      it { should be_true }
    end

    describe 'updated' do
      let(:user) { create :user, can_vote_1: true }
      before do
        round.matches.first.vote_for 'left', user, 'z'
        round.matches.last.vote_for 'left', user, 'z'
        round.matches.first.update_user user, 'z'
      end

      it { should be_false }
    end
  end

  describe :winner do
    let(:match) { build_stubbed :contest_match, state: 'finished' }
    subject { match.winner }

    describe 'left' do
      before { match.winner_id = match.left_id }
      its(:id) { should eq match.left.id }
    end

    describe 'right' do
      before { match.winner_id = match.right_id }
      its(:id) { should eq match.right.id }
    end
  end

  describe :loser do
    let(:match) { build_stubbed :contest_match, state: 'finished' }
    subject { match.loser }

    describe 'left' do
      before { match.winner_id = match.left_id }
      its(:id) { should eq match.right.id }
    end

    describe 'right' do
      before { match.winner_id = match.right_id }
      its(:id) { should eq match.left.id }
    end

    describe 'no loser' do
      before do
        match.winner_id = match.left_id
        match.right = nil
      end
      it { match.loser.should be_nil }
    end
  end

  describe :contest do
    subject(:match) { create :contest_match }
    its(:contest) { should eq match.round.contest }
  end
end
