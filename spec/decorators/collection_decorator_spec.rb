describe CollectionDecorator do
  let(:decorator) { CollectionDecorator.new collection }
  let(:collection) { create :collection }
  let!(:link_1) do
    create :collection_link,
      collection: collection,
      linked: anime_1,
      group: 'a'
  end
  let!(:link_2) do
    create :collection_link,
      collection: collection,
      linked: anime_2,
      group: 'a'
  end
  let!(:link_3) do
    create :collection_link,
      collection: collection,
      linked: anime_3,
      group: 'b',
      text: 'z'
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
    it { expect(decorator.texts).to eq anime_3.id => link_3.text }
  end
end
