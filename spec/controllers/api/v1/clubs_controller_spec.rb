describe Api::V1::ClubsController, :show_in_doc do
  describe '#index' do
    include_context :timecop

    let!(:club_1) { create :club, :with_topics, id: 2 }
    let!(:club_2) { create :club, :with_topics, id: 3 }
    let!(:club_3) { create :club, :with_topics, id: 4 }
    subject! do
      get :index,
        params: {
          page: 1,
          limit: 1,
          search: ''
        },
        format: :json
    end

    it do
      expect(collection).to eq [club_1, club_2]
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#update' do
    include_context :authenticated, :user, :week_registered
    let(:club) { create :club, :with_topics, owner: user }

    context 'valid params' do
      subject! do
        patch :update,
          params: {
            id: club.id,
            club: params
          },
          format: :json
      end
      let(:params) { { name: 'test club' } }

      it do
        expect(resource.errors).to be_empty
        expect(resource).to_not be_changed
        expect(resource).to have_attributes params
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response).to have_http_status :success
      end
    end

    context 'invalid params' do
      subject! do
        patch 'update',
          params: {
            id: club.id,
            club: params
          },
          format: :json
      end
      let(:params) { { name: '' } }

      it_behaves_like :failed_resource_change, true
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
      club.images << create(:club_image, user: build_stubbed(:user), club: club)
    end
    let(:make_request) { get :show, params: { id: club.id }, format: :json }

    subject! { make_request }

    it { expect(response).to have_http_status :success }
  end

  describe '#animes' do
    before { club.animes << create(:anime) }
    subject! do
      get :animes,
        params: {
          id: club.id,
          page: 1
        },
        format: :json
    end

    it { expect(response).to have_http_status :success }
  end

  describe '#mangas' do
    before { club.mangas << create(:manga) }
    subject! do
      get :mangas,
        params: {
          id: club.id,
          page: 1
        },
        format: :json
    end

    it { expect(response).to have_http_status :success }
  end

  describe '#ranobe' do
    before { club.mangas << create(:ranobe) }
    subject! do
      get :ranobe,
        params: {
          id: club.id,
          page: 1
        },
        format: :json
    end

    it { expect(response).to have_http_status :success }
  end

  describe '#characters' do
    before { club.characters << create(:character) }
    subject! do
      get :characters,
        params: {
          id: club.id,
          page: 1
        },
        format: :json
    end

    it { expect(response).to have_http_status :success }
  end

  describe '#collections' do
    before { club.collections << create(:collection) }
    subject! { get :collections, params: { id: club.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#clubs' do
    before { club.clubs << create(:club) }
    subject! do
      get :clubs,
        params: {
          id: club.id,
          page: 1
        },
        format: :json
    end

    it { expect(response).to have_http_status :success }
  end

  describe '#members' do
    before { club.members << create(:user) }
    before { get :members, params: { id: club.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    before { club.images << create(:club_image, user: build_stubbed(:user), club: club) }
    before { get :images, params: { id: club.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#join' do
    include_context :authenticated, :user
    before { post :join, params: { id: club.id }, format: :json }

    it do
      expect(club.member? user).to be true
      expect(response).to have_http_status :success
    end
  end

  describe '#leave' do
    include_context :authenticated, :user
    let!(:club_role) { create :club_role, club: club, user: user }
    before { post :leave, params: { id: club.id }, format: :json }

    it do
      expect(club.member? user).to be false
      expect(response).to have_http_status :success
    end
  end
end
