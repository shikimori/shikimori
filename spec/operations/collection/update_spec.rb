# frozen_string_literal: true

describe Collection::Update do
  include_context :timecop
  subject { described_class.call collection, params }

  let(:collection) { create :collection, user: user }

  context 'valid params' do
    let(:params) do
      {
        name: 'test collection',
        state: state,
        links: [{
          linked_id: anime_1.id,
          group: 'zz1',
          text: 'xx1'
        }, {
          linked_id: anime_2.id,
          group: 'zz2',
          text: 'xx2'
        }]
      }
    end
    let(:state) { 'unpublished' }
    let!(:collection_link_1) do
      create :collection_link, collection: collection, linked: anime_1
    end
    let!(:collection_link_2) do
      create :collection_link, collection: collection, linked: anime_3
    end
    let(:anime_1) { create :anime, updated_at: 1.day.ago }
    let(:anime_2) { create :anime, updated_at: 1.day.ago }
    let(:anime_3) { create :anime, updated_at: 1.day.ago }

    before { subject }

    it do
      expect(collection.errors).to be_empty
      expect(collection.reload).to have_attributes params.except(:links)
      expect(collection.links).to have(2).items
      expect(collection.links.first).to have_attributes(
        linked_id: anime_1.id,
        linked_type: Anime.name,
        group: 'zz1',
        text: 'xx1'
      )
      expect(collection.links.last).to have_attributes(
        linked_id: anime_2.id,
        linked_type: Anime.name,
        group: 'zz2',
        text: 'xx2'
      )

      expect(collection.topics).to be_empty
      expect { collection_link_1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { collection_link_2.reload }.to raise_error ActiveRecord::RecordNotFound

      expect(anime_1.reload.updated_at).to be_within(0.1).of 1.day.ago
      expect(anime_2.reload.updated_at).to be_within(0.1).of 1.day.ago
      expect(anime_3.reload.updated_at).to be_within(0.1).of 1.day.ago
    end

    describe 'publish' do
      let(:state) { 'published' }
      it do
        expect(collection.errors).to be_empty
        expect(collection.reload).to have_attributes params.except(:links)
        expect(collection.topics).to have(1).item
        expect(collection.topics.first.locale).to eq collection.locale

        expect(anime_1.reload.updated_at).to be_within(0.1).of Time.zone.now
        expect(anime_2.reload.updated_at).to be_within(0.1).of Time.zone.now
        expect(anime_3.reload.updated_at).to be_within(0.1).of 1.day.ago
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
