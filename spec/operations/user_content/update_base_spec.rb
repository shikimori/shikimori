# frozen_string_literal: true

class TestUpdate < UserContent::UpdateBase
  klass Article
  is_publishable true
end

describe UserContent::UpdateBase do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject { TestUpdate.call model, params, user }

  let(:model) { create :article, user: user, created_at: 1.day.ago }
  let!(:topic) do
    create :article_topic, linked: model, forum_id: Forum::HIDDEN_ID
  end

  context 'valid params' do
    let(:params) do
      {
        name: 'test article',
        state: state
      }
    end
    let(:state) { 'unpublished' }

    it do
      is_expected.to eq true
      expect(model).to_not be_changed
      expect(model.errors).to be_empty
      expect(model.reload).to have_attributes params
      expect(model.created_at).to be_within(0.1).of 1.day.ago
      expect(model.changed_at).to be_within(0.1).of Time.zone.now

      expect(model.topic).to have_attributes(
        id: topic.id,
        forum_id: Forum::HIDDEN_ID
      )
    end

    describe 'publish' do
      let(:state) { 'published' }

      it do
        is_expected.to eq true
        expect(model).to_not be_changed
        expect(model.errors).to be_empty
        expect(model.reload).to have_attributes params
        expect(model.created_at).to be_within(0.1).of Time.zone.now
        expect(model.changed_at).to be_within(0.1).of Time.zone.now

        expect(model.topic).to be_present
        expect(model.topic).to have_attributes(
          id: topic.id,
          forum_id: Topic::FORUM_IDS['Article']
        )
        expect(model.topic.created_at).to be_within(0.1).of Time.zone.now
      end
    end
  end

  context 'invalid params' do
    let(:params) { { name: '' } }
    before { subject }

    it do
      is_expected.to eq false
      expect(model).to be_changed
      expect(model.errors).to be_present
      expect(model.reload).not_to have_attributes params
    end
  end
end
