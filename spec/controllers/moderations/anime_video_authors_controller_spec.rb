describe Moderations::AnimeVideoAuthorsController do
  include_context :authenticated, :video_moderator

  let!(:anime_video) do
    create :anime_video,
      anime: create(:anime),
      author_name: 'test'
  end

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    before { get :show, params: { id: anime_video.anime_video_author_id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#none' do
    before { get :none }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    before { get :edit, params: { id: anime_video.anime_video_author_id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    before do
      patch :update,
        params: {
          id: anime_video.anime_video_author_id,
          anime_video_author: { name: 'zxcvbnm' }
        }
    end

    it do
      expect(resource).to be_valid
      expect(resource).to have_attributes name: 'zxcvbnm'
      expect(response).to redirect_to moderations_anime_video_authors_url
    end
  end
end
