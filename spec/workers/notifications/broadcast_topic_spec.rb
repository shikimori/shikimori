describe Notifications::BroadcastTopic do
  subject(:messages) { described_class.new.perform topic.id }
  before do
    allow(Topics::SubscribedUsersQuery)
      .to receive(:call)
      .with(topic)
      .and_return users
  end

  let(:users) { [user, user_2, user_3] }
  let(:user_2) { seed :user_day_registered }
  let(:user_3) { seed :user_week_registered }

  let(:topic) do
    create topic_type,
      linked: linked,
      action: action,
      broadcast: is_broadcast,
      processed: is_processed,
      created_at: created_at
  end
  let(:topic_type) { :topic }
  let(:linked) { nil }
  let(:action) { nil }
  let(:is_broadcast) { true }
  let(:is_processed) { false }
  let(:created_at) { Time.zone.now }

  context 'broadcasted topic' do
    it do
      expect { subject }.to change(Message, :count).by users.count
      is_expected.to have(3).items
      expect(messages.first).to have_attributes(
        from: topic.user,
        body: nil,
        kind: MessageType::SiteNews,
        linked: topic
      )
      expect(messages.first.created_at).to be_within(0.1).of topic.created_at
      expect(messages.map(&:to).sort_by(&:id)).to eq users.sort_by(&:id)
      expect(topic.reload).to be_processed
    end
  end

  context 'anime news topic' do
    let(:topic_type) { :news_topic }
    let(:is_broadcast) { false }
    let(:linked) { create :anime }
    let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons] }

    it do
      expect { subject }.to change(Message, :count).by users.count
      is_expected.to have(3).items
      expect(messages.first).to have_attributes(
        from: topic.user,
        body: nil,
        kind: topic.action,
        linked: topic
      )
      expect(messages.first.created_at).to be_within(0.1).of topic.created_at
      expect(messages.map(&:to).sort_by(&:id)).to eq users.sort_by(&:id)
      expect(topic.reload).to be_processed
    end
  end

  context 'other news topic' do
    let(:topic_type) { :news_topic }
    let(:is_broadcast) { false }
    let(:linked) { create :anime }

    it do
      expect(-> {
        expect { subject }.to raise_error ArgumentError
      }).to_not change Message, :count
      expect(topic.reload).to_not be_processed
    end
  end

  context 'already processed topic' do
    let(:is_processed) { true }

    it do
      expect { subject }.to_not change Message, :count
      is_expected.to be_empty
      expect(Topics::SubscribedUsersQuery).to_not have_received :call
      expect(topic.reload).to be_processed
    end
  end

  context 'expired topic' do
    let(:topic_type) { :news_topic }
    let(:created_at) { described_class::NEWS_EXPIRE_IN.ago - 1.minute }
    let(:is_broadcast) { false }

    it do
      expect { subject }.to_not change Message, :count
      is_expected.to be_empty
      expect(Topics::SubscribedUsersQuery).to_not have_received :call
      expect(topic.reload).to be_processed
    end
  end

  context 'ignored topic' do
    let(:topic_type) { :news_topic }
    let(:is_broadcast) { false }
    let(:linked) do
      [
        create(:anime, censored: true),
        create(:anime, kind: :music)
      ].sample
    end

    it do
      expect { subject }.to_not change Message, :count
      is_expected.to be_empty
      expect(Topics::SubscribedUsersQuery).to_not have_received :call
      expect(topic.reload).to be_processed
    end
  end

  context 'missing topic' do
    let(:topic) { build_stubbed :topic }

    it do
      expect { subject }.to_not change Message, :count
      is_expected.to be_empty
      expect(Topics::SubscribedUsersQuery).to_not have_received :call
    end
  end
end
