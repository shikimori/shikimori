require 'spec_helper'

describe AnimeHistoryService do
  let!(:users) { create_list :user, 2, notifications: 0xFFFFFF }

  def process
    AnimeHistoryService.process
  end

  describe 'creates Message' do
    it 'for Topic width broadcast: true' do
      create :topic, user: users.last, broadcast: true
      expect{process}.to change(Message, :count).by User.count
    end

    it 'for new Anonsed Anime' do
      create :anime, :with_callbacks, status: AniMangaStatus::Anons
      expect{process}.to change(Message, :count).by users.size
    end

    it 'for Episode of in-list anime' do
      anime = create :anime, status: AniMangaStatus::Ongoing
      process
      create :user_rate, user: users.first, target: anime
      create :anime_news, action: AnimeHistoryAction::Episode, generated: true, linked: anime, user: users.first

      expect{process}.to change(Message, :count).by 1
    end
  end

  describe "doesn't create Message" do
    it 'for old news' do
      create :topic, user: users.last, broadcast: true, created_at: DateTime.now - AnimeHistoryService::NewsExpireIn - 1.day
      expect{process}.to_not change Message, :count
    end

    it 'for Topic width broadcast: false' do
      create :topic, user: users.last, broadcast: false
      expect{process}.to_not change Message, :count
    end

    it 'for censored anime' do
      create :anime, status: AniMangaStatus::Anons, censored: true
      expect{process}.to_not change Message, :count
    end

    it 'for music anime' do
      create :anime, status: AniMangaStatus::Anons, kind: 'Music'
      expect{process}.to_not change Message, :count
    end

    it 'for Episode of not-in-list anime' do
      anime = create :anime, status: AniMangaStatus::Ongoing
      process
      create :anime_news, action: AnimeHistoryAction::Episode, generated: true, linked: anime

      expect{process}.to_not change Message, :count
    end

    it 'for Episode of in-list dropped anime' do
      anime = create :anime, status: AniMangaStatus::Ongoing
      process
      create :user_rate, :dropped, user: users.first, target: anime
      create :anime_news, action: AnimeHistoryAction::Episode, generated: true, linked: anime

      expect{process}.to change(Message, :count).by 0
    end
  end
end
