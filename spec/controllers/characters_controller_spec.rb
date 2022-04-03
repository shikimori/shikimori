describe CharactersController do
  let!(:character) { create :character }
  include_examples :db_entry_controller, :character

  describe '#index' do
    let(:phrase) { 'qqq' }

    before do
      allow(Search::Character)
        .to receive(:call)
        .and_return Character.where(id: character.id)
    end
    subject! { get :index, params: { search: 'Fff' } }

    it do
      expect(collection).to eq [character]
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    let!(:character) { create :character, :with_topics }
    subject! { get :show, params: { id: character.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#seyu' do
    context 'without_seyu' do
      subject! { get :seyu, params: { id: character.to_param } }
      it { expect(response).to redirect_to character }
    end

    context 'with_seyu' do
      let!(:role) { create :person_role, :seyu_role, character: character }
      subject! { get :seyu, params: { id: character.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#animes' do
    context 'without_anime' do
      subject! { get :animes, params: { id: character.to_param } }
      it { expect(response).to redirect_to character }
    end

    context 'with_animes' do
      let!(:role) { create :person_role, :anime_role, character: character }
      subject! { get :animes, params: { id: character.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#mangas' do
    context 'without_manga' do
      subject! { get :mangas, params: { id: character.to_param } }
      it { expect(response).to redirect_to character }
    end

    context 'with_mangas' do
      let!(:role) { create :person_role, :manga_role, character: character }
      subject! { get :mangas, params: { id: character.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#cosplay' do
    let(:cosplay_gallery) { create :cosplay_gallery }
    let!(:cosplay_link) do
      create :cosplay_gallery_link,
        cosplay_gallery: cosplay_gallery, linked: character
    end
    subject! { get :cosplay, params: { id: character.to_param } }
    it { expect(response).to have_http_status :success }
  end

  if Shikimori::IS_IMAGEBOARD_TAGS_ENABLED
    describe '#art' do
      subject! { get :art, params: { id: character.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: character }
    subject! { get :favoured, params: { id: character.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#collections' do
    let!(:collection) { create :collection, :published, :with_topics, :character }
    let!(:collection_link) do
      create :collection_link, collection: collection, linked: character
    end
    subject! { get :collections, params: { id: character.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#clubs' do
    let(:club) { create :club, :with_topics, :with_member }
    let!(:club_link) { create :club_link, linked: character, club: club }
    subject! { get :clubs, params: { id: character.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    let(:character) { build_stubbed :character }
    let(:phrase) { 'qqq' }

    before { allow(Autocomplete::Character).to receive(:call).and_return [character] }
    subject! do
      get :autocomplete,
        params: { search: 'Fff' },
        xhr: true,
        format: :json
    end

    it do
      expect(collection).to eq [character]
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#autocomplete_v2' do
    let(:entry) { build_stubbed :character }
    let(:phrase) { 'qqq' }

    before do
      allow(Autocomplete::Character)
        .to receive(:call)
        .and_return [entry]
    end
    subject! { get :autocomplete_v2, params: { search: 'Fff' }, xhr: true }

    it do
      expect(collection).to eq [entry]
      expect(response.content_type).to eq 'text/html; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end
end
