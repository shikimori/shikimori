describe Elasticsearch::Data::Person do
  subject { Elasticsearch::Data::Person.call person }
  let(:person) do
    create :person,
      name: 'zzz',
      japanese: 'ff',
      russian: 'ттт',
      seyu: true,
      producer: false,
      mangaka: false
  end

  it do
    is_expected.to eq(
      name: 'zzz',
      japanese: 'ff',
      russian: 'ттт',
      is_seyu: true,
      is_producer: false,
      is_mangaka: false
    )
  end
end
