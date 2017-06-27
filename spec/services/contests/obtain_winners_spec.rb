describe Contests::ObtainWinners do
  let(:service) { Contests::ObtainWinners.new contest }
  let(:contest) do
    create :contest, :with_5_members,
      started_on: 1.day.ago,
      updated_at: 1.day.ago
  end

  let(:anime_1) { create :anime }
  let(:anime_2) { create :anime }

  before do
    allow(contest.strategy)
      .to receive(:results)
      .with(nil)
      .and_return [anime_1, anime_2]
  end

  subject! { service.call }

  it do
    expect(contest.winners).to have(2).items
    expect(contest.winners.first).to have_attributes(
      item: anime_1,
      position: 1
    )
    expect(contest.winners.second).to have_attributes(
      item: anime_2,
      position: 2
    )
  end
end
