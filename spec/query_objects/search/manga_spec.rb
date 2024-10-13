describe Search::Manga do
  subject { described_class.call scope:, phrase:, ids_limit: }

  before do
    allow(Elasticsearch::Query::Manga).to receive(:call)
      .with(phrase:, limit: ids_limit)
      .and_return(
        manga_3.id => 9,
        manga_1.id => 8
      )
  end

  let(:scope) { Manga.all }
  let(:phrase) { 'Kaichou' }
  let(:ids_limit) { 10 }

  let!(:manga_1) { create :manga }
  let!(:manga_2) { create :manga }
  let!(:manga_3) { create :manga }

  it { is_expected.to eq [manga_3, manga_1] }
end
