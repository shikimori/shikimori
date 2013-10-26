require 'spec_helper'

describe NameMatcher do
  let(:matcher) { NameMatcher.new(Anime) }

  describe 'get_id' do
    describe 'single match' do
      let(:anime) do
        create :anime, kind: 'TV',
                      name: 'My anime',
                      synonyms: ['My little anime', 'My : little anime', 'My Little Anime', 'MyAnim']
      end
      before { anime }

      it 'matches by name' do
        matcher.get_id(anime.name).should be anime.id
      end

      it 'matches w/o !' do
        matcher.get_id("#{anime.synonyms.last}!").should be anime.id
      end

      it 'matches by name with kind suffix' do
        matcher.get_id("#{anime.name} TV").should be anime.id
      end

      it 'matches by synonym name' do
        matcher.get_id(anime.synonyms.first).should be anime.id
      end

      it 'matches by synonym name with kind suffix' do
        matcher.get_id("#{anime.synonyms.first} TV").should be anime.id
      end

      it 'matches even with comma' do
        matcher.get_id("#{anime.synonyms.first}, with comma").should be anime.id
      end
    end

    it 'matches "&" with "and"' do
      anime = create :anime, kind: 'TV', name: 'test & test'
      matcher.get_id("test and test").should be anime.id
    end

    it 'matches "and" with "&"' do
      anime = create :anime, kind: 'TV', name: 'test and test'
      matcher.get_id("test & test").should be anime.id
    end

    it 'matches "S3" with "Season 3"' do
      anime = create :anime, kind: 'TV', name: 'Anime Season 3'
      matcher.get_id("Anime S3").should be anime.id
    end

    it 'matches "The anime" with "anime"' do
      anime = create :anime, kind: 'TV', name: 'anime'
      matcher.get_id("The anime").should be anime.id
    end

    it 'matches "anime" with "The anime"' do
      anime = create :anime, kind: 'TV', name: 'The anime'
      matcher.get_id("anime").should be anime.id
    end

    it 'matches "Season 3" with "S3"' do
      anime = create :anime, kind: 'TV', name: 'Anime S3'
      matcher.get_id("Anime Season 3").should be anime.id
    end

    it 'matches Madoka' do
      anime = create :anime, kind: 'TV', name: 'Mahou Shoujo Madoka★Magika', synonyms: ['Mahou Shoujo Madoka Magika']
      matcher.get_id("Mahou Shoujo Madoka Magica").should be anime.id
    end

    it 'matches downcase' do
      anime = create :anime, kind: 'TV', name: 'Mahou Shoujo Madoka★Magika', synonyms: ['Mahou Shoujo Madoka Magika']
      matcher.get_id("mahou shoujo madoka magica").should be anime.id
    end

    it 'prefers tv' do
      anime1 = create :anime, kind: 'TV', name: 'test'
      anime2 = create :anime, kind: 'Movie', name: anime1.name

      matcher.get_id(anime2.name).should be anime1.id
    end

    it 'matches long lines in brackets' do
      anime = create :anime, kind: 'TV', name: 'Yahari Ore no Seishun Love Come wa Machigatteiru.', english: ["My youth romantic comedy is wrong as I expected."]
      matcher.get_id('My youth romantic comedy is wrong as I expected. (Yahari ore no seishun rabukome wa machigatte iru.)').should be anime.id
    end

    it 'matches short lines in brackets' do
      anime = create :anime, kind: 'TV', name: 'Cyborg 009'
      matcher.get_id('Cyborg009 (1968ver.)').should be anime.id
    end

    it 'matches with year at end' do
      anime = create :anime, kind: 'TV', name: 'The Genius Bakabon', aired_at: DateTime.parse('1975-01-01')
      matcher.get_id('The Genius Bakabon 1975').should be anime.id
    end

    it 'matches without brackets' do
      anime = create :anime, kind: 'TV', name: 'Hunter x Hunter (2011)'
      matcher.get_id('HUNTER x HUNTER 2011').should be anime.id
    end
  end

  describe 'fetch_id' do
    it 'fetches from database' do
      anime1 = create :anime, kind: 'TV', name: 'The Genius Bakabon'
      anime2 = create :anime, kind: 'TV', name: 'zzz'

      matcher.fetch_id("The Genius").should be anime1.id
    end
  end
end
