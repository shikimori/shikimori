describe Elasticsearch::Data::Club do
  subject { Elasticsearch::Data::Club.call club }
  let(:club) { create :club, name: 'zzz', locale: 'ru' }

  it { is_expected.to eq name: 'zzz', locale: 'ru' }
end
