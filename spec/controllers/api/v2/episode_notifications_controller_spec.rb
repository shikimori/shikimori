describe Api::V2::EpisodeNotificationsController, :show_in_doc do
  include_context :timecop
  let(:anime) { create :anime, :ongoing, episodes_aired: 2, episodes: 4 }

  describe '#create' do
    subject do
      post :create,
        params: {
          episode_notification: params,
          token: token
        },
        format: :json
    end
    let(:params) do
      {
        anime_id: anime.id.to_s,
        episode: 3.to_s,
        aired_at: 1.week.ago.iso8601,
        is_raw: false,
        is_subtitles: false,
        is_fandub: true,
        is_anime365: true
      }
    end

    before do
      allow(EpisodeNotification::Track).to receive(:call).and_call_original
      allow(controller).to receive(:topic_id).and_return 123
    end

    context 'invalid token' do
      let(:token) { 'zxc' }
      it do
        expect { subject }.to raise_error CanCan::AccessDenied
        expect(EpisodeNotification::Track).to_not have_received(:call)
      end
    end

    context 'valid token' do
      let(:token) { Rails.application.secrets[:api][:anime_videos][:token] }
      before { subject }

      context 'no episode notifiaction' do
        it do
          expect(anime.reload.episodes_aired).to eq 3
          expect(EpisodeNotification::Track)
            .to have_received(:call)
            .with(
              **params.except(:anime_id),
              anime: anime
            )
          expect(anime.episode_notifications.first).to have_attributes(
            episode: 3,
            is_raw: false,
            is_subtitles: false,
            is_fandub: true,
            is_anime365: true
          )
          expect(anime.episode_notifications.first.created_at).to be_within(1).of 1.week.ago

          expect(response).to have_http_status :success
        end
      end
    end
  end
end
