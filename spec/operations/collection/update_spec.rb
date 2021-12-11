# frozen_string_literal: true

describe Collection::Update do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject do
    described_class.call collection, params, transition, user
  end

  let(:collection) do
    create :collection,
      kind: Types::Collection::Kind[type],
      user: user,
      moderation_state: moderation_state,
      approver: user,
      created_at: 1.day.ago
  end
  let!(:topic) do
    create :collection_topic,
      linked: collection,
      forum_id: Forum::HIDDEN_ID
  end
  let(:type) { %i[anime manga ranobe].sample }
  let(:moderation_state) { %i[accepted pending].sample }
  let(:transition) { nil }

  context 'valid params' do
    let(:params) do
      {
        name: 'test collection',
        links: [
          ActionController::Parameters.new(
            linked_id: db_entry_1.id,
            group: 'zz1',
            text: 'xx1'
          ).permit!,
          ActionController::Parameters.new(
            linked_id: db_entry_2.id,
            group: 'zz2',
            text: 'xx2'
          ).permit!,
          ActionController::Parameters.new(
            linked_id: db_entry_3.id,
            group: 'zz3',
            text: 'xx3'
          ).permit!
        ]
      }
    end
    let!(:collection_link_1) do
      create :collection_link, collection: collection, linked: db_entry_1
    end
    let!(:collection_link_2) do
      create :collection_link, collection: collection, linked: db_entry_3
    end
    let(:db_entry_1) { create type, updated_at: 1.day.ago }
    let(:db_entry_2) { create type, updated_at: 1.day.ago }
    let(:db_entry_3) { create type, updated_at: 1.day.ago }

    it do
      is_expected.to eq true
      expect(collection.errors).to be_empty
      expect(collection.reload).to have_attributes params.except(:links)
      expect(collection.created_at).to be_within(0.1).of 1.day.ago
      expect(collection.changed_at).to be_within(0.1).of Time.zone.now
      expect(collection.links).to have(3).items
      expect(collection.links_count).to eq 3
      expect(collection.links.first).to have_attributes(
        linked: db_entry_1,
        group: 'zz1',
        text: 'xx1'
      )
      expect(collection.links.last).to have_attributes(
        linked: db_entry_3,
        group: 'zz3',
        text: 'xx3'
      )

      expect(collection.topics.first).to have_attributes(
        id: topic.id,
        forum_id: Forum::HIDDEN_ID
      )

      expect { collection_link_1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { collection_link_2.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    describe 'publish' do
      let(:transition) { :to_published }
      let(:params) { nil }

      it do
        is_expected.to be_nil
        expect(collection.errors).to be_empty
        expect(collection.reload).to be_published
        expect(collection.published_at).to be_within(0.1).of Time.zone.now
        expect(collection.created_at).to be_within(0.1).of Time.zone.now
        expect(collection.changed_at).to be_within(0.1).of Time.zone.now
        expect(collection.changed_at).to be_within(0.1).of Time.zone.now

        expect(collection.topics).to have(1).item
        expect(collection.topics.first).to have_attributes(
          id: topic.id,
          forum_id: Topic::FORUM_IDS['Collection']
        )
        expect(collection.topics.first.created_at).to be_within(0.1).of Time.zone.now
      end

      context 'rejected collection' do
        let(:moderation_state) { :rejected }

        it do
          is_expected.to be_nil
          expect(collection.topics.first).to have_attributes(
            forum_id: Forum::OFFTOPIC_ID
          )
        end
      end
    end
  end

  context 'invalid params' do
    let(:params) { { name: '' } }

    it do
      is_expected.to eq false
      expect(collection.errors).to be_present
      expect(collection.reload).not_to have_attributes params
    end
  end
end
