
describe AnimeCalendar do
  it { should belong_to :anime }
  it { should validate_presence_of :anime }
  it { should validate_presence_of :episode }
  it { should validate_presence_of :start_at }

  it 'loads calendar' do
    expect(AnimeCalendar.load_calendar.first.events).not_to be_empty
  end

  it 'imports calendar' do
    create :anime, name: 'Naruto Shippuuden', status: AniMangaStatus::Ongoing, aired_on: 1.year.ago
    expect {
      AnimeCalendar.parse
    }.to change(AnimeCalendar, :count)
  end

  it 'imports calendar only once' do
    create :anime, name: 'Naruto Shippuuden', status: AniMangaStatus::Ongoing, aired_on: 1.year.ago
    AnimeCalendar.parse
    expect {
      AnimeCalendar.parse
    }.to_not change(AnimeCalendar, :count)
  end

  it 'deletes old entries' do
    AnimeCalendar.create!(anime: (FactoryGirl.create :anime), start_at: 1.month.ago, episode: 1)
    expect {
      AnimeCalendar.parse
    }.to change(AnimeCalendar, :count).by(-1)
  end
end
