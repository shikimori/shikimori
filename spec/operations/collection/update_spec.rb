# frozen_string_literal: true

describe Collection::Update do
  subject { Collection::Update.call collection, params }

  let(:user) { create :user }
  let(:collection) { create :collection, :with_topics, user: user }

  context 'valid params' do
    let(:params) { { name: 'test collection' } }
    before { subject }

    it do
      expect(collection.errors).to be_empty
      expect(collection.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) { { name: '' } }
    before { subject }

    it do
      expect(collection.errors).to be_present
      expect(collection.reload).not_to have_attributes params
    end
  end
end
