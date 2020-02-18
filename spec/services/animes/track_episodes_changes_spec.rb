# frozen_string_literal: true

describe Animes::TrackEpisodesChanges do
  let!(:news_topics) {}
  let!(:episode_notifications) {}

  before { anime.assign_attributes episodes_aired: new_episodes_aired }

  subject! { described_class.call anime }

  context 'episodes aired not changed' do
    let(:anime) { create :anime, episodes_aired: old_episodes_aired }

    let(:old_episodes_aired) { 1 }
    let(:new_episodes_aired) { 1 }

    it 'does not change anime status' do
      expect(anime.status_change).to eq nil
    end
  end

  describe 'anons aired_episodes changed' do
    let(:anime) { create :anime, :anons, episodes_aired: old_episodes_aired }

    let(:old_episodes_aired) { 0 }
    let(:new_episodes_aired) { 1 }

    it 'changes anime status to ongoing' do
      expect(anime).to be_ongoing
    end
  end

  describe 'ongoing aired_episodes changed' do
    let(:anime) do
      create :anime,
        status: :ongoing,
        episodes: episodes,
        episodes_aired: old_episodes_aired
    end

    context 'last episode aired' do
      let(:episodes) { 8 }

      let(:old_episodes_aired) { 7 }
      let(:new_episodes_aired) { 8 }

      describe 'change anime status to released' do
        let(:news_topics) { topic }
        let(:topic) do
          create :news_topic,
            linked: anime,
            action: AnimeHistoryAction::Episode,
            value: topic_episode,
            created_at: 1.day.ago
        end

        context 'has last episode topic' do
          let(:topic_episode) { episodes }

          it do
            expect(anime).to be_released
            expect(anime.released_on).to eq Time.zone.yesterday
          end
        end

        context 'no last episode topic' do
          let(:topic_episode) { episodes - 1 }

          it do
            expect(anime).to be_released
            expect(anime.released_on).to eq Time.zone.today
          end
        end
      end
    end

    context 'not last episode aired' do
      let(:episodes) { 8 }

      let(:old_episodes_aired) { 6 }
      let(:new_episodes_aired) { 7 }

      it 'does not change anime status' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to eq nil
      end
    end

    context 'total episodes is 0' do
      let(:episodes) { 0 }

      let(:old_episodes_aired) { 7 }
      let(:new_episodes_aired) { 8 }

      it 'does not change anime status' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to eq nil
      end
    end
  end

  describe 'aired_episodes are decreased' do
    let(:anime) { create :anime, :ongoing, episodes_aired: old_episodes_aired }
    let(:old_episodes_aired) { 7 }
    let(:new_episodes_aired) { 5 }

    context 'ongoing' do
      let(:news_topic_5) do
        create :news_topic,
          linked: anime,
          action: AnimeHistoryAction::Episode,
          value: 5
      end
      let(:news_topic_6) do
        create :news_topic,
          linked: anime,
          action: AnimeHistoryAction::Episode,
          value: 6
      end
      let(:news_topic_7) do
        create :news_topic,
          linked: anime,
          action: AnimeHistoryAction::Episode,
          value: 7
      end

      let(:episode_notification_5) { create :episode_notification, anime: anime, episode: 5 }
      let(:episode_notification_6) { create :episode_notification, anime: anime, episode: 6 }
      let(:episode_notification_7) { create :episode_notification, anime: anime, episode: 7 }

      let!(:news_topics) { [news_topic_5, news_topic_6, news_topic_7] }
      let!(:episode_notifications) do
        [episode_notification_5, episode_notification_6, episode_notification_7]
      end

      it do
        expect(news_topic_5.reload).to be_persisted
        expect { news_topic_6.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { news_topic_7.reload }.to raise_error ActiveRecord::RecordNotFound

        expect(episode_notification_5.reload).to be_persisted
        expect { episode_notification_6.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { episode_notification_7.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'released anime' do
      let(:anime) do
        create :anime, :released,
          episodes: 10,
          episodes_aired: old_episodes_aired,
          released_on: Time.zone.today
      end
      let(:news_topic) { create :news_topic, linked: anime, action: AnimeHistoryAction::Released }

      let(:news_topics) { [news_topic] }

      it 'changes anime status to ongoing' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to be_nil
        expect { news_topic.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
