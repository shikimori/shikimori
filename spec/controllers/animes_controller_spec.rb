describe AnimesController do
  let(:anime) { create :anime }

  describe '#show' do
    let(:anime) { create :anime, :with_thread }

    describe 'id' do
      before { get :show, id: anime.id }
      it { should redirect_to anime_url(anime) }
    end

    describe 'to_param' do
      before { get :show, id: anime.to_param }
      it { should respond_with :success }
    end
  end

  describe '#characters' do
    let(:anime) { create :anime, :with_character }
    before { get :characters, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#staff' do
    let(:anime) { create :anime, :with_staff }
    before { get :staff, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#files' do
    context 'authenticated' do
      include_context :authenticated, :user
      before { get :files, id: anime.to_param }
      it { should respond_with :success }
    end

    context 'guest' do
      before { get :files, id: anime.to_param }
      it { should redirect_to anime_url(anime) }
    end
  end

  describe '#similar' do
    let!(:similar_anime) { create :similar_anime, src: anime }
    before { get :similar, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#screenshots' do
    before { get :screenshots, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#videos' do
    before { get :videos, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#chronology' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :chronology, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#art' do
    pending
  end

  describe '#related' do
    let!(:related_anime) { create :related_anime, source: anime, anime: create(:anime) }
    before { get :related, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#comments' do
    let(:anime) { create :anime, :with_thread }
    let(:comment) { create :comment, commentable: anime.thread }
    before { comment.commentable.update comments_count: 1 }
    before { get :comments, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#reviews' do
    let(:anime) { create :anime, :with_thread }
    let!(:comment) { create :comment, commentable: anime.thread, review: true }
    before { get :reviews, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#resources' do
    before { get :resources, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#other_names' do
    before { get :other_names, id: anime.to_param }
    it { should respond_with :success }
  end

  describe '#edit' do
    context 'guest' do
      let(:page) { nil }
      before { get :edit, id: anime.to_param }
      it { should redirect_to users_sign_in_url }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :edit, id: anime.to_param, page: page }

      describe 'description' do
        let(:page) { nil }
        it { should respond_with :success }
      end

      describe 'russian' do
        let(:page) { 'russian' }
        it { should respond_with :success }
      end

      describe 'video' do
        let(:page) { 'video' }
        it { should respond_with :success }
      end

      describe 'screenshots' do
        let(:page) { 'screenshots' }
        it { should respond_with :success }
      end

      describe 'torrents_name' do
        let(:page) { 'torrents_name' }
        it { should respond_with :success }
      end
    end
  end
end
