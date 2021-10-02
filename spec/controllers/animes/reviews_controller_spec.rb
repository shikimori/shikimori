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

  # describe '#new' do
  #   include_context :authenticated, :user, :week_registered

  #   let(:params) do
  #     {
  #       user_id: user.id,
  #       target_id: anime.id,
  #       target_type: anime.class.name
  #     }
  #   end
  #   subject! do
  #     get :new,
  #       params: {
  #         anime_id: anime.to_param,
  #         type: Anime.name,
  #         review: params
  #       }
  #   end

  #   it { expect(response).to have_http_status :success }
  # end

  describe '#edit' do
    include_context :authenticated, :user, :week_registered
    subject! do
      get :edit,
        params: {
          anime_id: anime.to_param,
          type: Anime.name,
          id: review.id
        }
    end
    it { expect(response).to have_http_status :success }
  end
end
