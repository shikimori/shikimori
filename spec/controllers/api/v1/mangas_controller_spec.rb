describe Api::V1::MangasController, :show_in_doc do
  describe '#index' do
    include_context :authenticated, :user

    let(:genre) { create :genre }
    let(:publisher) { create :publisher }
    let!(:user_rate) { create :user_rate, target: manga, user: user, status: 1 }
    let(:manga) do
      create :manga,
        name: 'Test',
        aired_on: Date.parse('2014-01-01'),
        publisher_ids: [publisher.id],
        genre_ids: [genre.id],
        franchise: 'zxc'
    end

    before do
      allow(Search::Manga).to receive(:call) { |params| params[:scope] }
    end

    subject! do
      get :index,
        params: {
          page: 1,
          limit: 1,
          type: 'manga',
          season: '2014',
          genre: genre.id.to_s,
          publisher: publisher.id.to_s,
          franchise: 'zxc',
          search: 'Te',
          order: 'ranked',
          mylist: '1',
          censored: 'false'
        },
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(collection).to have(1).item
    end
  end

  describe '#show' do
    let(:manga) { create :manga, :with_topics }
    subject! { get :show, params: { id: manga.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#similar' do
    let(:manga) { create :manga }
    let!(:similar) { create :similar_manga, src: manga }

    subject! { get :similar, params: { id: manga.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(collection).to have(1).item
    end
  end

  describe '#roles' do
    let(:manga) { create :manga }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, manga: manga, character: character, roles: %w[Main] }
    let!(:role_2) { create :person_role, manga: manga, person: person, roles: %w[Director] }

    subject! { get :roles, params: { id: manga.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(collection).to have(2).items
    end
  end

  describe '#related' do
    let(:manga) { create :manga }
    let!(:similar) { create :related_manga, source: manga, manga: create(:manga), relation: 'Adaptation' }

    subject! { get :related, params: { id: manga.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(collection).to have(1).item
    end
  end

  describe '#franchise' do
    before { Animes::BannedRelations.instance.clear_cache! }
    after(:all) { Animes::BannedRelations.instance.clear_cache! }

    let(:manga) { create :manga }
    let!(:similar) { create :related_manga, source: manga, manga: create(:manga), relation: 'Adaptation' }
    subject! { get :franchise, params: { id: manga.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#external_links' do
    let(:manga) { create :manga, mal_id: 123 }
    let!(:external_links) do
      create :external_link,
        entry: manga,
        kind: :wikipedia,
        url: 'en.wikipedia.org'
    end

    subject! { get :external_links, params: { id: manga.id }, format: :json }

    it do
      expect(collection).to have(2).items
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#search' do
    let!(:manga_1) { create :manga, name: 'asdf' }
    let!(:manga_2) { create :manga, name: 'zxcv' }
    before do
      allow(Search::Manga).to receive(:call) do |params|
        params[:scope].where(id: manga_1)
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
    let!(:topic) { create :topic, linked: manga, locale: 'ru' }
    let(:manga) { create :manga }

    subject! { get :topics, params: { id: manga.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(collection).to have(1).item
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
