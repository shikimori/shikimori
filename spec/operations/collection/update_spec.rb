# frozen_string_literal: true

describe Collection::Update do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject { described_class.call collection, params }

  let(:collection) do
    create :collection,
      kind: Types::Collection::Kind[type],
      user: user,
      created_at: 1.day.ago
  end
  let!(:topic) do
    create :collection_topic, linked: collection, forum_id: Forum::HIDDEN_ID
  end
  let(:type) { %i[anime manga ranobe].sample }

  context 'valid params' do
    let(:params) do
      {
        name: 'test collection',
        state: state,
        links: [{
          linked_id: db_entry_1.id,
          group: 'zz1',
          text: 'xx1'
        }, {
          linked_id: db_entry_2.id,
          group: 'zz2',
          text: 'xx2'
        }]
      }
    end
    let(:state) { 'unpublished' }
    let!(:collection_link_1) do
      create :collection_link, collection: collection, linked: db_entry_1
    end
    let!(:collection_link_2) do
      create :collection_link, collection: collection, linked: db_entry_3
    end
    let(:db_entry_1) { create type, updated_at: 1.day.ago }
    let(:db_entry_2) { create type, updated_at: 1.day.ago }
    let(:db_entry_3) { create type, updated_at: 1.day.ago }

    before { subject }

    it do
      expect(collection.errors).to be_empty
      expect(collection.reload).to have_attributes params.except(:links)
      expect(collection.links).to have(2).items
      expect(collection.links.first).to have_attributes(
        linked: db_entry_1,
        group: 'zz1',
        text: 'xx1'
      )
      expect(collection.links.last).to have_attributes(
        linked: db_entry_2,
        group: 'zz2',
        text: 'xx2'
      )

      # expect(collection.topics).to be_empty
      expect(collection.created_at).to be_within(0.1).of 1.day.ago
      expect { collection_link_1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { collection_link_2.reload }.to raise_error ActiveRecord::RecordNotFound

      # NOTE: disabled because of `touch: true` in CollectionLink
      # expect(db_entry_1.reload.updated_at).to be_within(0.1).of 1.day.ago
      # expect(db_entry_2.reload.updated_at).to be_within(0.1).of 1.day.ago
      # expect(db_entry_3.reload.updated_at).to be_within(0.1).of 1.day.ago
    end

    describe 'publish' do
      let(:state) { 'published' }

      it do
        expect(collection.errors).to be_empty
        expect(collection.reload).to have_attributes params.except(:links)
        expect(collection.topics).to have(1).item
        expect(collection.topics.first).to have_attributes(
          id: topic.id,
          forum_id: Topic::FORUM_IDS['Collection']
        )
        expect(collection.created_at).to be_within(0.1).of Time.zone.now
        expect(collection.updated_at).to be_within(0.1).of Time.zone.now
        expect(collection.topics.first.created_at).to be_within(0.1).of Time.zone.now
        expect(collection.topics.first.updated_at).to be_within(0.1).of Time.zone.now

        # NOTE: disabled because of `touch: true` in CollectionLink
        # expect(db_entry_1.reload.updated_at).to be_within(0.1).of Time.zone.now
        # expect(db_entry_2.reload.updated_at).to be_within(0.1).of Time.zone.now
        # expect(db_entry_3.reload.updated_at).to be_within(0.1).of 1.day.ago
      end
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
