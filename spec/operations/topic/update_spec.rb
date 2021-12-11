# frozen_string_literal: true

describe Topic::Update do
  include_context :timecop
  subject { described_class.call topic, params, faye }

  let(:faye) { FayeService.new user, nil }
  let(:topic) { create :topic, updated_at: 1.hour.ago }
  let(:is_broadcast_required) { false }

  before do
    allow(Notifications::BroadcastTopic).to receive :perform_in
    allow_any_instance_of(Topic::BroadcastPolicy)
      .to receive(:required?)
      .and_return is_broadcast_required
  end

  context 'valid params' do
    let(:params) { { title: 'title', body: 'text' } }

    it do
      is_expected.to eq true
      expect(topic).to be_valid
      expect(topic).to_not be_changed
      expect(topic.updated_at).to be_within(0.1).of Time.zone.now

      expect(topic.reload).to have_attributes params
      expect(Notifications::BroadcastTopic).to_not have_received :perform_in
    end

    describe 'broadcast required' do
      let(:is_broadcast_required) { true }

      it do
        is_expected.to eq true
        expect(topic).to be_valid
        expect(Notifications::BroadcastTopic)
          .to have_received(:perform_in)
          .with 10.seconds, topic.id
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
      expect(Notifications::BroadcastTopic).to_not have_received :perform_in
    end
  end
end
