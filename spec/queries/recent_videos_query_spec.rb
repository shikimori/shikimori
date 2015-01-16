describe RecentVideosQuery do
  let(:query) { RecentVideosQuery.new is_adult }

  let(:anime_ongoing) { create :anime, :ongoing }
  let(:anime_recent) { create :anime, :released, released_on: 2.weeks.ago }
  let(:anime_old) { create :anime, :released, released_on: 6.weeks.ago }
  let(:anime_adult) { create :anime, :ongoing, :with_video, rating: Anime::ADULT_RATINGS.first }
  let(:anime_g) { create :anime, :ongoing, :with_video, rating: 'G - All Ages' }

  let!(:episode_notification_1) { create :episode_notification, id: 1, episode: 1, anime: anime_ongoing }
  let!(:episode_notification_2) { create :episode_notification, id: 2, episode: 2, anime: anime_ongoing }
  let!(:episode_notification_3) { create :episode_notification, id: 3, episode: 1, anime: anime_adult }
  let!(:episode_notification_4) { create :episode_notification, id: 4, episode: 1, anime: anime_recent }
  let!(:episode_notification_5) { create :episode_notification, id: 5, episode: 1, anime: anime_old }
  let!(:episode_notification_6) { create :episode_notification, id: 6, episode: 1, anime: anime_g }

  describe '#fetch' do
    #subject { query.fetch.map(&:episode) }
    subject { query.fetch }

    context 'not adult' do
      let(:is_adult) { false }
      it { should eq [episode_notification_2, episode_notification_4] }
    end

    context 'adult' do
      let(:is_adult) { true }
      it { should eq [episode_notification_3] }
    end
  end
end
