describe HistoryWorker do
  subject { HistoryWorker.new.perform }
  let!(:users) { create_list :user, 2, notifications: 0xFFFFFF }

  describe 'creates Message' do
    before { allow(PushNotification).to receive :perform_async }

    it 'for Topic width broadcast: true' do
      create :topic, user: users.last, broadcast: true
      expect{subject}.to change(Message, :count).by User.count
      expect(PushNotification).to_not have_received :perform_async
    end

    it 'for announced anime' do
      create :anime, :with_callbacks, :anons
      expect{subject}.to change(Message, :count).by users.size
      expect(PushNotification).to_not have_received :perform_async
    end

    it 'for Episode of in-list anime' do
      anime = create :anime, status: :ongoing
      HistoryWorker.new.perform
      create :user_rate, user: users.first, target: anime
      create :news_topic, action: AnimeHistoryAction::Episode, generated: true, linked: anime, user: users.first

      expect{subject}.to change(Message, :count).by 1
      expect(PushNotification).to_not have_received :perform_async
    end

    context 'user with device' do
      let!(:user) { create :user, notifications: 0xFFFFFF }
      let!(:device) { create :device, user: user }
      let!(:anime) { create :anime, :with_callbacks, :anons }
      before { subject }

      it { expect(PushNotification).to have_received(:perform_async).once }
    end
  end

  describe "doesn't create Message" do
    it 'for old news' do
      create :topic, user: users.last, broadcast: true, created_at: HistoryWorker::NEWS_EXPIRE_IN.ago - 1.day
      expect{subject}.to_not change Message, :count
    end

    it 'for Topic width broadcast: false' do
      create :topic, user: users.last, broadcast: false
      expect{subject}.to_not change Message, :count
    end

    it 'for censored anime' do
      create :anime, status: :anons, censored: true
      expect{subject}.to_not change Message, :count
    end

    it 'for music anime' do
      create :anime, status: :anons, kind: 'music'
      expect{subject}.to_not change Message, :count
    end

    it 'for Episode of not-in-list anime' do
      anime = create :anime, status: :ongoing
      subject
      create :news_topic, action: AnimeHistoryAction::Episode, generated: true, linked: anime

      expect{subject}.to_not change Message, :count
    end

    it 'for Episode of in-list dropped anime' do
      anime = create :anime, status: :ongoing
      subject
      create :user_rate, :dropped, user: users.first, target: anime
      create :news_topic, action: AnimeHistoryAction::Episode, generated: true, linked: anime

      expect{subject}.to change(Message, :count).by 0
    end
  end
end
