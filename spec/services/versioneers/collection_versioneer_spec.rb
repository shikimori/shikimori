describe Versioneers::CollectionVersioneer do
  let(:service) { described_class.new anime, :external_links }
  let(:anime) { create :anime }
  let(:author) { build_stubbed :user }
  let(:reason) { 'change reason' }

  let!(:external_link) { create :external_link, entry: anime }
  let(:external_links_data) do
    [{
      'url' => 'http://ya.ru',
      'kind' => 'wikipedia',
      'source' => 'shikimori',
      'entry_type' => anime.class.name,
      'entry_id' => anime.id
    }, {
      'url' => 'http://google.com',
      'kind' => 'anime_db',
      'source' => 'shikimori',
      'entry_type' => anime.class.name,
      'entry_id' => anime.id
    }]
  end

  describe '#premoderate' do
    subject!(:version) do
      service.premoderate external_links_data, author, reason
    end

    it do
      expect(anime.reload.external_links).to eq [external_link]
      expect(external_link.reload).to be_persisted

      expect(version).to be_persisted
      expect(version).to_not be_changed
      expect(version).to be_pending
      expect(version).to be_instance_of Versions::CollectionVersion
      expect(version).to have_attributes(
        user: author,
        reason: reason,
        item_diff: {
          'external_links' => [
            [
              JSON.parse(external_link.attributes.except('id').to_json)
            ].map { |v| service.send :convert, v },
            external_links_data.map { |v| service.send :convert, v }
          ]
        },
        item: anime,
        moderator: nil
      )
    end

    describe 'no changes' do
      let(:external_links_data) do
        [
          JSON.parse(
            external_link.attributes
              .except('id', 'entry_id', 'imported_at')
              .merge('imported_at' => '', 'entry_id' => external_link.entry_id.to_s)
              .to_json
          )
        ]
      end
      it { expect(version).to be_new_record }
    end
  end

  describe '#postmoderate' do
    subject!(:version) { service.postmoderate external_links_data, author, reason }

    context 'can auto_accept' do
      let(:author) { user_admin }

      it do
        expect(anime.reload.external_links).to have(2).items
        expect { external_link.reload }.to raise_error ActiveRecord::RecordNotFound

        expect(version).to be_persisted
        expect(version).to_not be_changed
        expect(version).to be_auto_accepted

        expect(version).to be_instance_of Versions::CollectionVersion
        expect(version).to have_attributes(
          user: author,
          reason: reason,
          item_diff: {
            'external_links' => [
              [
                JSON.parse(external_link.attributes.except('id').to_json)
              ].map { |v| service.send :convert, v },
              external_links_data.map { |v| service.send :convert, v }
            ]
          },
          item: anime,
          moderator: author
        )
      end
    end

    context 'cannot auto_accept' do
      let(:author) { user_1 }

      it do
        expect(anime.reload.external_links).to have(1).item
        expect(external_link.reload).to be_persisted

        expect(version).to be_persisted
        expect(version).to_not be_changed
        expect(version).to be_pending

        expect(version).to be_instance_of Versions::CollectionVersion
        expect(version).to have_attributes(
          user: author,
          reason: reason,
          item_diff: {
            'external_links' => [
              [
                JSON.parse(external_link.attributes.except('id').to_json)
              ].map { |v| service.send :convert, v },
              external_links_data.map { |v| service.send :convert, v }
            ]
          },
          item: anime,
          moderator: nil
        )
      end
    end
  end
end
