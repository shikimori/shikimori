# frozen_string_literal: true

describe Animes::ReviewsController do
  let(:anime) { create :anime }
  let!(:review) { create :review, anime: anime, user: user }

  describe '#index' do
    subject! do
      get :index, params: { anime_id: anime.to_param, type: 'Anime' }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    subject! do
      get :show, params: { anime_id: anime.to_param, type: 'Anime', id: review.id }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#new' do
    include_context :authenticated, :user, :day_registered
    subject! do
      get :new,
        params: {
          anime_id: anime.to_param,
          type: 'Anime'
        }
    end

    context 'no user review' do
      let(:review) { nil }
      it { expect(response).to have_http_status :success }
    end

    context 'has user review' do
      it do
        expect(response).to redirect_to UrlGenerator.instance.review_url(review)
      end
    end
  end

  describe '#create' do
    include_context :authenticated, :user, :day_registered
    before { Review.delete_all }

    subject! do
      post :create,
        params: {
          anime_id: anime.to_param,
          type: 'Anime',
          review: params
        }
    end

    context 'valid params' do
      let(:params) do
        {
          anime_id: anime.id,
          body: 'x' * Review::MIN_BODY_SIZE,
          opinion: 'positive'
        }
      end

      it do
        expect(assigns(:review)).to be_persisted
        expect(assigns(:review)).to have_attributes params
        expect(assigns(:review).user).to eq user
        expect(response).to redirect_to UrlGenerator.instance.review_url(assigns(:review))
      end
    end

    context 'invalid params' do
      let(:params) do
        {
          anime_id: anime.id,
          body: 'x' * (Review::MIN_BODY_SIZE - 1),
          opinion: 'positive'
        }
      end

      it do
        expect(assigns(:review)).to be_new_record
        expect(response).to render_template :new
        expect(response).to have_http_status :success
      end
    end
  end

  # describe '#edit' do
  #   include_context :authenticated, :user, :day_registered
  #   subject! do
  #     get :edit,
  #       params: {
  #         anime_id: anime.to_param,
  #         type: Anime.name,
  #         id: review.id
  #       }
  #   end
  #   it { expect(response).to have_http_status :success }
  # end
end
