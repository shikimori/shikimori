describe Elasticsearch::Query::Anime, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :animes
    AnimesIndex.purge!
  end

  subject do
    described_class.call(
      phrase: phrase,
      limit: ids_limit
    )
  end

  let!(:anime_1) { create :anime, name: 'test' }
  let!(:anime_2) { create :anime, name: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [anime_1.id, anime_2.id] }

  context 'kind weight' do
    let!(:anime_1) { create :anime, name: 'test', kind: :special }
    let!(:anime_2) { create :anime, name: 'test', kind: :tv }

    it { is_expected.to have_keys [anime_2.id, anime_1.id] }
  end

  context 'score weight' do
    let!(:anime_1) { create :anime, name: 'test', score: 7 }
    let!(:anime_2) { create :anime, name: 'test', score: 8 }

    it { is_expected.to have_keys [anime_2.id, anime_1.id] }
  end
end
