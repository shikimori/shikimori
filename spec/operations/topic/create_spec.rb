# frozen_string_literal: true

describe Topic::Create do
  before { allow(Notifications::BroadcastTopic).to receive :perform_async }
  subject!(:topic) do
    described_class.call(
      faye: faye,
      params: params,
      locale: locale
    )
  end

  let(:faye) { FayeService.new user, nil }
  let(:locale) { :en }

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text',
        broadcast: broadcast,
        type: type,
        generated: generated
      }
    end
    let(:broadcast) { nil }
    let(:type) { nil }
    let(:generated) { nil }

    it do
      is_expected.to be_persisted
      is_expected.to have_attributes params.merge(locale: locale.to_s)
      expect(Notifications::BroadcastTopic).to_not have_received :perform_async
    end

    describe 'broadcast' do
      context 'broadcast' do
        let(:broadcast) { true }

        it do
          is_expected.to be_persisted
          expect(Notifications::BroadcastTopic).to have_received(:perform_async).with topic
        end
      end

      context 'generated news topic' do
        let(:type) { Topics::NewsTopic.name }
        let(:generated) { true }

        it do
          is_expected.to be_persisted
          expect(Notifications::BroadcastTopic).to have_received(:perform_async).with topic
        end
      end

      context 'news topic' do
        let(:type) { Topics::NewsTopic.name }

        it do
          is_expected.to be_persisted
          expect(Notifications::BroadcastTopic).to_not have_received :perform_async
        end
      end

      context 'generated' do
        let(:generated) { true }

        it do
          is_expected.to be_persisted
          expect(Notifications::BroadcastTopic).to_not have_received :perform_async
        end
      end
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text'
      }
    end

    it do
      is_expected.to be_new_record
      is_expected.to have_attributes params.merge(locale: locale.to_s)
      expect(topic.errors).to be_present
      expect(Notifications::BroadcastTopic).to_not have_received :perform_async
    end
  end
end
