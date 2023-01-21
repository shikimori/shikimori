# frozen_string_literal: true

class TestCreate < UserContent::CreateBase
  klass Article
  is_auto_acceptable true
  is_publishable true
end

describe UserContent::CreateBase do
  subject(:model) { TestCreate.call params }

  let(:params) do
    {
      name: 'Test Article Name',
      user_id: user.id,
      body: 'Test Article Text'
    }
  end

  context 'valid params' do
    it do
      expect(model).to be_persisted
      expect(model).to have_attributes params.merge(
        state: 'unpublished'
      )
      expect(model.errors).to be_empty
      expect(model.topic).to have_attributes(
        linked: model,
        type: Topics::EntryTopics::ArticleTopic.name,
        forum_id: Forum::HIDDEN_ID
      )
    end
  end

  context 'invalid params' do
    let(:params) { { user_id: user.id } }
    it do
      expect(model).to be_new_record
      expect(model).to_not be_valid
      expect(model.topic).to_not be_present
    end
  end

  describe 'auto acceptable' do
    context 'model moderator' do
      let(:user) { create :user, :article_moderator }

      it do
        expect(model).to be_persisted
        expect(model).to_not be_changed
        expect(model).to have_attributes(
          approver: user,
          moderation_state: 'accepted'
        )
      end
    end

    context 'not model moderator' do
      it do
        expect(model).to be_persisted
        expect(model).to_not be_changed
        expect(model).to have_attributes(
          approver: nil,
          moderation_state: 'pending'
        )
      end
    end
  end
end
