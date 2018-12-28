describe Api::V1::AnimeVideosController do
  let(:anime) { create :anime }
  let!(:anime_video) { create :anime_video, anime: anime }

  describe '#index' do
    let(:make_request) do
      get :index, params: { anime_id: anime.id, video_token: video_token }, format: :json
    end
    let(:video_token) {}

    context 'video_token' do
      subject! { make_request }
      let(:video_token) { Rails.application.secrets[:api][:anime_videos][:token] }

      it do
        expect(collection).to have(1).item
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'trusted video uploader' do
      include_context :authenticated, :trusted_video_uploader
      subject! { make_request }

      it do
        expect(collection).to have(1).item
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'common user' do
      include_context :authenticated, :user
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#create', :show_in_doc do
    include_context :authenticated, :user
    let(:video_params) do
      {
        kind: kind,
        author_name: 'test',
        episode: 3,
        url: 'http://smotretanime.ru/catalog/anime-princessa-vampir-miyu-1988-2/ova-1-seriya-93732/russkie-subtitry-758598',
        source: 'http://url-for-page-where-you-got-video',
        language: 'russian',
        quality: 'bd',
        anime_id: anime.id
      }
    end

    subject! do
      post :create,
        params: {
          anime_id: anime.id,
          anime_video: video_params
        },
        format: :json
    end

    let(:kind) { 'fandub' }

    it do
      expect(resource).to be_valid
      expect(resource).to be_persisted
      expect(resource).to have_attributes video_params.except(:url)
      expect(resource.url).to eq Url.new(VideoExtractor::PlayerUrlExtractor.call(video_params[:url])).with_http.to_s

      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#destroy' do
    include_context :authenticated, :api_video_uploader
    let(:video) { create :anime_video, anime: anime }
    let!(:upload_report) { create :anime_video_report, anime_video: video, kind: 'uploaded', user: user }

    subject! { delete :destroy, params: { anime_id: anime.id, id: video.id }, format: :json }

    it do
      expect(resource).to be_destroyed
      expect(response).to have_http_status :success
    end
  end
end
