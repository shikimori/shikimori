describe CharactersController do
  let!(:character) { create :character }

  describe 'index' do
    let!(:character_2) { create :character, name: 'zzz' }
    before { get :index, search: 'zzz' }

    it { should respond_with :success }
    it { expect(assigns :collection).to eq [character_2] }
  end

  describe 'show' do
    let!(:character) { create :character, :with_thread }
    before { get :show, id: character.to_param }
    it { should respond_with :success }
  end

  describe 'seyu' do
    context 'without_seyu' do
      before { get :seyu, id: character.to_param }
      it { should redirect_to character }
    end

    context 'with_seyu' do
      let!(:role) { create :person_role, :seyu_role, character: character }
      before { get :seyu, id: character.to_param }
      it { should respond_with :success }
    end
  end

  describe 'animes' do
    context 'without_anime' do
      before { get :animes, id: character.to_param }
      it { should redirect_to character }
    end

    context 'with_animes' do
      let!(:role) { create :person_role, :anime_role, character: character }
      before { get :animes, id: character.to_param }
      it { should respond_with :success }
    end
  end

  describe 'mangas' do
    context 'without_manga' do
      before { get :mangas, id: character.to_param }
      it { should redirect_to character }
    end

    context 'with_mangas' do
      let!(:role) { create :person_role, :manga_role, character: character }
      before { get :mangas, id: character.to_param }
      it { should respond_with :success }
    end
  end

  describe 'comments' do
    let!(:character) { create :character, :with_thread }

    context 'without_comments' do
      before { get :comments, id: character.to_param }
      it { should redirect_to character }
    end

    context 'with_comments' do
      let!(:comment) { create :comment, commentable: character.thread }
      before { character.thread.update comments_count: 1 }
      before { get :comments, id: character.to_param }
      it { should respond_with :success }
    end
  end

  describe 'tooltip' do
    before { get :tooltip, id: character.to_param }
    it { should respond_with :success }
  end

  describe 'autocomplete' do
    let!(:character_1) { create :character, name: 'Fffff' }
    before { get :autocomplete, search: 'Fff' }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end

  describe 'edit' do
    pending 'russian'
    pending 'description'
  end
end
