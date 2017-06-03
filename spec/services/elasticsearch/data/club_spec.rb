describe Elasticsearch::Data::Club do
  subject { Elasticsearch::Data::Club.call club }
  let(:collection) { create :club, name: 'zzz', locale: 'ru' }

  it { is_expected.to eq name: 'zzz', locale: 'ru' }
end
