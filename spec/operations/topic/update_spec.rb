# frozen_string_literal: true

describe Topic::Update do
  include_context :timecop

  before do
    allow(Notifications::BroadcastTopic).to receive :perform_async
    allow_any_instance_of(Topic::BroadcastPolicy)
      .to receive(:required?)
      .and_return is_broadcast_required
  end

  subject! do
    described_class.call(
      topic: topic,
      params: params,
      faye: faye
    )
  end

  let(:faye) { FayeService.new user, nil }
  let(:topic) { create :topic }
  let(:is_broadcast_required) { false }

  context 'valid params' do
    let(:params) { { title: 'title', body: 'text' } }

    it do
      is_expected.to eq true
      expect(topic).to be_valid
      expect(topic).to_not be_changed

      expect(topic.reload).to have_attributes params
      expect(Notifications::BroadcastTopic).to_not have_received :perform_async
    end

    describe 'broadcast required' do
      let(:is_broadcast_required) { true }

      it do
        is_expected.to eq true
        expect(topic).to be_valid
        expect(Notifications::BroadcastTopic)
          .to have_received(:perform_async)
          .with topic
      end
    end
  end

  context 'invalid params' do
    let(:params) { { title: 'title', body: nil } }

    it do
      is_expected.to eq false
      expect(topic).to_not be_valid
      expect(topic).to be_changed

      expect(topic.reload).not_to have_attributes params
      expect(Notifications::BroadcastTopic).to_not have_received :perform_async
    end
  end
end
