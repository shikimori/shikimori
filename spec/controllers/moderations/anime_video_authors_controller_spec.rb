describe Moderations::AnimeVideoAuthorsController do
  include_context :authenticated, :video_moderator

  let!(:anime_video) { create :anime_video, anime: create(:anime), author_name: 'test' }

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    before { get :edit, id: anime_video.anime_video_author_id }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    before do
      patch :update,
        id: anime_video.anime_video_author_id,
        anime_video_author: { name: 'zxcvbnm' }
    end

    it do
      expect(resource).to be_valid
      expect(resource).to have_attributes name: 'zxcvbnm'
      expect(response).to redirect_to moderations_anime_video_authors_url
    end
  end
end
