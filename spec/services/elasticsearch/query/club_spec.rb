describe Elasticsearch::Query::Club, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :clubs
    ClubsIndex.purge!
  end

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit,
      locale: 'ru'
    )
  end

  let!(:club_1) { create :club, name: 'test', locale: 'ru' }
  let!(:club_2) { create :club, name: 'test zxct', locale: 'ru' }
  let!(:club_3) { create :club, name: 'test 2', locale: 'en' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [club_1.id, club_2.id] }
end
