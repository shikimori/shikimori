describe Api::V1::AnimesController, :show_in_doc do
  describe '#index' do
    let(:user) { create :user }
    let(:genre) { create :genre }
    let(:studio) { create :studio }
    let(:anime) { create :anime, name: 'Test', aired_on: Date.parse('2014-01-01'),
      studios: [studio], genres: [genre], duration: 90, rating: :r }
    let!(:user_rate) { create :user_rate, target: anime, user: user, status: 1 }

    before { sign_in user }
    before { get :index, page: 1, limit: 1, type: 'TV', season: '2014',
      genre: genre.id.to_s, studio: studio.id.to_s, duration: 'F', rating: 'r',
      search: 'Te', order: 'ranked', mylist: '1', format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#show' do
    let(:anime) { create :anime, :with_thread }
    before { get :show, id: anime.id, format: :json }

    it do
      expect(json).to have_key :description_html
      expect(json).to have_key :videos
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#similar' do
    let(:anime) { create :anime }
    let!(:similar) { create :similar_anime, src: anime }
    before { get :similar, id: anime.id, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#roles' do
    let(:anime) { create :anime }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, anime: anime, character: character, role: 'Main' }
    let!(:role_2) { create :person_role, anime: anime, person: person, role: 'Director' }
    before { get :roles, id: anime.id, format: :json }

    it do
      expect(collection).to have(2).items
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#related' do
    let(:anime) { create :anime }
    let!(:similar) { create :related_anime, source: anime, anime: create(:anime), relation: 'Adaptation' }
    before { get :related, id: anime.id, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#screenshots' do
    let(:anime) { create :anime }
    let!(:screenshot) { create :screenshot, anime: anime }
    before { get :screenshots, id: anime.id, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#videos' do
    let(:anime) { create :anime }
    let!(:video) { create :video, :confirmed, anime: anime }
    before { get :videos, id: anime.id, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#franchise' do
    let(:anime) { create :anime }
    let!(:similar) { create :related_anime, source: anime, anime: create(:anime), relation: 'Adaptation' }
    before { get :franchise, id: anime.id, format: :json }
    after { BannedRelations.instance.clear_cache! }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#search' do
    let!(:anime_1) { create :anime, name: 'asdf' }
    let!(:anime_2) { create :anime, name: 'zxcv' }
    before { get :search, q: 'asd', format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
