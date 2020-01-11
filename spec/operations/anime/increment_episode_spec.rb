describe Anime::IncrementEpisode do
  let(:anime) do
    create :anime, status, :with_track_changes,
      episodes_aired: episodes_aired,
      episodes: 100
  end
  let(:episodes_aired) { 10 }

  subject! { described_class.call anime }

  context 'anons' do
    let(:status) { :anons }
    let(:episodes_aired) { 0 }

    it do
      expect(anime).to be_ongoing
      expect(anime.episodes_aired).to eq 1
    end
  end

  context 'ongoing' do
    let(:status) { :ongoing }
    let(:episodes_aired) { 10 }

    it do
      expect(anime).to be_ongoing
      expect(anime.episodes_aired).to eq 11
    end
  end

  context 'released' do
    let(:status) { :released }
    let(:episodes_aired) { 100 }

    it do
      expect(anime).to be_released
      expect(anime.episodes_aired).to eq 100
    end
  end
end
