# frozen_string_literal: true

describe Topic::Update do
  include_context :timecop

  before { allow(Notifications::BroadcastTopic).to receive :perform_async }
  subject! do
    described_class.call(
      topic: topic,
      params: params,
      faye: faye
    )
  end

  let(:faye) { FayeService.new user, nil }
  let(:topic) { create :topic }

  context 'valid params' do
    let(:params) { { title: 'title', body: 'text' } }
    it do
      expect(topic).to be_valid
      expect(topic).to_not be_changed

      expect(topic.reload).to have_attributes params
      expect(topic.commented_at).to be_within(0.1).of(Time.zone.now)
      expect(Notifications::BroadcastTopic).to_not have_received :perform_async
    end

    describe 'broadcast' do
      let(:params) { { broadcast: true } }

      it do
        expect(topic.reload).to have_attributes params
        expect(Notifications::BroadcastTopic).to have_received(:perform_async).with topic
      end

      context 'not broadcast change' do
        let(:topic) { create :topic, broadcast: true }
        let(:params) { { broadcast: false } }

        it do
          expect(topic.reload).to have_attributes params
          expect(Notifications::BroadcastTopic).to_not have_received :perform_async
        end
      end

      context 'already processed topic' do
        let(:topic) { create :topic, processed: true }

        it do
          expect(topic.reload).to have_attributes params
          expect(Notifications::BroadcastTopic).to_not have_received :perform_async
        end
      end
    end
  end

  context 'invalid params' do
    let(:params) { { title: 'title', body: nil } }

    it do
      expect(topic).to_not be_valid
      expect(topic).to be_changed

      expect(topic.reload).not_to have_attributes params
      expect(topic.commented_at).to be_nil
      expect(Notifications::BroadcastTopic).to_not have_received :perform_async
    end
  end
end
