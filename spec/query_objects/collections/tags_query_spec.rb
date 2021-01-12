describe Collections::TagsQuery do
  subject { described_class.call }

  let!(:collection_1) { create :collection, :published, tags: %i[яяя ссс] }
  let!(:collection_2) { create :collection, :published, tags: %i[ббб] }
  let!(:collection_3) { create :collection, tags: %i[zzz] }

  it { is_expected.to eq %w[ббб ссс яяя] }
end
