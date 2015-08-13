describe CharactersController do
  let!(:character) { create :character }
  include_examples :db_entry_controller, :character

  describe '#index' do
    let!(:character_2) { create :character, name: 'zzz' }
    before { get :index, search: 'zzz' }

    it { expect(response).to have_http_status :success }
    it { expect(assigns :collection).to eq [character_2] }
  end

  describe '#show' do
    let!(:character) { create :character, :with_thread }
    before { get :show, id: character.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#seyu' do
    context 'without_seyu' do
      before { get :seyu, id: character.to_param }
      it { expect(response).to redirect_to character }
    end

    context 'with_seyu' do
      let!(:role) { create :person_role, :seyu_role, character: character }
      before { get :seyu, id: character.to_param }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#animes' do
    context 'without_anime' do
      before { get :animes, id: character.to_param }
      it { expect(response).to redirect_to character }
    end

    context 'with_animes' do
      let!(:role) { create :person_role, :anime_role, character: character }
      before { get :animes, id: character.to_param }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#mangas' do
    context 'without_manga' do
      before { get :mangas, id: character.to_param }
      it { expect(response).to redirect_to character }
    end

    context 'with_mangas' do
      let!(:role) { create :person_role, :manga_role, character: character }
      before { get :mangas, id: character.to_param }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#comments' do
    let!(:section) { create :section, :character }
    let(:character) { create :character, :with_thread }
    let!(:comment) { create :comment, commentable: character.thread }
    before { get :comments, id: character.to_param }

    it { expect(response).to redirect_to section_topic_url(id: character.thread, section: section, linked: character) }
  end

  describe '#cosplay' do
    let(:cosplay_gallery) { create :cosplay_gallery }
    let!(:cosplay_link) { create :cosplay_gallery_link, cosplay_gallery: cosplay_gallery, linked: character }
    before { get :cosplay, id: character.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#art' do
    before { get :art, id: character.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    before { get :images, id: character.to_param }
    it { expect(response).to redirect_to art_character_url(character) }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: character }
    before { get :favoured, id: character.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#clubs' do
    let(:group) { create :group, :with_thread, :with_member }
    let!(:group_link) { create :group_link, linked: character, group: group }
    before { get :clubs, id: character.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    let!(:character_1) { create :character, name: 'Fffff' }
    before { get :autocomplete, search: 'Fff' }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
