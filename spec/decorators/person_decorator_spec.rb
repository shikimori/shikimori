describe PersonDecorator do
  let(:person) { create :person, news_topics: [news_topic] }
  let(:news_topic) { create :news_topic }

  describe '#news_topic_views' do
    it { expect(person.reload.decorate.news_topic_views).to have(1).item }
  end
end
