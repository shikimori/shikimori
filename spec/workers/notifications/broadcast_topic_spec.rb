describe Notifications::BroadcastTopic do
  include_context :timecop
  subject { described_class.new.perform topic.id }

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

  before do
    allow(Notifications::SendMessages).to receive :perform_async
    stub_const 'Notifications::BroadcastTopic::MESSAGES_PER_JOB', messages_per_job
  end
  let(:messages_per_job) { 3 }

  context 'broadcasted topic' do
    let(:messages_per_job) { 2 }
    let(:message_attributes) do
      {
        'created_at' => topic.created_at.change(usec: 0), # usec is used to fix unstable specs in CIRCLE_CI
        'from_id' => topic.user_id,
        'kind' => MessageType::SITE_NEWS,
        'linked_id' => topic.id,
        'linked_type' => Topic.name
      }
    end

    it do
      is_expected.to eq true

      expect(Notifications::SendMessages)
        .to have_received(:perform_async)
        .with(message_attributes, [user.id, user_2.id])
        .ordered

      expect(Notifications::SendMessages)
        .to have_received(:perform_async)
        .with(message_attributes, [user_3.id])
        .ordered

      expect(Notifications::SendMessages)
        .to have_received(:perform_async)
        .twice

      expect(topic.reload).to be_processed
    end
  end

  context 'contest topic' do
    let(:topic_type) { :contest_status_topic }
    let(:linked) { create :contest }
    let(:is_broadcast) { false }
    let(:action) { :finished }
    let(:created_at) { 1.day.ago }

    let(:message_attributes) do
      {
        'created_at' => 1.day.ago.change(usec: 0), # usec is used to fix unstable specs in CIRCLE_CI
        'from_id' => topic.user_id,
        'kind' => MessageType::CONTEST_FINISHED,
        'linked_id' => linked.id,
        'linked_type' => Contest.name
      }
    end

    it do
      is_expected.to eq true

      expect(Notifications::SendMessages)
        .to have_received(:perform_async)
        .with(message_attributes, [user.id, user_2.id, user_3.id])
        .once

      expect(topic.reload).to be_processed
    end
  end

  context 'anime news topic' do
    let(:topic_type) { :news_topic }
    let(:is_broadcast) { false }
    let(:linked) { create :anime }
    let(:action) { Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons] }

    let(:message_attributes) do
      {
        'created_at' => topic.created_at.change(usec: 0), # usec is used to fix unstable specs in CIRCLE_CI
        'from_id' => topic.user_id,
        'kind' => Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons].to_s,
        'linked_id' => topic.id,
        'linked_type' => Topic.name
      }
    end

    it do
      is_expected.to eq true

      expect(Notifications::SendMessages)
        .to have_received(:perform_async)
        .with(message_attributes, [user.id, user_2.id, user_3.id])
        .once

      expect(topic.reload).to be_processed
    end
  end

  context 'other news topic' do
    let(:topic_type) { :news_topic }
    let(:is_broadcast) { false }
    let(:linked) { create :anime }

    it do
      expect { subject }.to raise_error ArgumentError
      expect(Notifications::SendMessages).to_not have_received :perform_async
      expect(topic.reload).to_not be_processed
    end
  end

  context 'already processed topic' do
    let(:is_processed) { true }

    it do
      is_expected.to be_nil
      expect(Notifications::SendMessages).to_not have_received :perform_async
      expect(topic.reload).to be_processed
    end
  end

  context 'expired topic' do
    let(:topic_type) { :news_topic }
    let(:created_at) { described_class::NEWS_EXPIRE_IN.ago - 1.minute }
    let(:is_broadcast) { false }

    it do
      is_expected.to be_nil
      expect(Notifications::SendMessages).to_not have_received :perform_async
      expect(topic.reload).to be_processed
    end
  end

  context 'ignored topic' do
    let(:topic_type) { :news_topic }
    let(:is_broadcast) { false }
    let(:linked) do
      [
        create(:anime, is_censored: true),
        create(:anime, kind: :music)
      ].sample
    end

    it do
      is_expected.to be_nil
      expect(Notifications::SendMessages).to_not have_received :perform_async
      expect(topic.reload).to be_processed
    end
  end

  context 'missing topic' do
    let(:topic) { build_stubbed :topic }

    it do
      is_expected.to be_nil
      expect(Notifications::SendMessages).to_not have_received :perform_async
    end
  end
end
