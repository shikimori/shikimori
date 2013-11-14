require 'spec_helper'

describe NameMatcher do
  let(:matcher) { NameMatcher.new Anime }

  describe :match do
    describe 'single match' do
      let!(:anime) { create :anime, kind: 'TV', name: 'My anime', synonyms: ['My little anime', 'My : little anime', 'My Little Anime', 'MyAnim'] }

      it { matcher.match(anime.name).should eq anime }
      it { matcher.match("#{anime.synonyms.last}!").should eq anime }
      it { matcher.match("#{anime.name} TV").should eq anime }
      it { matcher.match(anime.synonyms.first).should eq anime }
      it { matcher.match("#{anime.synonyms.first} TV").should eq anime }
      it { matcher.match("#{anime.synonyms.first}, with comma").should eq anime }
    end

    describe '"&" with "and"' do
      subject { matcher.match 'test and test' }
      let!(:anime) { create :anime, kind: 'TV', name: 'test & test' }
      it { should eq anime }
    end

    describe '"and" with "&"' do
      subject { matcher.match 'test and test' }
      let!(:anime) { create :anime, kind: 'TV', name: 'test and test' }
      it { should eq anime }
    end

    describe '"S3" with "Season 3"' do
      subject { matcher.match 'Anime S3' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Anime Season 3' }
      it { should eq anime }
    end

    describe '"The anime" with "anime"' do
      subject { matcher.match 'The anime' }
      let!(:anime) { create :anime, kind: 'TV', name: 'anime' }
      it { should eq anime }
    end

    describe '"anime" with "The anime"' do
      subject { matcher.match 'anime' }
      let!(:anime) { create :anime, kind: 'TV', name: 'The anime' }
      it { should eq anime }
    end

    describe '"Season 3" with "S3"' do
      let!(:anime) { create :anime, kind: 'TV', name: 'Anime S3' }
      it { matcher.match("Anime Season 3").should eq anime }
    end

    describe 'Madoka' do
      subject { matcher.match 'Mahou Shoujo Madoka Magica' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Mahou Shoujo Madoka★Magika', synonyms: ['Mahou Shoujo Madoka Magika'] }
      it { should eq anime }
    end

    describe 'downcase' do
      subject { matcher.match 'mahou shoujo madoka magica' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Mahou Shoujo Madoka★Magika', synonyms: ['Mahou Shoujo Madoka Magika'] }
      it { should eq anime }
    end

    describe 'prefers tv' do
      subject { matcher.match anime2.name }
      let!(:anime1) { create :anime, kind: 'TV', name: 'test' }
      let!(:anime2) { create :anime, kind: 'Movie', name: anime1.name }

      it { should eq anime1 }
    end

    describe '2nd season' do
      subject { matcher.match 'Kingdom 2' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Kingdom 2nd Season' }
      it { should eq anime }
    end

    describe 'more 2nd season' do
      subject { matcher.match 'Major 2nd Season' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Major S2' }
      it { should eq anime }
    end

    describe '3rd season' do
      subject { matcher.match 'Kingdom 3' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Kingdom 3rd Season' }
      it { should eq anime }
    end

    describe '4th season' do
      subject { matcher.match 'Kingdom 4' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Kingdom 4th Season' }
      it { should eq anime }
    end

    describe 'reversed 2nd season' do
      subject { matcher.match 'Kingdom 2nd Season' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Kingdom 2' }
      it { should eq anime }
    end

    describe 'series' do
      subject { matcher.match 'Kigeki [Sweat Punch Series 3]' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Sweat Punch' }
      it { should eq anime }
    end

    describe 'long lines in brackets' do
      subject { matcher.match "My youth romantic comedy is wrong as I expected. (Yahari ore no seishun rabukome wa machigatte iru.)" }
      let!(:anime) { create :anime, kind: 'TV', name: 'Yahari Ore no Seishun Love Come wa Machigatteiru.', english: ["My youth romantic comedy is wrong as I expected."] }
      it { should eq anime }
    end

    describe 'without [ТВ-N]' do
      subject { matcher.match 'Hayate no Gotoku! Cuties [ТВ- 4]' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Hayate no Gotoku! Cuties' }
      it { should eq anime }
    end

    describe 'without ТВ-N' do
      subject { matcher.match 'Buzzer Beater ТВ-1' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Buzzer Beater' }
      it { should eq anime }
    end

    describe 'without TV' do
      subject { matcher.match 'Tenchi Universe' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Tenchi Universe TV' }
      it { should eq anime }
    end

    describe 'without [OVA-N]' do
      subject { matcher.match 'JoJo no Kimyou na Bouken [OVA-2]' }
      let!(:anime) { create :anime, kind: 'TV', name: 'JoJo no Kimyou na Bouken' }
      it { should eq anime }
    end

    describe 'without year' do
      subject { matcher.match 'JoJo no Kimyou na Bouken' }
      let!(:anime) { create :anime, kind: 'TV', name: 'JoJo no Kimyou na Bouken (2000)' }
      it { should eq anime }
    end

    describe 'short lines in brackets' do
      subject { matcher.match 'Cyborg009 (1968ver.)' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Cyborg 009' }
      it { should eq anime }
    end

    describe 'reversed words' do
      subject { matcher.match 'Lain - Serial Experiments' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Serial Experiments Lain' }
      it { should eq anime }
    end

    #describe 'translit' do
      #subject { matcher.match 'dokidoki!preсure' }
      #let!(:anime) { create :anime, kind: 'TV', name: 'dokidoki!precure' }
      #it { should eq anime }
    #end

    describe 'year at end' do
      subject { matcher.match 'The Genius Bakabon 1975' }
      let!(:anime) { create :anime, kind: 'TV', name: 'The Genius Bakabon', aired_at: DateTime.parse('1975-01-01') }
      it { should eq anime }
    end

    describe 'without brackets' do
      subject { matcher.match 'HUNTER x HUNTER 2011' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Hunter x Hunter (2011)' }
      it { should eq anime }
    end

    describe '/' do
      subject { matcher.match 'Fate Zero' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Fate/Zero' }
      it { should eq anime }
    end

    describe '!' do
      subject { matcher.match 'Upotte' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Upotte!!' }
      it { should eq anime }
    end

    describe '"' do
      subject { matcher.match 'Boku no Imouto wa Osaka Okan' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Boku no Imouto wa "Osaka Okan": Haishin Gentei Osaka Okan.' }
      it { should eq anime }
    end

    describe 'russian with !' do
      subject { matcher.match 'Гинтама: Финальная арка: Йорозуя навсегда' }
      let!(:anime) { create :anime, kind: 'TV', russian: 'Гинтама: Финальная арка: Йорозуя навсегда!' }
      it { should eq anime }
    end

    describe '～' do
      subject { matcher.match 'Little Busters～Refrain～' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Little Busters!: Refrain' }
      it { should eq anime }
    end

    describe 'space delimiter' do
      subject { matcher.match 'Kyousougiga' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Kyousou Giga (TV)' }
      it { should eq anime }
    end

    describe 'russian' do
      subject { matcher.match 'Раз героем мне не стать - самое время работу искать!' }
      let!(:anime) { create :anime, kind: 'TV', russian: 'Раз героем мне не стать - самое время работу искать!' }
      it { should eq anime }
    end

    describe 'the animation' do
      subject { matcher.match 'Baton The Animation' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Baton' }
      it { should eq anime }
    end

    describe '"s" as "sh"' do
      subject { matcher.match 'YuShibu' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Yusibu' }
      it { should eq anime }
    end

    describe '"o" as "h"' do
      subject { matcher.match "Yuu-Gi-Ou! 5D's" }
      let!(:anime) { create :anime, kind: 'TV', name: "Yu-Gi-Oh! 5D's" }
      it { should eq anime }
    end

    describe '"u" as "uu"' do
      subject { matcher.match 'Kyuu' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Kyu' }
      it { should eq anime }
    end

    describe '" o " as " wo "' do
      subject { matcher.match 'Papa no Iukoto o Kikinasai! OVA' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Papa no Iukoto wo Kikinasai! OVA' }
      it { should eq anime }
    end

    describe '"o" as "ou"' do
      subject { matcher.match 'Rouaaaa' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Roaaaa' }
      it { should eq anime }
    end

    describe '"Plus" as "+"' do
      subject { matcher.match 'Amagami SS Plus' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Amagami SS+' }
      it { should eq anime }
    end

    describe '"special" as "specials"' do
      subject { matcher.match 'Suisei no Gargantia Special' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Suisei no Gargantia Specials' }
      it { should eq anime }
    end

    describe 'multiple replacements' do
      subject { matcher.match 'Rou Kyuu Bu! SS' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Ro-Kyu-Bu! SS' }
      it { should eq anime }
    end

    describe 'alternative names from config' do
      subject { matcher.match 'Охотник х Охотник [ТВ -2]' }
      let!(:anime) { create :anime, kind: 'TV', id: 11061 }
      it { should eq anime }
    end
  end

  describe :matches, :focus do
    subject { matcher.matches anime2.name, year: 2001 }
    let!(:anime1) { create :anime, aired_at: DateTime.parse('2001-01-01'), kind: 'TV', name: 'test' }
    let!(:anime2) { create :anime, kind: 'Movie', name: anime1.name }
    let!(:anime3) { create :anime, aired_at: DateTime.parse('2001-01-01'), name: anime1.name }

    it { should eq [anime1, anime3] }
  end

  describe :fetch do
    subject { matcher.fetch 'The Genius' }
    let!(:anime1) { create :anime, kind: 'TV', name: 'The Genius Bakabon' }
    let!(:anime2) { create :anime, kind: 'TV', name: 'zzz' }

    it { should eq anime1 }
  end

  describe :by_link do
    subject { matcher.by_link link.identifier, :findanime }
    let(:matcher) { NameMatcher.new Anime, nil, [:findanime] }
    let!(:anime) { create :anime }
    let!(:link) { create :anime_link, service: :findanime, identifier: 'zxcvbn', anime: anime }

    it { should eq anime }
  end
end
