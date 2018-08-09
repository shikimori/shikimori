# frozen_string_literal: true

describe Topic::Update do
  include_context :timecop

  subject { Topic::Update.call topic, params, faye }

  let(:faye) { FayeService.new user, nil }
  let(:topic) { create :topic }

  before { subject }

  context 'valid params' do
    let(:params) { { title: 'title', body: 'text' } }
    it do
      expect(topic.errors).to be_empty
      expect(topic.reload).to have_attributes params
      expect(topic.commented_at).to be_within(0.1).of(Time.zone.now)
    end
  end

  context 'invalid params' do
    let(:params) { { title: 'title', body: nil } }

    it do
      expect(topic.errors).to have(1).item
      expect(topic.reload).not_to have_attributes params
      expect(topic.commented_at).to be_nil
    end
  end
end
