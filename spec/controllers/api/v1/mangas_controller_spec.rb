describe Api::V1::MangasController, :show_in_doc do
  describe '#index' do
    let(:user) { create :user }
    let(:genre) { create :genre }
    let(:publisher) { create :publisher }
    let(:manga) { create :manga, name: 'Test', aired_on: Date.parse('2014-01-01'), publishers: [publisher], genres: [genre], rating: :r }
    let!(:user_rate) { create :user_rate, target: manga, user: user, status: 1 }

    before { sign_in user }
    before { get :index, page: 1, limit: 1, type: 'Manga', season: '2014', genre: genre.id.to_s, publisher: publisher.id.to_s, rating: 'r', search: 'Te', order: 'ranked', mylist: '1', format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(1).item
    end
  end

  describe '#show' do
    let(:manga) { create :manga, :with_topic }
    before { get :show, id: manga.id, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#similar' do
    let(:manga) { create :manga }
    let!(:similar) { create :similar_manga, src: manga }
    before { get :similar, id: manga.id, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(1).item
    end
  end

  describe '#roles' do
    let(:manga) { create :manga }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, manga: manga, character: character, role: 'Main' }
    let!(:role_2) { create :person_role, manga: manga, person: person, role: 'Director' }
    before { get :roles, id: manga.id, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(2).items
    end
  end

  describe '#related' do
    let(:manga) { create :manga }
    let!(:similar) { create :related_manga, source: manga, manga: create(:manga), relation: 'Adaptation' }
    before { get :related, id: manga.id, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(1).item
    end
  end

  describe '#franchise' do
    let(:manga) { create :manga }
    let!(:similar) { create :related_manga, source: manga, manga: create(:manga), relation: 'Adaptation' }
    before { get :franchise, id: manga.id, format: :json }
    after { BannedRelations.instance.clear_cache! }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#search' do
    let!(:manga_1) { create :manga, name: 'asdf' }
    let!(:manga_2) { create :manga, name: 'zxcv' }
    before { get :search, q: 'asd', format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
