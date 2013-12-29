require 'spec_helper'

describe CharactersController do
  let(:entry) { create :character, name: 'test' }
  let(:user) { create :user }
  let(:json) { JSON.parse response.body }
  before do
    1.upto(11) do
      create :character, name: 'test2'
    end
    create :anime, characters: [entry]
    create :anime, characters: [entry]
    create :character
  end

  describe :index do
    describe 'html' do
      before { get :index, search: 'test', format: :html }

      it { should respond_with 200 }
      it { should respond_with_content_type :html }

      it { assigns(:people).should have(10).items }
      it { assigns(:people).first.best_works.should have(3).items }
    end

    describe :json do
      before { get :index, search: 'test', format: :json }

      it { should respond_with 200 }
      it { should respond_with_content_type :json }
      it { json.should have_key 'content' }
    end
  end

  describe :show do
    it_should_behave_like :entry_show do
      before { create :favourite, user: user, linked: entry, kind: Favourite::Mangaka }
    end

    context 'sort: time' do
      before { get :show, id: entry.to_param, sort: 'time', page: 'info' }

      it { should respond_with 200 }
    end

  end

  describe :page do
    it_should_behave_like :entry_page, :comments

    it_should_behave_like :entry_page, :cosplay do
      before do
        create :cosplay_gallery, links: [
          create(:cosplay_gallery_link, linked: entry),
          create(:cosplay_gallery_link, linked: create(:cosplayer))
        ]
      end
    end

    it_should_behave_like :entry_page, :images do
      before { create :attached_image, owner: entry }
    end
  end

  describe :edit do
    it_should_behave_like :entry_edit, :russian
    it_should_behave_like :entry_edit, :description
  end

  describe :tooltip do
    context 'to_param' do
      before { get :tooltip, id: entry.to_param }

      it { should respond_with 200 }
      it { should respond_with_content_type :html }
    end

    context 'id' do
      before { get :tooltip, id: entry.id }
      it { should redirect_to character_tooltip_url(entry) }
    end
  end

  describe :autocomplete do
    before do
      create :character, name: 'Fffff'
      create :character, name: 'zzz Ffff'
      get :autocomplete, search: 'Fff', format: 'json'
    end

    it { should respond_with 200 }
    it { should respond_with_content_type :json }

    describe 'json' do
      it { json.should have(2).items }
      it { json.first.should have_key 'data' }
      it { json.first.should have_key 'value' }
      it { json.first.should have_key 'label' }
    end
  end
end
