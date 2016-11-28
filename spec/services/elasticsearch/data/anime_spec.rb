describe Elasticsearch::Data::Anime do
  subject { Elasticsearch::Data::Anime.call anime }
  let(:anime) do
    create :anime, :tv,
      name: 'zzz',
      score: 7,
      russian: 'ттт',
      english: ['qq'],
      japanese: ['ff'],
      synonyms: ['aa', 'bb']
  end

  it do
    is_expected.to eq(
      english: 'qq',
      japanese: 'ff',
      name: 'zzz',
      russian: 'ттт',
      synonym_0: 'aa',
      synonym_1: 'bb',
      synonym_2: nil,
      synonym_3: nil,
      synonym_4: nil,
      synonym_5: nil,
      weight: 1.845
    )
  end
end
