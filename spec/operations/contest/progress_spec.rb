describe Contest::Progress do
  let(:operation) { Contest::Progress.new contest }

  include_context :timecop

  let(:contest) { create :contest, :with_5_members }
  let(:round) { contest.current_round }

  before do
    Contest::Start.call contest
    contest.update_column :updated_at, 1.hour.ago
  end

  context 'matches to start' do
    before { round.matches.last.state = 'created' }
    subject! { operation.call }

    it do
      expect(contest.updated_at).to be_within(0.1).of(Time.zone.now)
      expect(round.matches.last.started?).to eq true
    end
  end

  describe 'matches to finish' do
    before { round.matches.last.finished_on = Time.zone.yesterday }
    subject! { operation.call }

    it do
      expect(contest.updated_at).to be_within(0.1).of(Time.zone.now)
      expect(round.matches.last.finished?).to eq true
    end
  end

  describe 'round to finish' do
    before { round.matches.each { |v| v.finished_on = Time.zone.yesterday } }
    subject! { operation.call }

    it do
      expect(contest.updated_at).to be_within(0.1).of(Time.zone.now)
      expect(round.finished?).to eq true
    end
  end
end
