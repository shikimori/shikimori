require 'spec_helper'

describe ContestRound do
  context :relations do
    it { should belong_to :contest }
    it { should have_many :matches }
  end

  describe :state_machine do
    let(:contest) { create :contest_with_5_members, state: 'started' }
    let(:round) { create :contest_round, contest: contest }

    it 'full cycle' do
      round.created?.should be_true

      contest.strategy.fill_round_with_matches round
      round.start!
      round.started?.should be_true

      round.matches.each {|v| v.state = 'finished' }
      round.finish!
      round.finished?.should be_true
    end

    describe :can_start? do
      subject { round.can_start? }

      context 'no matches' do
        it { should be_false }
      end

      context 'has matches' do
        before { round.matches.stub(:any?).and_return true }
        it { should be_true }
      end
    end

    describe :can_finish? do
      subject { round.can_finish? }

      context 'not finished matches' do
        before { contest.strategy.fill_round_with_matches round }
        before { round.start! }

        it { should be_false }

        context 'finished matches' do
          context 'all finished' do
            before { round.matches.each {|v| v.state = 'finished' } }
            it { should be_true }
          end

          context 'all can_finish' do
            before { round.matches.each {|v| v.stub(:can_finish?).and_return true } }
            it { should be_true }
          end
        end
      end
    end

    context 'after started' do
      before { contest.strategy.fill_round_with_matches round }

      it 'starts today matches' do
        round.start!
        round.matches.each do |vote|
          vote.started?.should be_true
        end
      end

      it 'does not start matches in future' do
        round.matches.each {|v| v.started_on = Date.tomorrow }
        round.start!

        round.matches.each do |vote|
          vote.started?.should be_false
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
        it { round.matches.each {|v| v.finished?.should be_true } }
      end
    end

    context 'after finished' do
      before do
        contest.strategy.fill_round_with_matches round
        round.start!
        round.matches.each {|v| v.finished_on = Date.yesterday }
      end
      let(:next_round) { create :contest_round }

      it 'starts&fills next round' do
        round.stub(:next_round).and_return next_round

        next_round.should_receive :start!
        round.strategy.should_receive(:advance_members).with next_round, round

        round.finish!
      end

      it 'finishes contest' do
        round.finish!
        round.contest.finished?.should be_true
      end
    end
  end

  context :navigation do
    let!(:contest) { create :contest }
    let!(:round1) { create :contest_round, contest: contest }
    let!(:round2) { create :contest_round, contest: contest }
    let!(:round3) { create :contest_round, contest: contest }

    describe :next_round do
      it 'should be valid' do
        round1.next_round.should eq round2
        round2.next_round.should eq round3
        round3.next_round.should be_nil
      end
    end

    describe :prior_round do
      it 'should be valid' do
        round1.prior_round.should be_nil
        round2.prior_round.should eq round1
        round3.prior_round.should eq round2
      end
    end

    describe :first? do
      it 'should be valid' do
        round1.first?.should be_true
        round2.first?.should be_false
        round3.first?.should be_false
      end
    end

    describe :last? do
      it 'should be valid' do
        round1.last?.should be_false
        round2.last?.should be_false
        round3.last?.should be_true
      end
    end
  end

  #describe :fill_matches do
    #context '19 members' do
      #let(:contest) { create :contest_with_19_members, matches_per_round: 3 }
      #before { contest.create_rounds }

      #context 'I' do
        #let(:round) { contest.rounds.first }
        #before { contest.rounds[0..0].each(&:fill_matches) }

        #it 'should not left last vote for next day' do
          #round.matches.map(&:started_on).map(&:to_s).uniq.should have(3).items
        #end
      #end

      #context 'II' do
        #let(:round) { contest.rounds[1] }
        #before { contest.rounds[0..1].each(&:fill_matches) }

        #it 'should make the same date grouping as in the first round' do
          #round.matches.map(&:started_on).map(&:to_s).uniq.should have(3).items
        #end
      #end
    #end

    #context '5 members' do
      #let(:contest) { create :contest_with_5_members }
      #before { contest.create_rounds }

      #context 'I' do
        #let(:round) { contest.rounds.first }
        #before { contest.rounds[0..0].each(&:fill_matches) }

        #it 'valid' do
          #round.matches.should have(3).items
          #round.matches.each {|vote| vote.group.should eq ContestRound::S }
          #round.matches.first.started_on.should eq contest.started_on
          #round.matches.first.right_type.should_not be_nil
          #round.matches.last.right_type.should be_nil
        #end
      #end

      #context 'II' do
        #let(:round) { contest.rounds[1] }
        #before { contest.rounds[0..1].each(&:fill_matches) }

        #it 'valid' do
          #round.matches.should have(3).items
          #round.matches[0..1].each {|vote| vote.group.should eq ContestRound::W }
          #round.matches[2..2].each {|vote| vote.group.should eq ContestRound::L }
          #round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          #round.matches.first.right_type.should_not be_nil
        #end
      #end

      #context 'IIa' do
        #let(:round) { contest.rounds[2] }
        #before { contest.rounds[0..2].each(&:fill_matches) }

        #it 'valid' do
          #round.matches.should have(1).item
          #round.matches.each {|vote| vote.group.should eq ContestRound::L }
          #round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          #round.matches.first.right_type.should_not be_nil
        #end
      #end

      #context 'III' do
        #let(:round) { contest.rounds[3] }
        #before { contest.rounds[0..3].each(&:fill_matches) }

        #it 'valid' do
          #round.matches.should have(2).items
          #round.matches.first.group.should eq ContestRound::W
          #round.matches.last.group.should eq ContestRound::L
          #round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          #round.matches.first.right_type.should_not be_nil
        #end
      #end

      #context 'IIIa' do
        #let(:round) { contest.rounds[4] }
        #before { contest.rounds[0..4].each(&:fill_matches) }

        #it 'valid' do
          #round.matches.should have(1).item
          #round.matches.first.group.should eq ContestRound::L
          #round.matches.first.right_type.should_not be_nil
        #end
      #end

      #context 'IV' do
        #let(:round) { contest.rounds.last }
        #before { contest.rounds.each(&:fill_matches) }

        #it 'valid' do
          #round.matches.should have(1).item
          #round.matches.first.group.should eq ContestRound::F
          #round.matches.first.started_on.should eq (round.prior_round.matches.last.finished_on+contest.matches_interval.days)
          #round.matches.first.right_type.should_not be_nil
        #end
      #end
    #end
  #end
end
