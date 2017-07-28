describe Contests::CurrentQuery do
  let(:query) { Contests::CurrentQuery.new }

  let!(:contest_1) { create :contest, :finished }
  let!(:contest_2) { create :contest, :proposing }
  let!(:contest_3) do
    create :contest, :started, started_on: Time.zone.tomorrow
  end
  let!(:contest_4) do
    create :contest, :started, started_on: Time.zone.today
  end

  subject! { query.call }

  it { is_expected.to eq [contest_4, contest_2] }
end
