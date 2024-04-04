describe Contests::Query do
  let(:query) { described_class.fetch }

  let!(:contest_1) { create :contest, :started, started_on: 1.day.from_now }
  let!(:contest_2) { create :contest, :started, started_on: 1.day.ago }
  let!(:contest_3) { create :contest, :proposing }
  let!(:contest_4) { create :contest, :created }
  let!(:contest_5) { create :contest, :finished, started_on: 9.days.ago }
  let!(:contest_6) { create :contest, :finished, started_on: 8.days.ago }

  describe '.fetch' do
    subject { query }

    it do
      is_expected.to eq [
        contest_2,
        contest_1,
        contest_3,
        contest_4,
        contest_6,
        contest_5
      ]
    end
  end

  context '#by_id' do
    subject { query.by_id [contest_1.id, contest_3.id] }
    it { is_expected.to eq [contest_1, contest_3] }
  end
end
