describe Api::V1::AnimesController, :show_in_doc do
  describe '#index' do
    include_context :authenticated, :user

    let(:genre) { create :genre }
    let(:studio) { create :studio }
    let!(:user_rate) { create :user_rate, target: anime, user: user, status: 1 }
    let(:anime) do
      create :anime,
        :released,
        name: 'Test',
        aired_on: Date.parse('2014-01-01'),
        studio_ids: [studio.id],
        genre_ids: [genre.id],
        duration: 90,
        rating: :r,
        score: 8,
        franchise: 'zxc'
    end

    before do
      allow(Search::Anime).to receive(:call) { |params| params[:scope] }
    end
    subject! do
      get :index,
        params: {
          page: 1,
          limit: 1,
          kind: 'tv',
          status: 'released',
          season: '2014',
          genre: genre.id.to_s,
          studio: studio.id.to_s,
          franchise: 'zxc',
          duration: 'F',
          rating: 'r',
          search: 'Te',
          order: 'ranked',
          mylist: '1',
          score: '6',
          censored: 'false'
        },
        format: :json
    end

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#show' do
    let(:anime) { create :anime, :with_topics }
    subject! { get :show, params: { id: anime.id }, format: :json }

    it do
      expect(json).to have_key :description_html
      expect(json).to have_key :videos
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#similar' do
    let(:anime) { create :anime }
    let!(:similar) { create :similar_anime, src: anime }
    subject! { get :similar, params: { id: anime.id }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#roles' do
    let(:anime) { create :anime }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, anime: anime, character: character, roles: %w[Main] }
    let!(:role_2) { create :person_role, anime: anime, person: person, roles: %w[Director] }
    subject! { get :roles, params: { id: anime.id }, format: :json }

    it do
      expect(collection).to have(2).items
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#related' do
    let(:anime) { create :anime }
    let!(:similar) do
      create :related_anime,
        source: anime,
        anime: create(:anime),
        relation: 'Adaptation'
    end
    subject! { get :related, params: { id: anime.id }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#screenshots' do
    let(:anime) { create :anime }
    let!(:screenshot) { create :screenshot, anime: anime }
    subject! { get :screenshots, params: { id: anime.id }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#videos' do
    let(:anime) { create :anime }
    let!(:video) { create :video, :confirmed, anime: anime }
    subject! { get :videos, params: { id: anime.id }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#franchise' do
    before { Animes::BannedRelations.instance.clear_cache! }
    after(:all) { Animes::BannedRelations.instance.clear_cache! }

    let(:anime) { create :anime }
    let!(:similar) { create :related_anime, source: anime, anime: create(:anime), relation: 'Adaptation' }

    subject! { get :franchise, params: { id: anime.id }, format: :json }


    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#external_links' do
    let(:anime) { create :anime, mal_id: 123 }
    let!(:external_links) do
      create :external_link,
        entry: anime,
        kind: :wikipedia,
        url: 'en.wikipedia.org'
    end
    subject! { get :external_links, params: { id: anime.id }, format: :json }

    it do
      expect(collection).to have(2).items
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#search' do
    let!(:anime_1) { create :anime, name: 'asdf' }
    let!(:anime_2) { create :anime, name: 'zxcv' }
    before do
      allow(Search::Anime).to receive(:call) do |params|
        params[:scope].where(id: anime_1)
      end
    end
    subject! { get :search, params: { q: 'asd', censored: true }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#topics' do
    let!(:topic) { create :topic, linked: anime }
    let(:anime) { create :anime }

    subject! { get :topics, params: { id: anime.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(collection).to have(1).item
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#neko', show_in_doc: false do
    let!(:anime_1) { create :anime, name: 'asdf', genre_ids: [genre.id] }
    let!(:anime_2) { create :anime, name: 'zxcv' }
    let(:genre) { create :genre }

    subject! { get :neko }

    it do
      expect(json).to have(2).items
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
