describe ClubsController do
  describe '#index' do
    let!(:club) { create :club, :with_topics, id: 999_999 }
    let!(:club_role) { create :club_role, club: club, user: user, role: 'admin' }

    describe 'no_pagination' do
      subject! { get :index }

      it do
        expect(collection).to eq [club]
        expect(response).to have_http_status :success
      end
    end

    describe 'pagination' do
      subject! { get :index, params: { page: 2 } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    let(:club) { create :club, :with_topics }
    let(:make_request) { get :show, params: { id: club.to_param } }

    context 'shown' do
      subject! { make_request }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    include_context :authenticated, :user, :week_registered
    subject! { get :new, params: { club: { owner_id: user.id } } }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    include_context :authenticated, :user, :week_registered
    let(:club) { create :club, owner: user }
    subject! { get :edit, params: { id: club.to_param, section: 'main' } }

    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user, :week_registered

    context 'valid params' do
      before { allow_any_instance_of(Club).to receive :add_to_index }
      subject! { post :create, params: { club: params } }
      let(:params) { { name: 'test', owner_id: user.id } }

      it do
        expect(resource).to be_persisted
        expect(resource).to_not be_changed
        expect(response).to redirect_to edit_club_url(resource, section: 'main')
      end
    end

    context 'invalid params' do
      subject! { post :create, params: { club: params } }
      let(:params) { { owner_id: user.id } }

      it do
        expect(resource).to be_new_record
        expect(response).to have_http_status :success
      end
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
            club: params,
            section: 'description'
          }
      end
      let(:params) do
        {
          name: 'test club',
          is_censored: [true, false].sample,
          is_private: [true, false].sample
        }
      end

      it do
        expect(resource.errors).to be_empty
        expect(resource).to_not be_changed
        expect(resource).to have_attributes params
        expect(response).to redirect_to edit_club_url(resource, section: :description)
      end
    end

    context 'invalid params' do
      subject! do
        patch 'update',
          params: {
            id: club.id,
            club: params,
            section: 'description'
          }
      end
      let(:params) { { name: '' } }

      it do
        expect(resource.errors).to be_present
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#members' do
    subject! { get :members, params: { id: club.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    subject! { get :images, params: { id: club.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#animes' do
    context 'without_animes' do
      subject! { get :animes, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_animes' do
      let(:club) { create :club, :with_topics, :linked_anime }
      subject! { get :animes, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#mangas' do
    context 'without_mangas' do
      subject! { get :mangas, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_mangas' do
      let(:club) { create :club, :with_topics, :linked_manga }
      subject! { get :mangas, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#ranobe' do
    context 'without_ranobe' do
      subject! { get :ranobe, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_ranobe' do
      let(:club) { create :club, :with_topics, :linked_ranobe }
      subject! { get :ranobe, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#characters' do
    context 'without_characters' do
      subject! { get :characters, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_characters' do
      let(:club) { create :club, :with_topics, :linked_character }
      subject! { get :characters, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#clubs' do
    context 'without_clubs' do
      subject! { get :clubs, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_characters' do
      let(:club) { create :club, :with_topics, :linked_club }
      subject! { get :clubs, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#collections' do
    context 'without_collections' do
      subject! { get :collections, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_characters' do
      let(:club) { create :club, :with_topics }
      let(:collection) { create :collection, :with_topics }
      before { club.collections << collection }
      subject! { get :collections, params: { id: club.to_param } }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#autocomplete' do
    let(:phrase) { 'Fff' }
    let(:club_1) { create :club, :with_topics }
    let(:club_2) { create :club, :with_topics }

    before do
      allow(Elasticsearch::Query::Club).to receive(:call).with(
        phrase: phrase,
        limit: Collections::Query::SEARCH_LIMIT
      ).and_return(
        club_1.id => 987,
        club_2.id => 654
      )
    end
    subject! do
      get :autocomplete,
        params: { search: phrase },
        xhr: true,
        format: :json
    end

    it do
      expect(collection).to eq [club_2, club_1]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
