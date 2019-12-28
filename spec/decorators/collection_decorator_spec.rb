describe CollectionDecorator do
  let(:decorator) { CollectionDecorator.new collection }
  let(:collection) { create :collection }
  let!(:link_1) do
    create :collection_link,
      collection: collection,
      linked: anime_1,
      group: 'a',
      text: 'a'
  end
  let!(:link_2) do
    create :collection_link,
      collection: collection,
      linked: anime_2,
      group: 'a',
      text: 'b'
  end
  let!(:link_3) do
    create :collection_link,
      collection: collection,
      linked: anime_3,
      group: 'b',
      text: '[b]z[/b]'
  end
  let(:anime_1) { create :anime }
  let(:anime_2) { create :anime }
  let(:anime_3) { create :anime }

  describe '#groups' do
    it do
      expect(decorator.groups).to eq(
        'a' => [anime_1, anime_2],
        'b' => [anime_3]
      )
    end
  end

  describe '#texts' do
    it do
      expect(decorator.texts).to eq(
        [
          { group_index: 0, linked_id: anime_1.id, text: 'a', linked_type: 'anime' },
          { group_index: 0, linked_id: anime_2.id, text: 'b', linked_type: 'anime' },
          { group_index: 1, linked_id: anime_3.id, text: '<strong>z</strong>', linked_type: 'anime' }
        ]
      )
    end
  end

  describe '#entries_sample' do
    it do
      expect(decorator.entries_sample).to eq [anime_1, anime_2, anime_3]
      expect(decorator.entries_sample.first).to be_decorated
    end
  end

  describe '#size' do
    it { expect(decorator.size).to eq 3 }
  end
end
