describe MalParsers::ScheduleExpired do
  let(:worker) { MalParsers::ScheduleExpired.new }

  let!(:anime_1) { create :anime, imported_at: nil, mal_id: 1 }
  let!(:anime_2) { create :anime, imported_at: 2.days.ago, mal_id: 2 }
  let!(:anime_3) { create :anime, imported_at: nil, mal_id: 3 }
  let!(:anime_4) { create :anime, imported_at: nil, mal_id: nil }

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
