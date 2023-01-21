# frozen_string_literal: true

describe Collection::Create do
  subject(:model) { described_class.call params }

  let(:params) do
    {
      name: 'Test Collection Name',
      user_id: user.id,
      kind: 'anime',
      text: 'Test Collection Text'
    }
  end

  it do
    expect(model).to be_persisted
    expect(model).to have_attributes params.merge(
      state: 'unpublished'
    )
    expect(model.errors).to be_empty
    expect(model.topic).to be_present
    expect(model.topic).to have_attributes(
      linked: model,
      type: Topics::EntryTopics::CollectionTopic.name,
      forum_id: Forum::HIDDEN_ID
    )
  end
end
