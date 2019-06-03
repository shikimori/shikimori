describe Versions::CollectionVersion do
  let(:anime) { create :anime }
  let(:version) do
    create :collection_version,
      item: anime,
      item_diff: {
        external_links: [
          anime.external_links,
          external_links_data
        ]
      }
  end

  let!(:external_link) do
    create :external_link,
      entry: anime,
      created_at: 2.weeks.ago,
      updated_at: 1.week.ago
  end
  let(:external_links_data) do
    [{
      url: 'http://ya.ru',
      kind: 'wikipedia',
      source: 'shikimori',
      entry_type: anime.class.name,
      entry_id: anime.id
    }, {
      url: 'http://google.com',
      kind: 'anime_db',
      source: 'shikimori',
      entry_type: anime.class.name,
      entry_id: anime.id
    }]
  end

  describe 'instance methods' do
    describe '#current_value' do
      it do
        expect(version.current_value(:external_links))
          .to eq JSON.parse([external_link.attributes.except('id')].to_json)
      end
    end

    describe '#apply_changes' do
      before { version.apply_changes }

      it do
        expect(anime.reload.external_links).to have(2).items
        expect(anime.desynced).to eq ['external_links']
        expect(anime.external_links.first)
          .to have_attributes external_links_data.first
        expect(anime.external_links.second)
          .to have_attributes external_links_data.second
        expect { external_link.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '#rollback_changes' do
      before do
        version.apply_changes
        version.reload.rollback_changes
      end

      it do
        expect(anime.reload.external_links).to have(1).item
        expect(anime.external_links.first)
          .to have_attributes external_link.attributes.except('id', 'updated_at', 'created_at')
        expect(anime.external_links.first.created_at)
          .to be_within(0.1).of(external_link.created_at)
        expect { external_link.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
