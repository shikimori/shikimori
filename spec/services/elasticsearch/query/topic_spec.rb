describe Elasticsearch::Query::Topic, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[topics]
  # include_context :chewy_logger

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit,
      forum_id: forum_id,
      locale: locale
    )
  end

  let!(:topic_1) do
    create :topic, title: 'test', locale: 'ru', forum_id: forum_id
  end
  let!(:topic_2) do
    create :topic, title: 'test zxct', locale: 'ru', forum_id: forum_id
  end
  let!(:topic_3) do
    create :topic, title: 'test 2', locale: 'en', forum_id: forum_id
  end
  let!(:topic_4) do
    create :topic,
      title: 'test',
      locale: 'ru',
      forum_id: Topic::FORUM_IDS[Contest.name]
  end

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:forum_id) { Topic::FORUM_IDS[Anime.name] }
  let(:locale) { 'ru' }

  it { is_expected.to have_keys [topic_1.id, topic_2.id] }
end
