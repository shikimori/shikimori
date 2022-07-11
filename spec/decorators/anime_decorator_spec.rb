describe AnimeDecorator do
  let(:anime) { create :anime, news_topics: [news_topic] }
  let(:news_topic) { create :news_topic }

  describe '#news_topic_views' do
    it { expect(anime.reload.decorate.news_topic_views).to have(1).item }
  end
end
