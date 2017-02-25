# frozen_string_literal: true

describe ReviewsController do
  let(:anime) { create :anime }
  let(:review) { create :review, :with_topics, user: user, target: anime }

  before { create :club, id: ReviewsController::REVIEWS_CLUB_ID }

  describe '#index' do
    before { get :index, anime_id: anime.to_param, type: 'Anime' }
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    include_context :authenticated, :user

    let(:params) do
      {
        user_id: user.id,
        target_id: anime.id,
        target_type: anime.class.name
      }
    end
    before { get :new, anime_id: anime.to_param, type: 'Anime', review: params }

    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user

    before do
      post :create,
        anime_id: anime.to_param,
        type: 'Anime',
        review: params
    end

    context 'valid params' do
      let(:params) do
        {
          user_id: user.id,
          target_type: anime.class.name,
          target_id: anime.id,
          text: 'x' * Review::MINIMUM_LENGTH,
          storyline: 1,
          characters: 2,
          animation: 3,
          music: 4,
          overall: 5
        }
      end
      it do
        expect(assigns(:review)).to be_persisted
        topic = assigns(:review).topic(controller.locale_from_host)
        expect(response).to redirect_to UrlGenerator.instance.topic_url topic
      end
    end

    context 'invalid params' do
      let(:params) do
        {
          user_id: user.id,
          text: 'x' * Review::MINIMUM_LENGTH,
          storyline: 1,
          characters: 2,
          animation: 3,
          music: 4,
          overall: 5
        }
      end
      it do
        expect(assigns(:review)).to be_new_record
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

    before do
      patch :update,
        id: review.id,
        review: params,
        anime_id: anime.to_param,
        type: 'Anime'
    end

    context 'valid params' do
      let(:params) do
        {
          user_id: user.id,
          target_type: anime.class.name,
          target_id: anime.id,
          text: 'x' * Review::MINIMUM_LENGTH
        }
      end
      it do
        expect(assigns(:review).errors).to be_empty
        topic = assigns(:review).topic(controller.locale_from_host)
        expect(response).to redirect_to UrlGenerator.instance.topic_url topic
      end
    end

    context 'invalid params' do
      let(:params) do
        {
          user_id: user.id,
          text: 'too short text'
        }
      end
      it do
        expect(assigns(:review).errors).to have(1).item
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user
    before do
      delete :destroy, id: review.id, anime_id: anime.to_param, type: 'Anime'
    end

    it do
      expect(response.content_type).to eq 'application/json'
      expect(assigns :review).to be_destroyed
      expect(response).to have_http_status :success
    end
  end
end
