describe Elasticsearch::Query::Character, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :characters
    CharactersIndex.purge!
  end

  subject { described_class.call phrase: phrase, limit: ids_limit }

  let!(:character_1) { create :character, name: 'test' }
  let!(:character_2) { create :character, name: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [character_1.id, character_2.id] }
end
