describe MalParsers::ScheduleExpired do
  let(:worker) { MalParsers::ScheduleExpired.new }

  let!(:anime_1) { create :anime, imported_at: nil }
  let!(:anime_2) { create :anime, imported_at: 2.days.ago }
  let!(:anime_3) { create :anime, imported_at: nil }

  before { allow(MalParsers::FetchEntry).to receive :perform_async }
  subject! { worker.perform 'anime' }


  it do
    is_expected.to eq [anime_1, anime_3]
    expect(MalParsers::FetchEntry)
      .to have_received(:perform_async)
      .with(anime_1.id, 'anime')
      .ordered
    expect(MalParsers::FetchEntry)
      .to have_received(:perform_async)
      .with(anime_3.id, 'anime')
      .ordered
  end
end
