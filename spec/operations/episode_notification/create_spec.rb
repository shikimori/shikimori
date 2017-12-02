describe EpisodeNotification::Create do
  subject do
    described_class.call(
      anime_id: anime_id,
      episode: episode,
      kind: kind
    )
  end
  let!(:episode_notification) do
    create :episode_notification,
      anime_id: anime.id,
      episode: 1,
      is_subtitles: false
  end
  let(:kind) { :subtitles }
  let(:anime) { create :anime }

  context 'matched anime_id, matched episode' do
    let(:anime_id) { anime.id }
    let(:episode) { 1 }

    it do
      expect { subject }.to_not change EpisodeNotification, :count
      expect(episode_notification.reload.is_subtitles).to eq true
    end
  end

  context 'not matched anime_id, matched episode' do
    let(:anime_id) { create(:anime).id }
    let(:episode) { 1 }

    it do
      expect { subject }.to change(EpisodeNotification, :count).by(1)
      expect(episode_notification.reload.is_subtitles).to eq false
      expect(EpisodeNotification.last).to have_attributes(
        anime_id: anime_id,
        episode: episode,
        is_subtitles: true
      )
    end
  end

  context 'matched anime_id, not matched episode' do
    let(:anime_id) { anime.id }
    let(:episode) { 2 }

    it do
      expect { subject }.to change(EpisodeNotification, :count).by(1)
      expect(episode_notification.reload.is_subtitles).to eq false
      expect(EpisodeNotification.last).to have_attributes(
        anime_id: anime_id,
        episode: episode,
        is_subtitles: true
      )
    end
  end
end
