describe ReviewsController do
  let(:anime) { create :anime }
  let(:review) { create :review, user: user, target: anime }

  describe '#index' do
    before { get :index, anime_id: anime.to_param, type: 'Anime' }
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    include_context :authenticated, :user
    let(:params) {{
      user_id: user.id,
      target_id: anime.id,
      target_type: anime.class.name
    }}
    before { get :new, anime_id: anime.to_param, type: 'Anime', review: params }
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user
    context 'when success' do
      let(:params) {{
        user_id: user.id,
        target_type: anime.class.name,
        target_id: anime.id,
        text: 'x' * Review::MINIMUM_LENGTH,
        storyline: 1,
        characters: 2,
        animation: 3,
        music: 4,
        overall: 5
      }}

      before { post :create, anime_id: anime.to_param, type: 'Anime', review: params }

      it do
        expect(assigns :review).to be_persisted
        expect(assigns :review).to have_attributes(params)
        expect(response).to redirect_to UrlGenerator.instance
          .topic_url(assigns(:review).thread)
      end
    end

    context 'when validation errors' do
      before { post :create, anime_id: anime.to_param, type: 'Anime',
        review: { user_id: user.id} }

      it do
        expect(assigns :review).to be_new_record
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#edit' do
    include_context :authenticated, :user
    before { get :edit, anime_id: anime.to_param, type: 'Anime', id: review.id }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    include_context :authenticated, :user

    context 'when success' do
      let(:params) {{
        user_id: user.id,
        target_type: anime.class.name,
        target_id: anime.id,
        text: 'x' * Review::MINIMUM_LENGTH,
        storyline: 1,
        characters: 2,
        animation: 3,
        music: 4,
        overall: 5
      }}
      before { patch :update, id: review.id, review: params,
        anime_id: anime.to_param, type: 'Anime' }

      it do
        expect(assigns :review).to be_valid
        expect(assigns :review).to have_attributes(params)
        expect(response).to redirect_to UrlGenerator.instance
          .topic_url(assigns(:review).thread)
      end
    end

    context 'when validation errors' do
      before { patch :update, id: review.id,
        review: { user_id: user.id, text: 'test' },
        anime_id: anime.to_param, type: 'Anime' }

      it do
        expect(assigns :review).to_not be_valid
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user
    before { delete :destroy, id: review.id, anime_id: anime.to_param,
      type: 'Anime' }

    it do
      expect(response.content_type).to eq 'application/json'
      expect(assigns :review).to be_destroyed
      expect(response).to have_http_status :success
    end
  end
end
