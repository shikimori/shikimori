describe ClubsController do
  let(:club) { create :group }

  describe '#index' do
    let(:club) { create :group, :with_thread }
    let(:user) { create :user }
    let!(:group_role) { create :group_role, group: club, user: user, role: 'admin' }

    describe 'no_pagination' do
      before { get :index }
      it { should respond_with :success }
      it { expect(assigns :collection).to eq [club] }
    end

    describe 'pagination' do
      before { get :index, page: 1 }
      it { should respond_with :success }
    end
  end

  describe '#show' do
    let(:club) { create :group, :with_thread }
    before { get :show, id: club.to_param }
    it { should respond_with :success }
  end

  describe '#new' do
    include_context :authenticated
    before { get :new }
    it { should respond_with :success }
  end

  describe '#edit' do
    include_context :authenticated
    let(:club) { create :group, owner: user }
    before { get :edit, id: club.to_param }

    it { should respond_with :success }
  end

  describe '#create' do
    include_context :authenticated

    context 'when success' do
      before { post :create, club: { name: 'test', owner_id: user.id } }
      it { should redirect_to edit_club_url(resource) }
    end

    context 'when validation errors' do
      before { post :create, club: { owner_id: user.id } }

      it { should respond_with :success }
      it { expect(resource.new_record?).to be true }
    end
  end

  describe '#update' do
    include_context :authenticated
    let(:club) { create :group, :with_thread, owner: user }

    context 'when success' do
      before { patch :update, id: club.id, club: { name: 'newnewtest' } }

      it { should redirect_to edit_club_url(resource) }
      it { expect(resource.name).to eq 'newnewtest' }
      it { expect(resource.errors).to be_empty }
    end

    context 'when validation errors' do
      before { patch 'update', id: club.id, club: { name: '' } }

      it { should respond_with :success }
      it { expect(resource.errors).to_not be_empty }
    end
  end


  describe '#upload' do
    include_context :authenticated
    let!(:group_role) { create :group_role, group: club, user: user, role: 'admin' }
    let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }
    before { post :upload, id: club.to_param, image: image }

    it { should redirect_to club_url(club) }
    it { expect(club.images.size).to eq(1) }

    context 'image' do
      subject { club.images.first }
      its(:uploader) { should eq user }
    end
  end

  describe '#members' do
    let(:club) { create :group }
    before { get :members, id: club.to_param }
    it { should respond_with :success }
  end

  describe '#images' do
    let(:club) { create :group }
    before { get :images, id: club.to_param }
    it { should respond_with :success }
  end

  describe '#comments' do
    let!(:club) { create :group, :with_thread }

    context 'without_comments' do
      before { get :comments, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context 'with_comments' do
      let!(:comment) { create :comment, commentable: club.thread }
      before { club.thread.update comments_count: 1 }
      before { get :comments, id: club.to_param }
      it { should respond_with :success }
    end
  end

  describe '#animes' do
    context 'without_animes' do
      before { get :animes, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context 'with_animes' do
      let(:club) { create :group, :with_thread, :linked_anime }
      before { get :animes, id: club.to_param }
      it { should respond_with :success }
    end
  end

  describe '#mangas' do
    context 'without_mangas' do
      before { get :mangas, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context 'with_mangas' do
      let(:club) { create :group, :with_thread, :linked_manga }
      before { get :mangas, id: club.to_param }
      it { should respond_with :success }
    end
  end

  describe '#characters' do
    context 'without_characters' do
      before { get :characters, id: club.to_param }
      it { should redirect_to club_url(club) }
    end

    context 'with_characters' do
      let(:club) { create :group, :with_thread, :linked_character }
      before { get :characters, id: club.to_param }
      it { should respond_with :success }
    end
  end
end
