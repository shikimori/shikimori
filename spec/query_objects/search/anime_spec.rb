describe Search::Anime do
  before do
    allow(Elasticsearch::Query::Anime).to receive(:call)
      .with(phrase: phrase, limit: ids_limit)
      .and_return(
        anime_3.id => 9,
        anime_1.id => 8
      )
  end

  subject do
    described_class.call scope: scope, phrase: phrase, ids_limit: ids_limit
  end

  let(:scope) { Anime.all }
  let(:phrase) { 'Kaichou' }
  let(:ids_limit) { 10 }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }
  let!(:anime_3) { create :anime }

  it { is_expected.to eq [anime_3, anime_1] }
end
