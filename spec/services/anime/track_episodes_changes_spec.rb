# frozen_string_literal: true

describe Anime::TrackEpisodesChanges do
  let!(:news_topic) {}
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

    let(:news_topic) do
      create :news_topic,
        linked: anime,
        action: AnimeHistoryAction::Episode,
        value: topic_episode
    end

    let(:old_episodes_aired) { 7 }
    let(:new_episodes_aired) { (1..6).to_a.sample }
    let(:topic_episode) { ((new_episodes_aired + 1)..old_episodes_aired).to_a.sample }

    it 'removes episode topics about aired episodes' do
      expect { news_topic.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'released anime' do
      let(:anime) do
        create :anime, :released,
          episodes: 10,
          episodes_aired: old_episodes_aired,
          released_on: Time.zone.today
      end

      it 'changes anime status to ongoing' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to be_nil
      end
    end
  end
end
