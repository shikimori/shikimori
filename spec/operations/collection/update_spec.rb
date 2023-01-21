# frozen_string_literal: true

describe Collection::Update do
  include_context :timecop
  subject do
    described_class.call model, params, transition, user
  end

  let(:model) do
    create :collection,
      kind: Types::Collection::Kind[type],
      user: user,
      moderation_state: moderation_state,
      approver: user,
      created_at: 1.day.ago
  end
  let!(:topic) do
    create :collection_topic,
      linked: model,
      forum_id: Forum::HIDDEN_ID
  end
  let(:type) { %i[anime manga ranobe].sample }
  let(:moderation_state) { %i[accepted pending].sample }
  let(:transition) { nil }

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
    create :collection_link, collection: model, linked: db_entry_1
  end
  let!(:collection_link_2) do
    create :collection_link, collection: model, linked: db_entry_3
  end
  let(:db_entry_1) { create type, updated_at: 1.day.ago }
  let(:db_entry_2) { create type, updated_at: 1.day.ago }
  let(:db_entry_3) { create type, updated_at: 1.day.ago }

  it do
    is_expected.to eq true
    expect(model).to_not be_changed
    expect(model.errors).to be_empty
    expect(model.reload).to have_attributes params.except(:links)
    expect(model.created_at).to be_within(0.1).of 1.day.ago
    expect(model.changed_at).to be_within(0.1).of Time.zone.now
    expect(model.links).to have(3).items
    expect(model.links_count).to eq 3
    expect(model.links.first).to have_attributes(
      linked: db_entry_1,
      group: 'zz1',
      text: 'xx1'
    )
    expect(model.links.last).to have_attributes(
      linked: db_entry_3,
      group: 'zz3',
      text: 'xx3'
    )

    expect(model.topic).to have_attributes(
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
      expect(model.errors).to be_empty
      expect(model).to_not be_changed
      expect(model.reload).to be_published
      expect(model.published_at).to be_within(0.1).of Time.zone.now
      expect(model.created_at).to be_within(0.1).of Time.zone.now
      expect(model.changed_at).to be_within(0.1).of Time.zone.now

      expect(model.topic).to be_present
      expect(model.topic).to have_attributes(
        id: topic.id,
        forum_id: Topic::FORUM_IDS['Collection']
      )
      expect(model.topic.created_at).to be_within(0.1).of Time.zone.now
    end

    context 'rejected collection' do
      let(:moderation_state) { :rejected }

      it do
        is_expected.to be_nil
        expect(model.topic).to have_attributes(
          forum_id: Forum::OFFTOPIC_ID
        )
      end
    end
  end
end
