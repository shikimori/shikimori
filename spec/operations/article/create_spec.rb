# frozen_string_literal: true

describe Article::Create do
  subject(:article) { Article::Create.call params }

  let(:params) do
    {
      name: 'Test Article Name',
      user_id: user.id,
      body: 'Test Article Text'
    }
  end

  context 'valid params' do
    it do
      expect(article).to be_persisted
      expect(article).to have_attributes params.merge(
        state: 'unpublished'
      )
      expect(article.errors).to be_empty
      expect(article.topic).to have_attributes(
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
      expect(article.topic).to_not be_present
    end
  end

  describe 'auto-accept' do
    context 'article_moderator' do
      let(:user) { create :user, :article_moderator }

      it do
        expect(article).to be_persisted
        expect(article).to have_attributes(
          approver: user,
          moderation_state: 'accepted'
        )
      end
    end

    context 'not article_moderator' do
      it do
        expect(article).to be_persisted
        expect(article).to have_attributes(
          approver: nil,
          moderation_state: 'pending'
        )
      end
    end
  end
end
