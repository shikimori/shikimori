describe UserRatesController do
  include_context :authenticated, :user

  describe '#index' do
    let!(:user_rate) { create :user_rate, user: user }
    let(:make_request) { get :index, profile_id: user.to_param, list_type: 'anime' }

    context 'has access to list' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'has no access to list' do
      let(:user) { create :user, preferences: create(:user_preferences, list_privacy: :owner) }
      before { sign_out user }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#export' do
    let(:make_request) { get :export, profile_id: user.to_param, list_type: 'anime', format: 'xml' }
    let!(:user_rate) { create :user_rate, user: user, target: create(:anime) }

    context 'has access' do
      before { make_request }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/xml'
      end
    end

    context 'has no access' do
      let(:user) { create :user, preferences: create(:user_preferences, list_privacy: :owner) }
      before { sign_out user }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#import' do
    let(:rewrite) { false }
    let!(:anime_1) { create :anime, name: 'Zombie-Loan' }
    let!(:anime_2) { create :anime, name: 'Zombie-Loan Specials' }

    context 'has no access' do
      let(:user) { create :user, preferences: create(:user_preferences, list_privacy: :owner) }
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
          expect(response).to redirect_to index_profile_messages_url(user, :notifications)
          expect(user.reload.anime_rates.size).to eq(2)
          expect(assigns(:added).size).to eq(1)
          expect(assigns :updated).to be_empty
        end
      end

      context 'rewrite' do
        let(:rewrite) { true }

        it 'imports data' do
          expect(response).to redirect_to index_profile_messages_url(user, :notifications)
          expect(user.reload.anime_rates.size).to eq(2)
          expect(assigns(:added).size).to eq(1)
          expect(assigns(:updated).size).to eq(1)
        end
      end
    end

    # context 'anime_planet', vcr: { cassette_name: 'anime_planet_import' } do
      # let!(:anime_1) { create :anime, name: 'Black Bullet' }
      # let!(:anime_2) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2007-01-01') }
      # let!(:anime_3) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2008-01-01') }
      # let!(:anime_4) { create :anime, name: 'Naruto: Shippuuden' }

      # let(:import_params) {{
        # profile_id: user.to_param,
        # klass: 'anime',
        # rewrite: true,
        # list_type: :anime_planet,
        # wont_watch_strategy: 'dropped',
        # login: 'shikitest'
      # }}

      # before { NameMatches::Refresh.new.perform Anime.name }
      # before { post :import, import_params }

      # it 'imports data' do
        # expect(response).to redirect_to index_profile_messages_url(user, :notifications)
        # expect(user.reload.anime_rates.size).to eq(3)

        # expect(assigns(:added).size).to eq(3)
        # expect(assigns(:updated).size).to eq(0)
        # expect(assigns(:not_imported).size).to eq(3)
      # end
    # end

    context 'xml' do
      let(:manga_1) { create :manga, name: "07 Ghost" }

      let(:xml) {
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserRatesImporter::MangaType}</user_export_type>
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
        expect(response).to redirect_to index_profile_messages_url(user, :notifications)
        expect(user.reload.manga_rates.size).to eq(1)

        expect(assigns(:added).size).to eq(1)
        expect(assigns(:updated).size).to eq(0)
        expect(assigns(:not_imported).size).to eq(1)
      end
    end
  end
end
