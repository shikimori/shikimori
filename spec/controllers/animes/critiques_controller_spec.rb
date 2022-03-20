# frozen_string_literal: true

describe Animes::CritiquesController do
  let(:anime) { create :anime }
  let(:critique) { create :critique, :with_topics, user: user, target: anime }

  describe '#index' do
    subject! { get :index, params: { anime_id: anime.to_param, type: 'Anime' } }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    subject! do
      get :show, params: { anime_id: anime.to_param, type: 'Anime', id: critique.id }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#tooltip' do
    subject! do
      get :tooltip,
        params: { anime_id: anime.to_param, type: 'Anime', id: critique.id },
        xhr: is_xhr
    end

    context 'html' do
      let(:is_xhr) { false }
      it { expect(response).to have_http_status :success }
    end

    context 'xhr' do
      let(:is_xhr) { true }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    include_context :authenticated, :user, :week_registered

    let(:params) do
      {
        user_id: user.id,
        target_id: anime.id,
        target_type: anime.class.name
      }
    end
    subject! do
      get :new,
        params: {
          anime_id: anime.to_param,
          type: Anime.name,
          critique: params
        }
    end

    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user, :week_registered

    subject! do
      post :create,
        params: {
          anime_id: anime.to_param,
          type: 'Anime',
          critique: params
        }
    end

    context 'valid params' do
      let(:params) do
        {
          user_id: user.id,
          target_type: anime.class.name,
          target_id: anime.id,
          text: 'x' * Critique::MIN_BODY_SIZE,
          storyline: 1,
          characters: 2,
          animation: 3,
          music: 4,
          overall: 5
        }
      end
      it do
        expect(assigns(:critique)).to be_persisted
        expect(response).to redirect_to UrlGenerator.instance.critique_url(assigns(:critique))
      end
    end

    context 'invalid params' do
      let(:params) do
        {
          user_id: user.id,
          text: 'x' * Critique::MIN_BODY_SIZE,
          storyline: 1,
          characters: 2,
          animation: 3,
          music: 4,
          overall: 5
        }
      end
      it do
        expect(assigns(:critique)).to be_new_record
        expect(response).to render_template :form
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#edit' do
    include_context :authenticated, :user, :week_registered
    subject! do
      get :edit,
        params: {
          anime_id: anime.to_param,
          type: Anime.name,
          id: critique.id
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    include_context :authenticated, :user, :week_registered

    subject! do
      patch :update,
        params: {
          id: critique.id,
          critique: params,
          anime_id: anime.to_param,
          type: 'Anime'
        }
    end

    context 'valid params' do
      let(:params) do
        {
          user_id: user.id,
          target_type: anime.class.name,
          target_id: anime.id,
          text: 'x' * Critique::MIN_BODY_SIZE
        }
      end
      it do
        expect(assigns(:critique).errors).to be_empty
        expect(response).to redirect_to UrlGenerator.instance.critique_url(assigns(:critique))
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
        expect(assigns(:critique).errors).to have(1).item
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy' do
    include_context :authenticated, :user, :week_registered
    subject! do
      delete :destroy,
        params: {
          id: critique.id,
          anime_id: anime.to_param,
          type: Anime.name
        }
    end

    it do
      expect(response.content_type).to eq 'application/json'
      expect(assigns :critique).to be_destroyed
      expect(response).to have_http_status :success
    end
  end
end
