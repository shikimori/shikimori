require 'spec_helper'

describe UserRatesController do
  include_context :authenticated

  describe '#index' do
    let!(:user_rate) { create :user_rate, user: user }
    let(:make_request) { get :index, profile_id: user.to_param, list_type: 'anime' }

    context 'has access to list' do
      before { make_request }
      it { should respond_with :success }
    end

    context 'has no access to list' do
      let(:user) { create :user, preferences: create(:user_preferences, profile_privacy: :owner) }
      before { sign_out user }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#edit' do
    let(:user_rate) { create :user_rate, user: user }
    before { get :edit, id: user_rate.id }

    it { should respond_with :success }
  end

  describe '#destroy' do
    let(:user_rate) { create :user_rate, user: user }
    before { delete :destroy, id: user_rate.id, format: :json }

    it { should respond_with :success }
    it { expect(assigns(:user_rate)).to be_destroyed }
  end

  describe '#create' do
    let(:target) { create :anime }
    let(:create_params) {{ user_id: user.id, target_id: target.id, target_type: target.class.name, score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
    before { post :create, user_rate: create_params, format: :json }

    it { should respond_with :success }

    describe 'user_rate' do
      subject { assigns :user_rate }

      its(:user_id) { should eq create_params[:user_id] }
      its(:target_id) { should eq create_params[:target_id] }
      its(:target_type) { should eq create_params[:target_type] }
      its(:score) { should eq create_params[:score] }
      its([:status]) { should eq create_params[:status] }
      its(:episodes) { should eq create_params[:episodes] }
      its(:volumes) { should eq create_params[:volumes] }
      its(:chapters) { should eq create_params[:chapters] }
      its(:text) { should eq create_params[:text] }
      its(:rewatches) { should eq create_params[:rewatches] }
    end
  end

  describe '#increment' do
    let(:user_rate) { create :user_rate, user: user, episodes: 1 }
    before { post :increment, id: user_rate.id, format: :json }

    it { should respond_with :success }

    describe 'user_rate' do
      subject { assigns :user_rate }
      its(:episodes) { should eq user_rate.episodes + 1 }
    end
  end

  describe '#export' do
    let(:make_request) { get :export, profile_id: user.to_param, list_type: 'anime', format: 'xml' }
    let!(:user_rate) { create :user_rate, user: user, target: create(:anime) }

    context 'has access' do
      before { make_request }
      it { should respond_with :success }
      it { should respond_with_content_type :xml }
    end

    context 'has no access' do
      let(:user) { create :user, preferences: create(:user_preferences, profile_privacy: :owner) }
      before { sign_out user }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#import' do
    let(:rewrite) { false }
    let!(:anime_1) { create :anime, name: 'Zombie-Loan' }
    let!(:anime_2) { create :anime, name: 'Zombie-Loan Specials' }

    context 'has no access' do
      let(:user) { create :user, preferences: create(:user_preferences, profile_privacy: :owner) }
      before { sign_out user }
      it { expect{post :import, profile_id: user.to_param}.to raise_error CanCan::AccessDenied }
    end

    context 'mal' do
      let(:list) {[
        { id: anime_1.id, status: 1, score: 5.0, name: "Zombie-Loan Specials", episodes: 1 },
        { id: anime_2.id, status: 2, score: 5.0, name: "Zombie-Loan,.", episodes: 1 }
      ]}

      let!(:user_rate) { create :user_rate, user: user, target: anime_1 }
      before { post :import, profile_id: user.to_param, klass: 'anime', rewrite: rewrite, list_type: :mal, data: list.to_json }

      context 'no rewrite' do
        let(:rewrite) { false }

        it 'imports data' do
          should redirect_to messages_url(type: :inbox)
          expect(user.reload.anime_rates).to have(2).items
          expect(assigns :added).to have(1).item
          expect(assigns :updated).to be_empty
        end
      end

      context 'rewrite' do
        let(:rewrite) { true }

        it 'imports data' do
          should redirect_to messages_url(type: :inbox)
          expect(user.reload.anime_rates).to have(2).items
          expect(assigns :added).to have(1).item
          expect(assigns :updated).to have(1).item
        end
      end
    end

    context 'anime_planet', vcr: { cassette_name: 'anime_planet_import' } do
      let!(:anime_1) { create :anime, name: 'Black Bullet' }
      let!(:anime_2) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2007-01-01') }
      let!(:anime_3) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2008-01-01') }

      before { post :import, profile_id: user.to_param, klass: 'anime', rewrite: true, list_type: :anime_planet, login: 'shikitest' }

      it 'imports data' do
        should redirect_to messages_url(type: :inbox)
        expect(user.reload.anime_rates).to have(2).items

        expect(assigns :added).to have(2).items
        expect(assigns :updated).to have(0).items
        expect(assigns :not_imported).to have(4).items
      end
    end

    context 'xml' do
      let(:manga_1) { create :manga, name: "07 Ghost" }

      let(:xml) {
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserListsController::MangaType}</user_export_type>
  </myinfo>
  <manga>
    <manga_mangadb_id>#{manga_1.id}</manga_mangadb_id>
    <my_read_volumes>0</my_read_volumes>
    <my_read_chapters>0</my_read_chapters>
    <my_score></my_score>
    <my_status>Plan to Read</my_status>
    <update_on_import>1</update_on_import>
  </manga>
  <manga>
    <manga_mangadb_id>1234</manga_mangadb_id>
    <my_watched_episodes>0</my_watched_episodes>
    <my_score></my_score>
    <my_status>Reading</my_status>
    <update_on_import>1</update_on_import>
  </manga>
</myanimelist>"
      }
      before { post :import, profile_id: user.to_param, klass: 'manga', rewrite: true, list_type: :xml, file: xml }

      it 'imports data' do
        should redirect_to messages_url(type: :inbox)
        expect(user.reload.manga_rates).to have(1).item

        expect(assigns :added).to have(1).item
        expect(assigns :updated).to have(0).items
        expect(assigns :not_imported).to have(1).item
      end
    end
  end
end
