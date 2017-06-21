describe Contests::Query do
  let(:query) { Contests::Query.fetch }

  include_context :timecop

  let!(:contest_1) { create :contest, :started }
  let!(:contest_2) { create :contest, :proposing }
  let!(:contest_3) { create :contest, :created }
  let!(:contest_4) { create :contest, :finished, started_on: 9.days.ago }
  let!(:contest_5) { create :contest, :finished, started_on: 8.days.ago }

  describe '.fetch' do
    subject { query }

    it do
      is_expected.to eq [
        contest_1,
        contest_2,
        contest_3,
        contest_5,
        contest_4
      ]
    end
  end
end
