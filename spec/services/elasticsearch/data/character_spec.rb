describe Elasticsearch::Data::Character do
  subject { Elasticsearch::Data::Character.call character }
  let(:character) do
    create :character,
      fullname: 'zzz',
      japanese: 'ff',
      russian: 'ттт'
  end

  it do
    is_expected.to eq(
      fullname: 'zzz',
      japanese: 'ff',
      russian: 'ттт'
    )
  end
end
