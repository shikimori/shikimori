# frozen_string_literal: true

describe Article::Create do
  subject(:article) { Article::Create.call params, locale }

  let(:locale) { :en }

  context 'valid params' do
    let(:params) do
      {
        name: 'Test Article Name',
        user_id: user.id,
        body: 'Test Article Text'
      }
    end

    it do
      expect(article).to be_persisted
      expect(article).to have_attributes params.merge(
        locale: locale.to_s,
        state: 'unpublished'
      )
      expect(article.errors).to be_empty
      expect(article.topics.first).to have_attributes(
        linked: article,
        type: Topics::EntryTopics::ArticleTopic.name,
        forum_id: Forum::HIDDEN_ID
      )
    end
  end

  context 'invalid params' do
    let(:params) { { user_id: user.id } }
    it do
      expect(article).to be_new_record
      expect(article).to_not be_valid
      expect(article.topics).to be_empty
    end
  end
end
