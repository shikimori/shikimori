describe Topics::TagsQuery do
  subject { described_class.call }

  let!(:topic_1) { create :news_topic, tags: %i[яяя аниме] }
  let!(:topic_2) { create :news_topic, tags: %i[ббб] }

  it { is_expected.to eq %w[ббб яяя] }
end
