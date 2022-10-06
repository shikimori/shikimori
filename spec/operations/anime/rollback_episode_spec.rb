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

  subject { described_class.call anime: anime, episode: episode, user: user }

  context 'no user' do
    let(:user) { nil }

    context 'episodes_aired == 0' do
      let(:episodes_aired) { 0 }
      let(:episode) { 0 }
      let(:notification_9) { nil }
      let(:notification_10) { nil }
      let(:notification_11) { nil }
      let(:status) { :ongoing }

      it do
        expect { subject }.to_not change Version, :count

        expect(anime).to_not be_changed
        expect(anime.episodes_aired).to eq 0
      end
    end

    context 'episode == episodes_aired' do
      let(:episode) { 10 }

      context 'ongoing' do
        let(:status) { :ongoing }
        it do
          expect { subject }.to_not change Version, :count

          expect(anime).to_not be_changed
          expect(anime.episodes_aired).to eq 9

          expect(notification_9.reload).to be_persisted
          expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'released' do
        let(:status) { :released }
        it do
          expect { subject }.to_not change Version, :count

          expect(anime).to_not be_changed
          expect(anime).to be_ongoing
          expect(anime.episodes_aired).to eq 9

          expect(notification_9.reload).to be_persisted
          expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context 'episode > episodes_aired' do
      let(:episode) { 11 }
      let(:status) { :ongoing }

      it do
        expect { subject }.to_not change Version, :count

        expect(anime).to_not be_changed
        expect(anime.episodes_aired).to eq 10

        expect(notification_9.reload).to be_persisted
        expect(notification_10.reload).to be_persisted
        expect(notification_11.reload).to be_persisted
      end
    end

    context 'episode < episodes_aired' do
      let(:episode) { 9 }
      let(:status) { :ongoing }

      it do
        expect { subject }.to_not change Version, :count

        expect(anime).to_not be_changed
        expect(anime.episodes_aired).to eq 8
        expect { notification_9.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'with user' do
    let(:user) { user_admin }

    context 'episode == episodes_aired' do
      let(:episode) { 10 }

      context 'ongoing' do
        let(:status) { :ongoing }
        it do
          expect { subject }.to change(Version, :count).by 1
          expect(subject).to be_persisted
          expect(subject).to have_attributes(
            item: anime,
            state: 'auto_accepted',
            item_diff: {
              'episodes_aired' => [10, 9]
            }
          )

          expect(anime).to_not be_changed
          expect(anime.episodes_aired).to eq 9

          expect(notification_9.reload).to be_persisted
          expect { notification_10.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { notification_11.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
