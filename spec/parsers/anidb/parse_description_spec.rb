describe Anidb::ParseDescription, :vcr do
  subject(:call) { service.call url }
  let(:service) { described_class.new }

  context 'valid url' do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=3395' }
    it do
      is_expected.to eq(
        'aoeu'
      )
    end
  end

  context 'invalid url' do
    let(:url) { 'http://foofoofoofoo.com' }
    it { expect { call }.to raise_error EmptyContentError }
  end

  context 'unkown anime id' do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=33911111' }
    it { expect { call }.to raise_error InvalidIdError }
  end

  context 'unkown character id' do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=character&charid=33311111' }
    it { expect { call }.to raise_error InvalidIdError }
  end
end
