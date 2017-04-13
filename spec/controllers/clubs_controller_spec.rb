# frozen_string_literal: true

describe ClubsController do
  include_context :seeds
  let(:club) { create :club }

  describe '#index' do
    let(:club) { create :club, :with_topics }
    let(:user) { create :user }
    let!(:club_role) { create :club_role, club: club, user: user, role: 'admin' }

    describe 'no_pagination' do
      before { get :index }

      it do
        expect(collection).to eq [club]
        expect(response).to have_http_status :success
      end
    end

    describe 'pagination' do
      before { get :index, params: { page: 1 } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    let(:club) { create :club, :with_topics }
    let(:make_request) { get :show, params: { id: club.to_param } }

    context 'club locale == locale from domain' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'club locale != locale from domain' do
      before { allow(controller).to receive(:ru_host?).and_return false }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe '#new' do
    include_context :authenticated, :user, :week_registered
    before { get :new, params: { club: { owner_id: user.id } } }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    include_context :authenticated, :user, :week_registered
    let(:club) { create :club, owner: user }
    before { get :edit, params: { id: club.to_param, page: 'main' } }

    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    include_context :authenticated, :user, :week_registered

    context 'valid params' do
      before { post :create, params: { club: params } }
      let(:params) { { name: 'test', owner_id: user.id } }

      it do
        expect(resource).to be_persisted
        expect(response).to redirect_to edit_club_url(resource, page: 'main')
      end
    end

    context 'invalid params' do
      before { post :create, params: { club: params } }
      let(:params) { { owner_id: user.id } }

      it do
        expect(resource).to be_new_record
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#update' do
    include_context :authenticated, :user, :week_registered
    let(:club) { create :club, :with_topics, owner: user }

    context 'valid params' do
      before { patch :update, params: { id: club.id, club: params, page: 'description' } }
      let(:params) { { name: 'test club' } }

      it do
        expect(resource.errors).to be_empty
        expect(response).to redirect_to edit_club_url(resource, page: :description)
      end
    end

    context 'invalid params' do
      before { patch 'update', params: { id: club.id, club: params, page: 'description' } }
      let(:params) { { name: '' } }

      it do
        expect(resource.errors).to be_present
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#members' do
    let(:club) { create :club }
    before { get :members, params: { id: club.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#images' do
    let(:club) { create :club }
    before { get :images, params: { id: club.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#animes' do
    context 'without_animes' do
      before { get :animes, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_animes' do
      let(:club) { create :club, :with_topics, :linked_anime }
      before { get :animes, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#mangas' do
    context 'without_mangas' do
      before { get :mangas, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_mangas' do
      let(:club) { create :club, :with_topics, :linked_manga }
      before { get :mangas, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#characters' do
    context 'without_characters' do
      before { get :characters, params: { id: club.to_param } }
      it { expect(response).to redirect_to club_url(club) }
    end

    context 'with_characters' do
      let(:club) { create :club, :with_topics, :linked_character }
      before { get :characters, params: { id: club.to_param } }
      it { expect(response).to have_http_status :success }
    end
  end
end
