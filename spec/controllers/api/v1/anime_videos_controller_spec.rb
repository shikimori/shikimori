describe Api::V1::AnimeVideosController do
  let(:anime) { create :anime }
  let!(:anime_video) { create :anime_video, anime: anime }

  describe '#index' do
    let(:make_request) { get :index, anime_id: anime.id, format: :json }

    context 'trusted video uploader' do
      include_context :authenticated, :trusted_video_uploader
      before { make_request }

      it do
        expect(collection).to have(1).item
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'common user' do
      include_context :authenticated, :user
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#create', :show_in_doc do
    include_context :authenticated, :user
    let(:video_params) {{
      state: 'uploaded',
      kind: kind,
      author_name: 'test',
      episode: 3,
      url: 'http://smotret-anime.ru/catalog/anime-princessa-vampir-miyu-1988-2/ova-1-seriya-93732/russkie-subtitry-758598',
      source: 'http://url-for-page-where-you-got-video',
      language: 'russian',
      quality: 'bd',
      anime_id: anime.id
    }}

    before { post :create, anime_id: anime.id, anime_video: video_params, format: :json }

    let(:kind) { 'fandub' }

    it do
      expect(resource).to be_valid
      expect(resource).to be_persisted
      expect(resource).to have_attributes video_params.except(:url)
      expect(resource.url).to eq VideoExtractor::UrlExtractor
        .new(video_params[:url]).extract

      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
