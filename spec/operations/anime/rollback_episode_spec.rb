describe Anime::RollbackEpisode do
  let(:anime) do
    create :anime, status,
      :with_track_changes,
      episodes_aired: episodes_aired,
      episodes: 100
  end
  let!(:notification_9) do
    create :episode_notification, anime: anime, episode: 9
  end
  let!(:notification_10) do
    create :episode_notification, anime: anime, episode: 10
  end
  let!(:notification_11) do
    create :episode_notification, anime: anime, episode: 11
  end
  let(:episodes_aired) { 10 }

  subject! { described_class.call anime, episode }

  context 'episode == episodes_aired' do
    let(:episode) { 10 }

    context 'ongoing' do
      let(:status) { :ongoing }
      it do
        expect(anime).to_not be_changed
        expect(anime.episodes_aired).to eq 9

        expect(notification_9).to be_persisted
        expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'released' do
      let(:status) { :released }
      it do
        expect(anime).to_not be_changed
        expect(anime).to be_ongoing
        expect(anime.episodes_aired).to eq 9

        expect(notification_9).to be_persisted
        expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'episode > episodes_aired' do
    let(:episode) { 11 }
    let(:status) { :ongoing }

    it do
      expect(anime).to_not be_changed
      expect(anime.episodes_aired).to eq 10

      expect(notification_9).to be_persisted
      expect(notification_10).to be_persisted
      expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'episode < episodes_aired' do
    let(:episode) { 9 }
    let(:status) { :ongoing }

    it do
      expect(anime).to_not be_changed
      expect(anime.episodes_aired).to eq 8
      expect { notification_9.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
