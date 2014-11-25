describe ReviewsController do
  before { create :section, :anime }
  let(:anime) { create :anime }
  let(:review) { create :review, user: user, target: anime }

  describe '#show' do
    let!(:section) { create :section, :reviews }
    let(:user) { create :user }
    before { get :show, id: review.id, anime_id: anime.to_param, type: 'Anime' }
    it { should respond_with :success }
  end

  describe '#index' do
    before { get :index, anime_id: anime.to_param, type: 'Anime' }
    it { should respond_with :success }
  end

  describe '#new' do
    include_context :authenticated, :user
    let(:params) {{ user_id: user.id, target_id: anime.id, target_type: anime.class.name }}
    before { get :new, anime_id: anime.to_param, type: 'Anime', review: params }
    it { should respond_with :success }
  end

  describe '#create' do
    include_context :authenticated, :user
    context 'when success' do
      let(:params) {{ user_id: user.id, target_type: anime.class.name,
        target_id: anime.id, text: 1188.times.sum {|v| 's' },
        storyline: 1, characters: 2, animation: 3, music: 4, overall: 5 }}
      before { post :create, anime_id: anime.to_param, type: 'Anime', review: params }

      it { should redirect_to anime_review_url(anime, resource) }
      it { expect(resource).to be_persisted }
      it { expect(resource).to have_attributes(params) }
    end

    context 'when validation errors' do
      before { post :create, anime_id: anime.to_param, type: 'Anime', review: { user_id: user.id} }

      it { should respond_with :success }
      it { expect(assigns :review).to be_new_record }
    end
  end

  describe '#edit' do
    include_context :authenticated, :user
    before { get :edit, anime_id: anime.to_param, type: 'Anime', id: review.id }
    it { should respond_with :success }
  end

  describe '#update' do
    include_context :authenticated, :user

    context 'when success' do
      let(:params) {{ user_id: user.id, target_type: anime.class.name,
        target_id: anime.id, text: 1188.times.sum {|v| 's' },
        storyline: 1, characters: 2, animation: 3, music: 4, overall: 5 }}
      before { patch :update, id: review.id, review: params, anime_id: anime.to_param, type: 'Anime' }

      it { should redirect_to anime_review_url(anime, resource) }
      it { expect(resource).to be_persisted }
      it { expect(resource).to have_attributes(params) }
    end

    context 'when validation errors' do
      before { patch :update, id: review.id, review: { user_id: user.id, text: 'test' }, anime_id: anime.to_param, type: 'Anime' }

      it { should respond_with :success }
      it { expect(assigns :review).to_not be_valid }
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user
    before { delete :destroy, id: review.id, anime_id: anime.to_param, type: 'Anime' }
    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    it { expect(resource).to be_destroyed }
  end
end
