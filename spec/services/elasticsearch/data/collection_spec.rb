describe Elasticsearch::Data::Collection do
  subject { Elasticsearch::Data::Collection.call collection }
  let(:collection) { create :collection, name: 'zzz', locale: 'ru' }

  it { is_expected.to eq name: 'zzz', locale: 'ru' }
end
