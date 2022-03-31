describe VideosController do
  include_context :authenticated, :version_moderator

  let(:anime) { create :anime }
  let(:url) { 'https://youtube.com/watch?v=l1YX30AmYsA' }
  let(:name) { 'test' }
  let(:kind) { 'pv' }

  let(:json) { JSON.parse response.body }

  describe '#create' do
    include_context :back_redirect
    let(:video_params) { { url: url, kind: kind, name: name } }

    describe 'post request' do
      subject! { post :create, params: { anime_id: anime.id, video: video_params } }
      it do
        expect(assigns :video).to be_uploaded
        expect(assigns :video).to have_attributes(
          url: url,
          name: name,
          kind: kind,
          anime_id: anime.id,
          uploader_id: user.id
        )
        expect(assigns :video).to be_persisted

        expect(assigns :version).to be_persisted
        expect(assigns(:version).item_diff['action']).to eq(
          Versions::VideoVersion::Actions[:upload].to_s
        )

        expect(response).to redirect_to back_url
      end
    end

    describe 'xhr request' do
      let(:anime_id) { anime.id }
      let!(:video) { nil }

      subject! do
        post :create,
          params: { anime_id: anime_id, video: video_params },
          xhr: true,
          format: :json
      end

      context 'new video' do
        context 'with anime' do
          it do
            expect(assigns :video).to be_persisted
            expect(assigns :video).to be_uploaded
            expect(assigns(:video).anime).to eq anime

            expect(json).to_not have_key 'errors'
            expect(json).to have_key 'video_id'
            expect(json).to have_key 'content'
          end
        end

        context 'wo anime' do
          let(:anime_id) { 0 }
          it do
            expect(assigns :video).to be_persisted
            expect(assigns :video).to be_uploaded
            expect(assigns(:video).anime).to be_nil

            expect(json).to_not have_key 'errors'
            expect(json).to have_key 'video_id'
            expect(json).to have_key 'content'
          end
        end
      end

      context 'invalid video' do
        let(:video_params) { { kind: kind, name: name } }

        it do
          expect(assigns :video).to_not be_persisted

          expect(json).to have_key 'errors'
          expect(json).to_not have_key 'video_id'
          expect(json).to_not have_key 'content'
        end
      end

      context 'already uploaded video' do
        let!(:video) { create :video, video_params.merge(anime: anime) }
        subject! do
          post :create,
            params: { anime_id: anime.id, video: video_params },
            xhr: true,
            format: :json
        end

        it do
          expect(assigns :video).to eq video

          expect(json).to_not have_key 'errors'
          expect(json).to have_key 'video_id'
          expect(json).to have_key 'content'
        end
      end
    end
  end

  describe '#update' do
    let(:video) { create :video, :confirmed, anime: anime }
    subject! do
      patch :update,
        params: {
          anime_id: anime.id,
          id: video.id,
          video: video_params,
          reason: 'zxc'
        }
    end

    context 'success' do
      let(:video_params) { { kind: 'pv' } }
      it do
        expect(assigns :version).to be_persisted
        expect(assigns :version).to have_attributes(
          item: video,
          user_id: user.id,
          moderator_id: user.id,
          state: 'auto_accepted',
          item_diff: { 'kind' => ['op', 'pv'] },
          reason: 'zxc',
          associated: anime
        )
        expect(response).to redirect_to edit_field_anime_url(anime, field: 'videos')
      end
    end

    context 'failure' do
      let(:video_params) { { kind: 'op' } }
      it do
        expect(assigns :version).to_not be_persisted
        expect(response).to redirect_to edit_video_anime_url(anime, video)
      end
    end
  end

  describe '#destroy' do
    let(:video) { create :video, :confirmed }
    subject! { post :destroy, params: { anime_id: anime.id, id: video.id } }

    it do
      expect(assigns :version).to be_persisted
      expect(assigns(:version).item_diff['action']).to eq(
        Versions::VideoVersion::Actions[:delete].to_s
      )

      expect(response).to have_http_status :success
    end
  end
end
