describe Elasticsearch::Query::Article, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[articles]
  # include_context :chewy_logger

  subject { described_class.call phrase: phrase, limit: ids_limit }

  let!(:article_1) { create :article, name: 'test' }
  let!(:article_2) { create :article, name: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [article_1.id, article_2.id] }
end
