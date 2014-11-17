describe Api::V1::AnimesController do
  describe 'index' do
    let(:user) { create :user }
    let(:genre) { create :genre }
    let(:studio) { create :studio }
    let(:anime) { create :anime, name: 'Test', aired_on: Date.parse('2014-01-01'), studios: [studio], genres: [genre], duration: 90, rating: 'R - 17+ (violence & profanity)' }
    let!(:user_rate) { create :user_rate, target: anime, user: user, status: 1 }

    before { sign_in user }
    before { get :index, page: 1, limit: 1, type: 'TV', season: '2014', genre: genre.id.to_s, studio: studio.id.to_s, duration: 'F', rating: 'NC-17', search: 'Te', order: 'ranked', mylist: '1', format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { expect(assigns(:collection).size).to eq(1) }
  end

  describe 'show' do
    let(:anime) { create :anime, :with_thread }
    before { get :show, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end

  describe 'similar' do
    let(:anime) { create :anime }
    let!(:similar) { create :similar_anime, src: anime }
    before { get :similar, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { expect(assigns(:collection).size).to eq(1) }
  end

  describe 'roles' do
    let(:anime) { create :anime }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, anime: anime, character: character, role: 'Main' }
    let!(:role_2) { create :person_role, anime: anime, person: person, role: 'Director' }
    before { get :roles, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { expect(assigns(:collection).size).to eq(2) }
  end

  describe 'related' do
    let(:anime) { create :anime }
    let!(:similar) { create :related_anime, source: anime, anime: create(:anime), relation: 'Adaptation' }
    before { get :related, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { expect(assigns(:collection).size).to eq(1) }
  end

  describe 'screenshots' do
    let(:anime) { create :anime }
    let!(:screenshot) { create :screenshot, anime: anime }
    before { get :screenshots, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { expect(assigns(:collection).size).to eq(1) }
  end
end
