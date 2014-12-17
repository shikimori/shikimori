describe Api::V1::MangasController do
  describe 'index' do
    let(:user) { create :user }
    let(:genre) { create :genre }
    let(:publisher) { create :publisher }
    let(:manga) { create :manga, name: 'Test', aired_on: Date.parse('2014-01-01'), publishers: [publisher], genres: [genre], rating: 'R - 17+ (violence & profanity)' }
    let!(:user_rate) { create :user_rate, target: manga, user: user, status: 1 }

    before { sign_in user }
    before { get :index, page: 1, limit: 1, type: 'Manga', season: '2014', genre: genre.id.to_s, publisher: publisher.id.to_s, rating: 'NC-17', search: 'Te', order: 'ranked', mylist: '1', format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    specify { expect(assigns(:collection).size).to eq(1) }
  end

  describe 'show' do
    let(:manga) { create :manga, :with_thread }
    before { get :show, id: manga.id, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end

  describe 'similar' do
    let(:manga) { create :manga }
    let!(:similar) { create :similar_manga, src: manga }
    before { get :similar, id: manga.id, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    specify { expect(assigns(:collection).size).to eq(1) }
  end

  describe 'roles' do
    let(:manga) { create :manga }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, manga: manga, character: character, role: 'Main' }
    let!(:role_2) { create :person_role, manga: manga, person: person, role: 'Director' }
    before { get :roles, id: manga.id, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    specify { expect(assigns(:collection).size).to eq(2) }
  end

  describe 'related' do
    let(:manga) { create :manga }
    let!(:similar) { create :related_manga, source: manga, manga: create(:manga), relation: 'Adaptation' }
    before { get :related, id: manga.id, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    specify { expect(assigns(:collection).size).to eq(1) }
  end
end
