describe RecentVideosQuery do
  let(:query) { RecentVideosQuery.new is_adult }

  let(:anime_ongoing) { create :anime, :ongoing }
  let(:anime_recent) { create :anime, :released, released_on: 2.weeks.ago }
  let(:anime_old) { create :anime, :released, released_on: 6.weeks.ago }
  let(:anime_adult) { create :anime, :ongoing, :with_video, rating: Anime::ADULT_RATING }
  let(:anime_g) { create :anime, :ongoing, :with_video, rating: 'G - All Ages' }

  let!(:episode_notification_1) { create :episode_notification, id: 1, episode: 1, anime: anime_ongoing, updated_at: 10.minutes.ago, is_fandub: true }
  let!(:episode_notification_2) { create :episode_notification, id: 2, episode: 2, anime: anime_ongoing, updated_at: 9.minutes.ago, is_fandub: true }
  let!(:episode_notification_3) { create :episode_notification, id: 3, episode: 1, anime: anime_adult, updated_at: 8.minutes.ago, is_fandub: true }
  let!(:episode_notification_4) { create :episode_notification, id: 4, episode: 1, anime: anime_recent, updated_at: 7.minutes.ago, is_fandub: true }
  let!(:episode_notification_5) { create :episode_notification, id: 5, episode: 1, anime: anime_old, updated_at: 6.minutes.ago, is_fandub: true }
  let!(:episode_notification_6) { create :episode_notification, id: 6, episode: 1, anime: anime_g, updated_at: 5.minutes.ago, is_fandub: true }

  describe '#fetch' do
    subject { query.fetch 1, 10 }

    context 'not adult' do
      let(:is_adult) { false }
      it { should eq [episode_notification_4, episode_notification_2] }
    end

    context 'adult' do
      let(:is_adult) { true }
      it { should eq [episode_notification_3] }
    end
  end

  describe '#postload' do
    let(:is_adult) { false }
    subject { query.postload 1, 1 }

    it { should eq [[episode_notification_4], true] }
  end
end
