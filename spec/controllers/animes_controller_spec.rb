describe AnimesController do
  let(:anime) { create :anime }
  include_examples :db_entry_controller, :anime

  describe '#show' do
    let(:anime) { create :anime, :with_topics }

    describe 'id' do
      before { get :show, params: { id: anime.id } }
      it { expect(response).to redirect_to anime_url(anime) }
    end

    describe 'to_param' do
      before { get :show, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#characters' do
    let(:anime) { create :anime, :with_character }
    before { get :characters, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#staff' do
    let(:anime) { create :anime, :with_staff }
    before { get :staff, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#files' do
    context 'authenticated' do
      include_context :authenticated, :user
      before { get :files, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      before { get :files, params: { id: anime.to_param } }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#similar' do
    let!(:similar_anime) { create :similar_anime, src: anime }
    before { get :similar, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#screenshots' do
    let!(:screenshot) { create :screenshot, anime: anime }

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :screenshots, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      before { get :screenshots, params: { id: anime.to_param } }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#videos' do
    let!(:video) { create :video, :confirmed, anime: anime }

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :videos, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      before { get :videos, params: { id: anime.to_param } }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#related' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :related, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#chronology' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :chronology, params: { id: anime.to_param } }
    after { BannedRelations.instance.clear_cache! }
    it { expect(response).to have_http_status :success }
  end

  describe '#franchise' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :franchise, params: { id: anime.to_param } }
    after { BannedRelations.instance.clear_cache! }
    it { expect(response).to have_http_status :success }
  end

  describe '#art' do
    before { get :art, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    before { get :images, params: { id: anime.to_param } }
    it { expect(response).to redirect_to art_anime_url(anime) }
  end

  describe '#cosplay' do
    let(:cosplay_gallery) { create :cosplay_gallery }
    let!(:cosplay_link) { create :cosplay_gallery_link, cosplay_gallery: cosplay_gallery, linked: anime }
    before { get :cosplay, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: anime }
    before { get :favoured, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#clubs' do
    let(:club) { create :club, :with_topics, :with_member }
    let!(:club_link) { create :club_link, linked: anime, club: club }
    before { get :clubs, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#collections' do
    let!(:collection) { create :collection, :published, :with_topics, :anime }
    let!(:collection_link) do
      create :collection_link, collection: collection, linked: anime
    end
    before { get :collections, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#summaries' do
    let(:anime) { create :anime, :with_topics }
    let!(:comment) { create :comment, :summary, commentable: anime.topic(:ru) }
    before { get :summaries, params: { id: anime.to_param } }

    it { expect(response).to have_http_status :success }
  end

  describe '#resources' do
    before { get :resources, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#other_names' do
    before { get :other_names, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#episode_torrents' do
    before { get :episode_torrents, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    let(:anime) { build_stubbed :anime }
    let(:phrase) { 'qqq' }

    before { allow(Autocomplete::Anime).to receive(:call).and_return [anime] }
    before { get :autocomplete, params: { search: 'Fff' } }

    it do
      expect(collection).to eq [anime]
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#rollback_episode' do
    let(:make_request) { post :rollback_episode, params: { id: anime.to_param } }
    let(:anime) { create :anime, episodes_aired: 10 }

    context 'admin' do
      include_context :authenticated, :admin
      before { make_request }
      it do
        expect(resource.episodes_aired).to eq 9
        expect(response).to redirect_to edit_anime_url(anime)
      end
    end

    context 'not admin' do
      include_context :authenticated, :version_moderator
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
