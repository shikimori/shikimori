# frozen_string_literal: true

describe Anime::TrackEpisodesChanges do
  let!(:news_topics) {}

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

      it 'changes anime status to released' do
        expect(anime).to be_released
        expect(anime.released_on).to eq Time.zone.today
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
    let!(:news_topics) { [news_topic_5, news_topic_6, news_topic_7] }

    let(:old_episodes_aired) { 7 }
    let(:new_episodes_aired) { 5 }

    it 'removes episode topics about reverted episodes' do
      expect(news_topic_5.reload).to be_persisted
      expect { news_topic_6.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { news_topic_7.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'released anime' do
      let(:anime) do
        create :anime, :released,
          episodes: 10,
          episodes_aired: old_episodes_aired,
          released_on: Time.zone.today
      end
      let!(:news_topic) { create :news_topic, linked: anime, action: AnimeHistoryAction::Released }
      let!(:news_topics) { [news_topic] }

      it 'changes anime status to ongoing' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to be_nil
        expect { news_topic.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
