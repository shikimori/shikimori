describe Articles::TagsQuery do
  subject { described_class.call }

  let!(:article_1) { create :article, :published, tags: %i[яяя ссс] }
  let!(:article_2) { create :article, :published, tags: %i[ббб] }
  let!(:article_3) { create :article, tags: %i[zzz] }

  it { is_expected.to eq %w[ббб ссс яяя] }
end
