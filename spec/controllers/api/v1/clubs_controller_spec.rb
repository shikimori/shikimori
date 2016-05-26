describe Api::V1::ClubsController, :show_in_doc do
  let(:club) { create :club }

  describe '#index' do
    let(:user) { create :user }
    let(:club_1) { create :club, :with_topics }
    let(:club_2) { create :club, :with_topics }
    let(:club_en) { create :club, :with_topics, locale: :en }

    before do
      club_1.members << user
      club_2.members << user
      club_en.members << user
    end

    before { get :index, page: 1, limit: 1, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(2).items
    end
  end

  describe '#show' do
    include_context :authenticated, :user

    let(:club) { create :club, :with_topics }
    before do
      club.members << user
      club.animes << create(:anime)
      club.mangas << create(:manga)
      club.characters << create(:character)
      club.images << create(:image, uploader: build_stubbed(:user), owner: club)
    end
    let(:make_request) { get :show, id: club.id, format: :json }

    context 'club locale == locale from domain' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'club locale != locale from domain' do
      before { allow(controller).to receive(:ru_domain?).and_return false }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe '#animes' do
    before { club.animes << create(:anime) }
    before { get :animes, id: club.id, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#mangas' do
    before { club.mangas << create(:manga) }
    before { get :mangas, id: club.id, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#characters' do
    before { club.characters << create(:character) }
    before { get :characters, id: club.id, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#members' do
    before { club.members << create(:user) }
    before { get :members, id: club.id, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    before { club.images << create(:image, uploader: build_stubbed(:user), owner: club) }
    before { get :images, id: club.id, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#join' do
    include_context :authenticated, :user
    before { post :join, id: club.id, format: :json }

    it do
      expect(club.joined? user).to be true
      expect(response).to have_http_status :success
    end
  end

  describe '#leave' do
    include_context :authenticated, :user
    let!(:club_role) { create :club_role, club: club, user: user }
    before { post :leave, id: club.id, format: :json }

    it do
      expect(club.joined? user).to be false
      expect(response).to have_http_status :success
    end
  end
end
