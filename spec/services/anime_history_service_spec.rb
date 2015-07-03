describe AnimeHistoryService do
  let!(:users) { create_list :user, 2, notifications: 0xFFFFFF }

  describe 'creates Message' do
    it 'for Topic width broadcast: true' do
      create :topic, user: users.last, broadcast: true
      expect{AnimeHistoryService.process}.to change(Message, :count).by User.count
    end

    it 'for new Anonsed Anime' do
      create :anime, :with_callbacks, status: :anons
      expect{AnimeHistoryService.process}.to change(Message, :count).by users.size
    end

    it 'for Episode of in-list anime' do
      anime = create :anime, status: :ongoing
      AnimeHistoryService.process
      create :user_rate, user: users.first, target: anime
      create :anime_news, action: AnimeHistoryAction::Episode, generated: true, linked: anime, user: users.first

      expect{AnimeHistoryService.process}.to change(Message, :count).by 1
    end
  end

  describe "doesn't create Message" do
    it 'for old news' do
      create :topic, user: users.last, broadcast: true, created_at: DateTime.now - AnimeHistoryService::NewsExpireIn - 1.day
      expect{AnimeHistoryService.process}.to_not change Message, :count
    end

    it 'for Topic width broadcast: false' do
      create :topic, user: users.last, broadcast: false
      expect{AnimeHistoryService.process}.to_not change Message, :count
    end

    it 'for censored anime' do
      create :anime, status: :anons, censored: true
      expect{AnimeHistoryService.process}.to_not change Message, :count
    end

    it 'for music anime' do
      create :anime, status: :anons, kind: 'music'
      expect{AnimeHistoryService.process}.to_not change Message, :count
    end

    it 'for Episode of not-in-list anime' do
      anime = create :anime, status: :ongoing
      AnimeHistoryService.process
      create :anime_news, action: AnimeHistoryAction::Episode, generated: true, linked: anime

      expect{AnimeHistoryService.process}.to_not change Message, :count
    end

    it 'for Episode of in-list dropped anime' do
      anime = create :anime, status: :ongoing
      AnimeHistoryService.process
      create :user_rate, :dropped, user: users.first, target: anime
      create :anime_news, action: AnimeHistoryAction::Episode, generated: true, linked: anime

      expect{AnimeHistoryService.process}.to change(Message, :count).by 0
    end
  end
end
