describe CollectionDecorator do
  let(:decorator) { CollectionDecorator.new collection }
  let(:collection) { create :collection }
  let!(:collection_topic) { create :collection_topic, linked: collection }

  describe '#minified_topic_view', :focus do
    subject { decorator.minified_topic_view }
    it do
      expect(subject.is_preview).to eq true
      expect(subject.is_mini).to eq true
      is_expected.to be_kind_of Topics::CollectionView
    end
  end
end
