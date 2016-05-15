# frozen_string_literal: true

describe Anime::TrackEpisodesChanges do
  let!(:news_topic) {}

  before do
    anime.assign_attributes episodes_aired: new_episodes_aired
    Anime::TrackEpisodesChanges.call anime
  end

  context 'episodes aired not changed' do
    let(:anime) { create :anime, episodes_aired: old_episodes_aired }

    let(:old_episodes_aired) { 1 }
    let(:new_episodes_aired) { 1 }

    it { expect(anime.status_change).to eq nil }
  end

  describe 'anons aired episodes changed' do
    let(:anime) do
      create :anime,
        status: :anons,
        episodes_aired: old_episodes_aired
    end

    let(:old_episodes_aired) { 0 }
    let(:new_episodes_aired) { 1 }

    it { expect(anime).to be_ongoing }
  end

  describe 'ongoing aired episodes changed' do
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

      it do
        expect(anime).to be_released
        expect(anime.released_on).to eq Time.zone.today
      end
    end

    context 'not last episode aired' do
      let(:episodes) { 8 }

      let(:old_episodes_aired) { 6 }
      let(:new_episodes_aired) { 7 }

      it do
        expect(anime).to be_ongoing
        expect(anime.released_on).to eq nil
      end
    end

    context 'total episodes is 0' do
      let(:episodes) { 0 }

      let(:old_episodes_aired) { 7 }
      let(:new_episodes_aired) { 8 }

      it do
        expect(anime).to be_ongoing
        expect(anime.released_on).to eq nil
      end
    end
  end

  describe 'aired episodes are reset' do
    let(:anime) do
      create :anime,
        status: :ongoing,
        episodes_aired: old_episodes_aired
    end

    let(:news_topic) do
      create :news_topic,
        linked: anime,
        action: AnimeHistoryAction::Episode
    end

    context 'aired episodes not reset' do
      let(:old_episodes_aired) { 7 }
      let(:new_episodes_aired) { 8 }

      it { expect(anime.news).to eq [news_topic] }
    end

    context 'aired episodes reset' do
      let(:old_episodes_aired) { 7 }
      let(:new_episodes_aired) { 0 }

      it { expect(anime.news).to be_empty }
    end
  end
end
