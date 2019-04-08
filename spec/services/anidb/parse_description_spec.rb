# frozen_string_literal: true

describe Anidb::ParseDescription do
  subject(:call) { described_class.call url }

  let(:cookie) { cookie_naruto2148 }
  # banned account (daria.ingate@mail.ru)
  let(:cookie_naruto2148) do
    %w[
      adbautopass=vbzjomexrccnxcla;
      adbautouser=naruto2148;
      adbsessuser=naruto2148;
      adbuin=1490295269-RLyR;
    ]
  end
  # active account (temp email)
  let(:cookie_naruto1451) do
    %w[
      adbautopass=zwsofsxfdnrzyxdj;
      adbautouser=naruto1451;
      adbsess=HeOtBhOHtFVJILxs;
      adbsessuser=naruto1451;
      adbss=740345-HeOtBhOH;
      adbuin=1491134069-bSaf;
      anidbsettings=%7B%22USEAJAX%22%3A1%7D;
    ]
  end
  before do
    allow(Anidb::Authorization.instance)
      .to receive(:cookie)
      .and_return(cookie)
  end

  context 'valid anime url', vcr: {
    cassette_name: 'Anidb_ParseDescription/valid_anime_url'
  } do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=3395' }
    it do
      is_expected.to eq(
        <<-TEXT.squish
          * Based on the manga by [Hiroe Rei].[br][br]When [Okajima Rokuro]
          (aka [i]Rock[/i]) visits Southeast Asia carrying a top
          secret disk, he is kidnapped by pirates riding in the torpedo boat,
          [i]Black Lagoon[/i]. Although he thought he would be rescued soon,
          the company actually abandons him, and sends mercenaries to retrieve
          the secret disk. He narrowly escapes with his life, but has nowhere
          to go. He gives up his name and past, and resolves to live as a
          member of the Black Lagoon.[source]AnimeNfo[/source]
        TEXT
      )
    end

    context 'no description' do
      let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=2461' }

      it { is_expected.to eq '' }
    end
  end

  context 'valid character url', vcr: {
    cassette_name: 'Anidb_ParseDescription/valid_character_url'
  } do
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

  # cassette is not recorded for site whose DNS address
  # cannot be found - it causes spec to fail on CI server
  # since HTTP request is performed again which is prohibited
  # by VCR configuration -> just stub Proxy.get response
  context 'invalid url' do
    let(:url) { 'http://foofoofoofoo.com' }
    before { allow(Proxy).to receive(:get).and_return '' }
    it { expect { call }.to raise_error EmptyContentError }
  end

  context 'unknown anime id', vcr: {
    cassette_name: 'Anidb_ParseDescription/unknown_anime_id'
  } do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=33911111' }
    it { expect { call }.to raise_error InvalidIdError }
  end

  context 'unknown character id', vcr: {
    cassette_name: 'Anidb_ParseDescription/unknown_character_id'
  } do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=character&charid=33311111' }
    it { expect { call }.to raise_error InvalidIdError }
  end

  context 'captcha', vcr: { cassette_name: 'Anidb_ParseDescription/captcha' } do
    let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=313' }
    it { expect { call }.to raise_error CaptchaError }
  end

  context 'adult content' do
    context 'success', vcr: {
      cassette_name: 'Anidb_ParseDescription/adult_content/success'
    } do
      let(:cookie) { cookie_naruto1451 }
      let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=314' }
      it do
        is_expected.to include(
          <<-TEXT.squish
            Orphaned at a young age, her parents victims of a brutal double
            murder, [Sawa] was taken in by the detective assigned to her case.
            Not content to just watch as the imperfect justice system lets more
            and more criminals go loose every day, he decides to train her to
            be his instrument of justice. After all, who'd suspect a pretty
            college student of being a deadly vigilante!
          TEXT
        )
      end
    end

    context 'auto banned', vcr: {
      cassette_name: 'Anidb_ParseDescription/adult_content/auto_banned'
    } do
      let(:url) { 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid=528' }
      it { expect { call }.to raise_error AutoBannedError }
    end
  end
end
