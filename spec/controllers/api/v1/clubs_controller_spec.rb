describe Api::V1::ClubsController do
  describe '#index' do
    let(:user) { create :user }
    let(:club_1) { create :group, :with_thread }
    let(:club_2) { create :group, :with_thread }
    before do
      club_1.members << user
      club_2.members << user
    end

    before { get :index, page: 1, limit: 1, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    specify { expect(assigns(:collection).size).to eq(2) }
  end

  describe '#show' do
    include_context :authenticated, :user
    let(:club) { create :group, :with_thread }
    before do
      club.members << user
      club.animes << create(:anime)
      club.mangas << create(:manga)
      club.characters << create(:character)
      club.images << create(:image, uploader: build_stubbed(:user), owner: club)
    end
    before { get :show, id: club.id, format: :json }

    it { should respond_with :success }
  end

  describe '#animes' do
    let(:club) { create :group }
    before { club.animes << create(:anime) }
    before { get :animes, id: club.id, format: :json }

    it { should respond_with :success }
  end

  describe '#mangas' do
    let(:club) { create :group }
    before { club.mangas << create(:manga) }
    before { get :mangas, id: club.id, format: :json }

    it { should respond_with :success }
  end

  describe '#characters' do
    let(:club) { create :group }
    before { club.characters << create(:character) }
    before { get :characters, id: club.id, format: :json }

    it { should respond_with :success }
  end

  describe '#members' do
    let(:club) { create :group }
    before { club.members << create(:user) }
    before { get :members, id: club.id, format: :json }

    it { should respond_with :success }
  end

  describe '#images' do
    let(:club) { create :group }
    before { club.images << create(:image, uploader: build_stubbed(:user), owner: club) }
    before { get :images, id: club.id, format: :json }

    it { should respond_with :success }
  end
end
