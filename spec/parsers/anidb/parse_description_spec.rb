describe Anidb::ParseDescription, :vcr do
  subject(:call) { service.call url }
  let(:service) { described_class.new }

  context 'valid anime url' do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=3395' }
    it do
      is_expected.to eq(
        <<-TEXT.squish
          * Based on the manga by [url=https://anidb.net/cr10211]Hiroe
          Rei[/url].[br][br]When [url=https://anidb.net/ch1194]Okajima
          Rokuro[/url] (aka [i]Rock[/i]) visits Southeast Asia carrying a top
          secret disk, he is kidnapped by pirates riding in the torpedo boat,
          [i]Black Lagoon[/i]. Although he thought he would be rescued soon,
          the company actually abandons him, and sends mercenaries to retrieve
          the secret disk. He narrowly escapes with his life, but has nowhere
          to go. He gives up his name and past, and resolves to live as a
          member of the Black Lagoon.[source]AnimeNfo[/source]
        TEXT
      )
    end
  end

  context 'valid character url' do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=character&charid=3444' }
    it do
      is_expected.to eq(
        <<-TEXT.squish
          Mitsuki is friends with both Takayuki and Haruka, but secretly she
          has feelings for Takayuki. In high school she was a competitive swimmer.
        TEXT
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
