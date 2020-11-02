describe Elasticsearch::Query::Anime, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[animes]
  # include_context :chewy_logger

  subject { described_class.call phrase: phrase, limit: ids_limit }

  let!(:anime_1) { create :anime, name: 'test', russian: 'аа' }
  let!(:anime_2) { create :anime, name: 'test zxct', russian: 'аа' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [anime_1.id, anime_2.id] }

  # context 'kind weight' do
  #   let!(:anime_1) { create :anime, name: 'test', kind: :special, russian: 'аа' }
  #   let!(:anime_2) { create :anime, name: 'test', kind: :tv, russian: 'аа' }
  #
  #   it { is_expected.to have_keys [anime_2.id, anime_1.id] }
  # end
  #
  # context 'score weight' do
  #   let!(:anime_1) { create :anime, name: 'test', score: 7, russian: 'аа' }
  #   let!(:anime_2) { create :anime, name: 'test', score: 8, russian: 'аа' }
  #
  #   it { is_expected.to have_keys [anime_2.id, anime_1.id] }
  # end
end
