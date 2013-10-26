require 'spec_helper'
[:anime, :manga].each do |type|
#[:anime].each do |type|
  controller = "#{type.to_s.pluralize.capitalize}Controller".constantize

  describe controller do
    let(:user) { create :user }
    let(:entry) { create type, :with_thread }
    let(:character) { create :character }
    let(:person) { create :person }

    before do
      create(:section, id: AniMangaEntry::SectionIDs[type.to_s.capitalize], name: 'a') if Section.find_by_name('a').nil?
    end
    let(:json) { JSON.parse response.body }
    let(:entry_url) { entry.class == Anime ? anime_url(entry) : manga_url(entry) }

    describe :show do
      it_should_behave_like :entry_show do
        before do
          create(:attached_image, owner: character) if page == 'images'
          create :cosplay_gallery, links: [
              create(:cosplay_gallery_link, linked: character),
              create(:cosplay_gallery_link, linked: create(:cosplayer))
            ]
          entry.characters << character
          entry.person_roles << create(:person_role, person: person, role: 'Director')
          create :comment, commentable: entry.thread
          create :comment, commentable: entry.thread
          create :comment, commentable: entry.thread, review: true

          create :review, target: entry, user: user

          entry.related << create("related_#{type}", type => create(type))
          create :favourite, user: user, linked: entry, kind: Favourite::Mangaka
        end
      end
    end

    describe :page do
      it_should_behave_like :entry_page, :similar do
        before { create "similar_#{type}", src: entry, dst: create(type) }
      end

      it_should_behave_like :entry_page, :characters do
        before do
          create :person_role, character: character, role: 'Main', type => entry
          create :person_role, character: character, role: 'Other', type => entry
          create :person_role, person: person, role: 'Director', type => entry
        end
      end

      it_should_behave_like :entry_page, :stats do
        before do
          user2 = create :user, id: User::GuestID
          create :friend_link, src: user, dst: user2
          create :user_rate, user: user2, target: entry
        end
      end

      it_should_behave_like :entry_page, :recent

      it_should_behave_like :entry_page, :images do
        before { create :attached_image, owner: entry }
      end

      if type != :manga
        it_should_behave_like :entry_page, :videos do
          before { create :video, anime: entry, state: 'confirmed', uploader: create(:user) }
        end

        it_should_behave_like :entry_page, :screenshots do
          before { create :screenshot, anime_id: entry.id }
        end

        it_should_behave_like :entry_page, :files
      end

      it_should_behave_like :entry_page, :chronology do
        before { create "related_#{type}", type => create(type), source_id: entry.id }
      end
    end

    describe :cosplay do
      before do
        create :cosplay_gallery, links: [
            create(:cosplay_gallery_link, linked: character),
            create(:cosplay_gallery_link, linked: create(:cosplayer))
          ]
        entry.characters << character
      end

      context 'one character' do
        before { get :cosplay, id: entry.to_param, page: 'cosplay', character: character.to_param }
        it { should respond_with 200 }
        it { should respond_with_content_type :html }
      end

      context 'full gallery' do
        before { get :cosplay, id: entry.to_param, page: 'cosplay', character: 'all' }
        it { should respond_with 200 }
        it { should respond_with_content_type :html }
      end
    end if type != :manga

    describe :edit do
      it_should_behave_like :entry_edit, :russian
      it_should_behave_like :entry_edit, :description
      if type != :manga
        it_should_behave_like :entry_edit, :torrents_name
        it_should_behave_like :entry_edit, :screenshot
        it_should_behave_like :entry_edit, :videos
      end
    end

    describe :related_all do
      before { entry.related << create("related_#{type}", type => create(type)) }

      context 'to_param' do
        before { get :related_all, id: entry.to_param }
        it { should respond_with 200 }
        it { should respond_with_content_type :html }
      end

      context 'id' do
        before { get :related_all, id: entry.id }
        it { should redirect_to entry_url }
      end
    end

    describe :tooltip do
      let(:entry_tooltip_url) { entry.class == Anime ? tooltip_anime_url(entry) : tooltip_manga_url(entry) }

      context 'to_param' do
        before { get :tooltip, id: entry.to_param }
        it { should respond_with 200 }
        it { should respond_with_content_type :html }
      end

      context 'id' do
        before { get :tooltip, id: entry.id }
        it { should redirect_to entry_tooltip_url }
      end
    end

    describe :other_names do
      before { get :other_names, id: entry.id }
      it { should respond_with 200 }
    end

    describe :episode_torrents do
      before { get :episode_torrents, id: entry.id }
      it { should respond_with 200 }
      it { should respond_with_content_type :json }
    end if type != :manga

    describe 'autocomplete' do
      before do
        create type, name: 'Fffff'
        create type, name: 'zzz Ffff'
        create type, name: 'Ffff'
        create type, name: 'zzz'
        get :autocomplete, search: 'Fff', format: 'json'
      end

      it { should respond_with 200 }
      it { should respond_with_content_type :json }

      describe 'json' do
        it { json.should have(3).items }
        it { json.first.should have_key 'data' }
        it { json.first.should have_key 'value' }
        it { json.first.should have_key 'label' }
      end
    end
  end
end
