require 'spec_helper'

describe UserListsController do
  let(:user) { create :user }
  let!(:anime_1) { create :anime, name: 'Zombie-Loan' }
  let!(:anime_2) { create :anime, name: 'Zombie-Loan Specials' }

  before { sign_in user }

  describe :export do
    let!(:user_rate) { create :user_rate, user: user, target: anime_1 }
    before { get :export, id: user.to_param, list_type: 'anime' }
    it { should respond_with :success }
    it { should respond_with_content_type :xml }
  end

  describe :import do
    let(:rewrite) { false }

    context :mal do
      let(:list) {[
        { id: anime_1.id, status: 1, score: 5.0, name: "Zombie-Loan Specials", episodes: 1 },
        { id: anime_2.id, status: 2, score: 5.0, name: "Zombie-Loan,.", episodes: 1 }
      ]}

      let!(:user_rate) { create :user_rate, user: user, target: anime_1 }
      before { post :list_import, id: user.to_param, klass: 'anime', rewrite: rewrite, list_type: :mal, data: list.to_json }

      context :no_rewrite do
        let(:rewrite) { false }

        it 'imports data' do
          should redirect_to messages_url(type: :inbox)
          expect(user.reload.anime_rates).to have(2).items
          expect(assigns :added).to have(1).item
          expect(assigns :updated).to be_empty
        end
      end

      context :rewrite do
        let(:rewrite) { true }

        it 'imports data' do
          should redirect_to messages_url(type: :inbox)
          expect(user.reload.anime_rates).to have(2).items
          expect(assigns :added).to have(1).item
          expect(assigns :updated).to have(1).item
        end
      end
    end

    context :anime_planet do
      let!(:anime_1) { create :anime, name: 'Black Bullet' }
      let!(:anime_2) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2007-01-01') }
      let!(:anime_3) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2008-01-01') }

      before { post :list_import, id: user.to_param, klass: 'anime', rewrite: true, list_type: :anime_planet, login: 'shikitest' }

      it 'imports data' do
        should redirect_to messages_url(type: :inbox)
        expect(user.reload.anime_rates).to have(2).items

        expect(assigns :added).to have(2).items
        expect(assigns :updated).to have(0).items
        expect(assigns :not_imported).to have(4).items
      end
    end

    context :xml do
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
      before { post :list_import, id: user.to_param, klass: 'manga', rewrite: true, list_type: :xml, file: xml }

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
