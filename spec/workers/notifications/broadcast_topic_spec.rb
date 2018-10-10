describe Notifications::BroadcastTopic do
  subject { described_class.new.perform topic }
  before do
    allow(Topics::SubscribedUsersQuery)
      .to receive(:call)
      .with(user)
      .and_return users
  end

  let(:users) { [user, user_2, user_3] }
  let(:user_2) { seed :user_day_registered }
  let(:user_3) { seed :user_week_registered }

  context 'expired topic' do
    let(:topic) { create :topic, created_at: described_class::NEWS_EXPIRE_IN.ago - 1.minute }

    it do
      expect { subject }.to_not change Message, :count
      expect(Topics::SubscribedUsersQuery).to_not have_received :call
      expect(topic).to be_processed
    end
  end

  context 'ignored topic' do
    let(:topic) { create :news_topic, linked: linked }
    let(:linked) do
      [
        nil,
        create(:anime, censored: true),
        create(:anime, kind: :music)
      ].sample
    end

    it do
      expect { subject }.to_not change Message, :count
      expect(Topics::SubscribedUsersQuery).to_not have_received :call
      expect(topic).to be_processed
    end
  end
end
