describe Topics::SubscribedUsersQuery do
  subject { described_class.call topic }
  before { User.update_all notification_settings: [] }

  context 'unsuitable topic' do
    let(:topic) { build :topic }
    it { is_expected.to eq [] }
  end

  context 'broadcast' do
    let(:topic) { build :topic, broadcast: true }
    it { is_expected.to eq User.all }
  end

  context 'news topic' do
    let(:topic) { build :news_topic, action: action, linked: anime }
    let(:anime) { create :anime }

    let(:user_1) { create :user, notification_settings: notification_settings }
    let(:user_rate_1) { create :user_rate, user: user_1, target: anime }

    context 'anons' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons] }
      let(:notification_settings) { %i[any_anons] }

      it { is_expected.to eq [user_1] }

      context 'no notification_settings' do
        let(:notification_settings) { Types::User::NotificationSettings.values - %i[any_anons] }
        it { is_expected.to eq [] }
      end
    end

    context 'ongoing' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Ongoing] }
      # let(:notification_settings) { %i[any_anons] }

      # context 'no user_rate' do
      #   let(:user_rate_1) { nil }
      #   it { is_expected.to eq [] }
      # end

    end

    context 'episode' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Episode] }
    end

    context 'released' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Released] }
    end
  end
end
