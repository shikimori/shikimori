describe Topics::SubscribedUsersQuery do
  subject { described_class.call topic }
  before { User.update_all notification_settings: [] }

  context 'unsuitable topic' do
    let(:topic) { build :topic }
    it { is_expected.to eq [] }
  end

  context 'filtered by last_online_at' do
    let(:topic) { build :topic, broadcast: true }

    before { User.update_all last_online_at: last_online_at }
    let(:last_online_at) { Topics::SubscribedUsersQuery::ACTIVITY_INTERVAL.ago - 1.minute }
    let!(:user) { create :user }

    it { is_expected.to eq [user] }
  end

  context 'broadcast' do
    let(:topic) { build :topic, broadcast: true }
    it do
      is_expected.to eq(
        User
          .where('last_online_at > ?', Topics::SubscribedUsersQuery::ACTIVITY_INTERVAL.ago)
          .order(:id)
          .to_a
      )
    end
  end

  context 'contest news topic' do
    let(:topic) { build :topic, linked: contest }
    let(:contest) { build :contest }

    let(:user) { create :user, notification_settings: notification_settings }
    let(:notification_settings) { %i[contest_event] }

    it { is_expected.to eq [user] }
  end

  context 'news topic' do
    let(:topic) { build :news_topic, action: action, linked: anime }
    let(:anime) { create :anime }

    let(:user) { create :user, notification_settings: notification_settings }

    context 'anons' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons] }

      context 'any_anons' do
        let(:notification_settings) { %i[any_anons] }
        it { is_expected.to eq [user] }
      end

      context 'other notification_settings' do
        let(:notification_settings) do
          Types::User::NotificationSettings.values - %i[any_anons]
        end
        it { is_expected.to eq [] }
      end
    end

    context 'ongoing' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Ongoing] }

      context 'any_ongoing' do
        let(:notification_settings) { %i[any_ongoing] }
        it { is_expected.to eq [user] }
      end

      context 'my_ongoing' do
        let(:notification_settings) { %i[my_ongoing] }

        context 'has user_rate' do
          let!(:user_rate) { create :user_rate, status, user: user, target: anime }

          context 'not dropped' do
            let(:status) { (UserRate.statuses.keys - %w[dropped]).sample.to_sym }
            it { is_expected.to eq [user] }
          end

          context 'dropped' do
            let(:status) { :dropped }
            it { is_expected.to eq [] }
          end
        end

        context 'no user_rate' do
          let!(:user_rate_1) { create :user_rate, user: user, target: create(:anime) }
          let!(:user_rate_2) { create :user_rate, user: seed(:user_day_registered), target: anime }
          it { is_expected.to eq [] }
        end
      end

      context 'other notification_settings' do
        let(:notification_settings) do
          Types::User::NotificationSettings.values - %i[any_ongoing my_ongoing]
        end
        let!(:user_rate) { create :user_rate, user: user, target: anime }
        it { is_expected.to eq [] }
      end
    end

    context 'episode' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Episode] }

      context 'my_episode' do
        let(:notification_settings) { %i[my_episode] }

        context 'has user_rate' do
          let!(:user_rate) { create :user_rate, user: user, target: anime }
          it { is_expected.to eq [user] }
        end

        context 'no user_rate' do
          let!(:user_rate_1) { create :user_rate, user: user, target: create(:anime) }
          let!(:user_rate_2) { create :user_rate, user: seed(:user_day_registered), target: anime }
          it { is_expected.to eq [] }
        end
      end

      context 'other notification_settings' do
        let(:notification_settings) do
          Types::User::NotificationSettings.values - %i[my_episode]
        end
        let!(:user_rate) { create :user_rate, user: user, target: anime }
        it { is_expected.to eq [] }
      end
    end

    context 'released' do
      let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Released] }

      context 'any_released' do
        let(:notification_settings) { %i[any_released] }
        it { is_expected.to eq [user] }
      end

      context 'my_released' do
        let(:notification_settings) { %i[my_released] }

        context 'has user_rate' do
          let!(:user_rate) { create :user_rate, user: user, target: anime }
          it { is_expected.to eq [user] }
        end

        context 'no user_rate' do
          let!(:user_rate_1) { create :user_rate, user: user, target: create(:anime) }
          let!(:user_rate_2) { create :user_rate, user: seed(:user_day_registered), target: anime }
          it { is_expected.to eq [] }
        end
      end

      context 'other notification_settings' do
        let(:notification_settings) do
          Types::User::NotificationSettings.values - %i[any_released my_released]
        end
        let!(:user_rate) { create :user_rate, user: user, target: anime }
        it { is_expected.to eq [] }
      end
    end
  end
end
