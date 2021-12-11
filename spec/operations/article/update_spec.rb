# frozen_string_literal: true

describe Article::Update do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject { described_class.call article, params, user }

  let(:article) { create :article, user: user, created_at: 1.day.ago }
  let!(:topic) do
    create :article_topic, linked: article, forum_id: Forum::HIDDEN_ID
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
      expect(article.errors).to be_empty
      expect(article.reload).to have_attributes params
      expect(article.created_at).to be_within(0.1).of 1.day.ago
      expect(article.changed_at).to be_within(0.1).of Time.zone.now

      expect(article.topics.first).to have_attributes(
        id: topic.id,
        forum_id: Forum::HIDDEN_ID
      )
    end

    describe 'publish' do
      let(:state) { 'published' }

      it do
        is_expected.to eq true
        expect(article.errors).to be_empty
        expect(article.reload).to have_attributes params
        expect(article.created_at).to be_within(0.1).of Time.zone.now
        expect(article.changed_at).to be_within(0.1).of Time.zone.now

        expect(article.topics).to have(1).item
        expect(article.topics.first).to have_attributes(
          id: topic.id,
          forum_id: Topic::FORUM_IDS['Article']
        )
        expect(article.topics.first.created_at).to be_within(0.1).of Time.zone.now
      end
    end
  end

  context 'invalid params' do
    let(:params) { { name: '' } }
    before { subject }

    it do
      is_expected.to eq false
      expect(article.errors).to be_present
      expect(article.reload).not_to have_attributes params
    end
  end
end
