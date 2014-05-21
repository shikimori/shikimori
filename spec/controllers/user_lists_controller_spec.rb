require 'spec_helper'

describe UserListsController do
  let(:user) { create :user }
  let!(:anime_1) { create :anime, name: 'Zombie-Loan' }
  let!(:anime_2) { create :anime, name: 'Zombie-Loan Specials' }

  before do
    sign_in user

    @list = [{
        id: anime_1.id,
        status: 1,
        score: 5.0,
        name: "Zombie-Loan Specials",
        episodes: 1
      }, {
        id: anime_2.id,
        status: 2,
        score: 5.0,
        name: "Zombie-Loan,.",
        episodes: 1
      }]
  end

  describe :export do
    before { get :export, id: user.to_param, list_type: 'anime' }
    it { should respond_with :success }
    it { should respond_with_content_type :xml }
  end

  describe :import do
    let(:rewrite) { false }

    context :mal, :focus do
      let!(:user_rate) { create :user_rate, user: user, target: anime_1 }
      before { post :list_import, id: user.to_param, klass: 'anime', rewrite: rewrite, list_type: :mal, data: @list.to_json }

      it { should redirect_to messages_url(type: :inbox) }
      it { expect(user.reload.anime_rates).to have(2).items }

      context :no_rewrite do
        let(:rewrite) { false }

        it { expect(assigns :added).to have(1).item }
        it { expect(assigns :updated).to be_empty }
      end

      context :rewrite do
        let(:rewrite) { true }

        it { expect(assigns :added).to have(1).item }
        it { expect(assigns :updated).to have(1).item }
      end
    end

    context :anime_planet do
      it 'works' do
        create :manga, name: "07 Ghost"
        create :manga, name: "20th Century Boys"

        expect {
          post :list_import, id: user.to_param, klass: 'manga', rewrite: true, list_type: :anime_planet, login: 'morr507'
        }.to change(UserRate, :count).by 2

        response.should redirect_to(messages_url(type: :inbox))
      end
    end

    context :xml do
      let(:manga1) { create :manga, name: "07 Ghost" }
      let(:manga2) { create :manga, name: "20th Century Boys" }

      let(:xml) {
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
