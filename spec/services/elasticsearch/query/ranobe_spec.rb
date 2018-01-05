describe Elasticsearch::Query::Ranobe, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :mangas
    RanobeIndex.purge!
  end

  subject { described_class.call phrase: phrase, limit: ids_limit }

  let!(:ranobe_1) { create :ranobe, name: 'test' }
  let!(:ranobe_2) { create :ranobe, name: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [ranobe_1.id, ranobe_2.id] }
end
