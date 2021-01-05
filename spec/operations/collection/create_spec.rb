# frozen_string_literal: true

describe Collection::Create do
  subject(:collection) { Collection::Create.call params, locale }

  let(:locale) { :en }

  context 'valid params' do
    let(:params) do
      {
        name: 'Test Collection Name',
        user_id: user.id,
        kind: 'anime',
        text: 'Test Collection Text'
      }
    end

    it do
      expect(collection).to be_persisted
      expect(collection).to have_attributes params.merge(
        locale: locale.to_s,
        state: 'unpublished'
      )
      expect(collection.errors).to be_empty
      expect(collection.topics).to have(1).item
      expect(collection.topics.first).to have_attributes(
        linked: collection,
        type: Topics::EntryTopics::CollectionTopic.name,
        forum_id: Forum::HIDDEN_ID
      )
    end
  end

  context 'invalid params' do
    let(:params) { { user_id: user.id } }
    it do
      expect(collection).to be_new_record
      expect(collection).to_not be_valid
      expect(collection.topics).to be_empty
    end
  end
end
