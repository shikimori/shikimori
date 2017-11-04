describe AnimeOnline::RecentVideos do
  let(:query) { AnimeOnline::RecentVideos.new is_adult }

  EXCLUDED_ANIMES = [
    [:released, released_on: 6.weeks.ago],
    [:ongoing, :with_video, rating: :g],
    [:ongoing, :with_video, id: Anime::EXCLUDED_ONGOINGS.max]
  ]
  let(:anime_ongoing) { create :anime, :ongoing }
  let(:anime_recent) { create :anime, :released, released_on: 2.weeks.ago }
  let(:anime_adult) { create :anime, :ongoing, :with_video, rating: Anime::ADULT_RATING }
  let(:anime_excluded) { create :anime, *EXCLUDED_ANIMES.sample }

  let!(:ongoing_notification_1) do
    create :episode_notification,
      id: 1,
      episode: 1,
      anime: anime_ongoing,
      updated_at: 10.minutes.ago,
      is_fandub: true
  end
  let!(:ongoing_notification_2) do
    create :episode_notification,
      id: 2,
      episode: 2,
      anime: anime_ongoing,
      updated_at: 9.minutes.ago,
      is_fandub: true
  end
  let!(:adult_notification) do
    create :episode_notification,
      id: 3,
      episode: 1,
      anime: anime_adult,
      updated_at: 8.minutes.ago,
      is_fandub: true
  end
  let!(:recent_notification) do
    create :episode_notification,
      id: 4,
      episode: 1,
      anime: anime_recent,
      updated_at: 7.minutes.ago,
      is_fandub: true
  end
  let!(:excluded_notification) do
    create :episode_notification,
      id: 5,
      episode: 1,
      anime: anime_excluded,
      updated_at: 6.minutes.ago,
      is_fandub: true
  end

  describe '#fetch' do
    subject { query.fetch 1, 10 }

    context 'not adult' do
      let(:is_adult) { false }
      it { is_expected.to eq [recent_notification, ongoing_notification_2] }
    end

    context 'adult' do
      let(:is_adult) { true }
      it { is_expected.to eq [adult_notification] }
    end
  end

  describe '#postload' do
    let(:is_adult) { false }
    subject { query.postload 1, 1 }

    it { is_expected.to eq [[recent_notification], true] }
  end
end
