describe Elasticsearch::Query::QueryBase, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[animes]
  # include_context :chewy_logger

  subject { Elasticsearch::Query::Anime.call phrase: phrase, limit: ids_limit }

  let!(:anime_1) { create :anime, name: 'test', russian: 'аниме_1' }
  let!(:anime_2) { create :anime, name: 'test zxct qqq', russian: 'аниме_2' }
  let!(:anime_3) { create :anime, name: 'zxc', russian: 'аниме_3' }
  let!(:anime_4) { create :anime, name: 'qw', russian: 'аниме_4' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'Test' }

  it { is_expected.to have_keys [anime_1.id, anime_2.id] }

  describe 'ids_limit' do
    let(:ids_limit) { 1 }
    it { is_expected.to have_keys [anime_1.id] }
  end

  describe 'original match' do
    it { is_expected.to have_keys [anime_1.id, anime_2.id] }
  end

  describe 'edge_phrase match' do
    context 'one letter' do
      let(:phrase) { 't' }
      it { is_expected.to have_keys [anime_1.id, anime_2.id] }
    end

    context 'two letters' do
      let(:phrase) { 'te' }
      it { is_expected.to have_keys [anime_1.id, anime_2.id] }
    end

    context 'more letters' do
      let(:phrase) { 'tes' }
      it { is_expected.to have_keys [anime_1.id, anime_2.id] }
    end
  end

  describe 'edge_word match' do
    context 'word' do
      let(:phrase) { 'qqq' }
      it { is_expected.to have_keys [anime_2.id] }
    end

    context 'edge_phrase first' do
      let(:phrase) { 'zx' }
      it { is_expected.to have_keys [anime_2.id, anime_3.id] }
    end
  end

  context 'no matches' do
    let(:phrase) { 'io' }
    it { is_expected.to eq({}) }
  end

  describe 'multiple names produce the same relevance' do
    let!(:anime_1) { create :anime, name: 'test', english: 'test', russian: '' }
    let!(:anime_2) { create :anime, name: 'test', russian: '' }
    let!(:anime_3) {}
    let!(:anime_4) {}

    it do
      expect(subject[anime_1.id]).to eq subject[anime_2.id]
    end
  end
end
