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
      allow(AnimeVideoAuthor::Rename).to receive :call
      allow(AnimeVideoAuthor::SplitRename).to receive :call
    end

    before do
      patch :update,
        params: {
          id: anime_video.anime_video_author_id,
          anime_video_author: params
        }
    end

    context 'without name' do
      let(:params) { { is_verified: true } }

      it do
        expect(AnimeVideoAuthor::Rename).to_not have_received :call
        expect(AnimeVideoAuthor::SplitRename).to_not have_received :call

        expect(resource).to be_valid
        expect(resource).to be_verified
        expect(response).to redirect_to moderations_anime_video_authors_url
      end
    end

    context 'with name' do
      let(:params) { { name: 'zxcvbnm', is_verified: true } }

      it do
        expect(AnimeVideoAuthor::Rename)
          .to have_received(:call)
          .with resource, params[:name]
        expect(AnimeVideoAuthor::SplitRename).to_not have_received :call

        expect(resource).to be_valid
        expect(resource).to be_verified
        expect(response).to redirect_to moderations_anime_video_authors_url
      end

      context 'with anime_id' do
        let(:params) { { name: 'zxcvbnm', anime_id: '1', is_verified: true } }

        it do
          expect(AnimeVideoAuthor::Rename).to_not have_received :call
          expect(AnimeVideoAuthor::SplitRename)
            .to have_received(:call)
            .with model: resource, new_name: params[:name], anime_id: params[:anime_id]

          expect(resource).to be_valid
          expect(resource).to be_verified
          expect(response).to redirect_to moderations_anime_video_authors_url
        end
      end
    end
  end
end
