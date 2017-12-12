describe Elasticsearch::Query::Topic, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :topics
    TopicsIndex.purge!
  end

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit,
      forum_id: forum_id,
      locale: locale
    )
  end

  let!(:topic_1) { create :topic, title: 'test', locale: 'ru', forum_id: forum_id }
  let!(:topic_2) { create :topic, title: 'test zxct', locale: 'ru', forum_id: forum_id }
  let!(:topic_3) { create :topic, title: 'test 2', locale: 'en', forum_id: forum_id }
  let!(:topic_4) { create :topic, title: 'test', locale: 'ru', forum_id: Topic::FORUM_IDS[Contest.name] }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }
  let(:forum_id) { Topic::FORUM_IDS[Anime.name] }
  let(:locale) { 'ru' }

  it { is_expected.to have_keys [topic_1.id, topic_2.id] }
end
