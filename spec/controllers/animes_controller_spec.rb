describe AnimesController do
  let(:anime) { create :anime }
  include_examples :db_entry_controller, :anime

  describe '#show' do
    let(:anime) { create :anime, :with_topics }

    describe 'id' do
      subject! { get :show, params: { id: anime.id } }
      it { expect(response).to redirect_to anime_url(anime) }
    end

    describe 'to_param' do
      subject! { get :show, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#characters' do
    let(:anime) { create :anime, :with_character }
    subject! { get :characters, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#staff' do
    let(:anime) { create :anime, :with_staff }
    subject! { get :staff, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#files' do
    let(:make_request) { get :files, params: { id: anime.to_param } }

    context 'authenticated' do
      context 'user' do
        include_context :authenticated, :user
        subject! { make_request }
        it { expect(response).to redirect_to anime_url(anime) }
      end

      context 'admin' do
        include_context :authenticated, :admin
        subject! { make_request }
        it { expect(response).to have_http_status :success }
      end
    end

    context 'guest' do
      subject! { get :files, params: { id: anime.to_param } }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#similar' do
    let!(:similar_anime) { create :similar_anime, src: anime }
    subject! { get :similar, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#screenshots' do
    let!(:screenshot) { create :screenshot, anime: anime }

    context 'authenticated' do
      include_context :authenticated, :user
      subject! { get :screenshots, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      subject! { get :screenshots, params: { id: anime.to_param } }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#videos' do
    let!(:video) { create :video, :confirmed, anime: anime }

    context 'authenticated' do
      include_context :authenticated, :user
      subject! { get :videos, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end

    context 'guest' do
      subject! { get :videos, params: { id: anime.to_param } }
      it { expect(response).to redirect_to anime_url(anime) }
    end
  end

  describe '#related' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    subject! { get :related, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#chronology' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }

    before { Animes::BannedRelations.instance.clear_cache! }
    after(:all) { Animes::BannedRelations.instance.clear_cache! }

    subject! { get :chronology, params: { id: anime.to_param } }

    it { expect(response).to have_http_status :success }
  end

  describe '#franchise' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }

    before { Animes::BannedRelations.instance.clear_cache! }
    after(:all) { Animes::BannedRelations.instance.clear_cache! }

    subject! { get :franchise, params: { id: anime.to_param } }

    it { expect(response).to have_http_status :success }
  end

  if Shikimori::IS_IMAGEBOARD_TAGS_ENABLED
    describe '#art' do
      before { Anime.find(anime.id).update imageboard_tag: 'zxc' }
      subject! { get :art, params: { id: anime.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#coub' do
    let(:anime) { create :anime, coub_tags: %i[working] }
    before { allow(Coubs::Fetch).to receive(:call).and_return double(coubs: [], iterator: nil) }
    subject! { get :coub, params: { id: anime.to_param } }

    it { expect(response).to have_http_status :success }
  end

  describe '#cosplay' do
    let(:cosplay_gallery) { create :cosplay_gallery }
    let!(:cosplay_link) { create :cosplay_gallery_link, cosplay_gallery: cosplay_gallery, linked: anime }
    subject! { get :cosplay, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: anime }
    subject! { get :favoured, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#clubs' do
    let(:club) { create :club, :with_topics, :with_member }
    let!(:club_link) { create :club_link, linked: anime, club: club }
    subject! { get :clubs, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#collections' do
    let!(:collection) { create :collection, :published, :with_topics, :anime }
    let!(:collection_link) do
      create :collection_link, collection: collection, linked: anime
    end
    subject! { get :collections, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#summaries' do
    let(:anime) { create :anime, :with_topics }
    let!(:comment) { create :comment, :summary, commentable: anime.topic(:ru) }
    subject! { get :summaries, params: { id: anime.to_param } }

    it { expect(response).to have_http_status :success }
  end

  describe '#resources' do
    subject! { get :resources, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#watch_online' do
    subject! { get :watch_online, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#other_names' do
    subject! { get :other_names, params: { id: anime.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#episode_torrents' do
    let(:make_request) { get :episode_torrents, params: { id: anime.to_param } }

    context 'authenticated' do
      context 'user' do
        include_context :authenticated, :user
        it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
      end

      context 'admin' do
        include_context :authenticated, :forum_moderator
        subject! { make_request }
        it { expect(response).to have_http_status :success }
      end
    end

    context 'guest' do
      subject! { get :files, params: { id: anime.to_param } }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe '#increment_episode' do
    let(:make_request) { post :increment_episode, params: { id: anime.to_param } }
    let(:anime) { create :anime, :ongoing, episodes_aired: 10 }

    context 'has access' do
      include_context :authenticated, :admin
      subject! { make_request }
      it do
        expect(resource.episodes_aired).to eq 11
        expect(response).to redirect_to edit_anime_url(anime)
      end
    end

    context 'no access' do
      include_context :authenticated, :forum_moderator
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
      end
    end
  end

  describe '#rollback_episode' do
    let(:make_request) { post :rollback_episode, params: { id: anime.to_param } }
    let(:anime) { create :anime, episodes_aired: 10 }

    context 'has access' do
      include_context :authenticated, :admin
      subject! { make_request }
      it do
        expect(resource.episodes_aired).to eq 9
        expect(response).to redirect_to edit_anime_url(anime)
      end
    end

    context 'no access' do
      include_context :authenticated, :forum_moderator
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
