require 'spec_helper'

describe UserListsController do
  let (:user) { create :user }

  before (:each) do
    sign_in user

    @anime1 = create :anime, name: "Zombie-Loan"
    @anime2 = create :anime, name: "Zombie-Loan Specials"

    @list = [{
        id: @anime1.id,
        status: 1,
        score: 5.0,
        name: "Zombie-Loan Specials",
        episodes: 1
      }, {
        id: @anime2.id,
        status: 2,
        score: 5.0,
        name: "Zombie-Loan,.",
        episodes: 1
      }]
  end

  describe 'import' do
    describe 'mal' do
      it 'works' do
        expect {
          post :list_import, id: user.to_param, klass: 'anime', rewrite: false, list_type: :mal, data: @list.to_json
        }.to change(UserRate, :count).by @list.size

        response.should redirect_to(messages_url(type: :inbox))
      end
    end

    it 'with rewrite' do
      create :user_rate, user: user, target: @anime1
      expect {
        post :list_import, id: user.to_param, klass: 'anime', rewrite: true, list_type: :mal, data: @list.to_json
      }.to change(UserRate, :count).by 1

      response.should redirect_to(messages_url(type: :inbox))
    end

    describe 'anime-planet' do
      it 'works' do
        create :manga, name: "07 Ghost"
        create :manga, name: "20th Century Boys"

        expect {
          post :list_import, id: user.to_param, klass: 'manga', rewrite: true, list_type: :anime_planet, login: 'morr507'
        }.to change(UserRate, :count).by 2

        response.should redirect_to(messages_url(type: :inbox))
      end
    end

    describe 'xml' do
      let (:manga1) { create :manga, name: "07 Ghost" }
      let (:manga2) { create :manga, name: "20th Century Boys" }

      let (:xml) {
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserListsController::MangaType}</user_export_type>
  </myinfo>
  <manga>
    <manga_mangadb_id>#{manga1.id}</manga_mangadb_id>
    <my_read_volumes>0</my_read_volumes>
    <my_read_chapters>0</my_read_chapters>
    <my_score></my_score>
    <my_status>Plan to Read</my_status>
    <update_on_import>1</update_on_import>
  </manga>
  <manga>
    <manga_mangadb_id>#{manga2.id}</manga_mangadb_id>
    <my_watched_episodes>0</my_watched_episodes>
    <my_score></my_score>
    <my_status>Plan to Read</my_status>
    <update_on_import>1</update_on_import>
  </manga>
</myanimelist>"
      }

      it 'works' do
        expect {
          post :list_import, id: user.to_param, klass: 'manga', rewrite: true, list_type: :xml, file: xml
        }.to change(UserRate, :count).by 2

        response.should redirect_to(messages_url(type: :inbox))
      end
    end
  end
end
