require 'spec_helper'

describe NameMatcher do
  let(:matcher) { NameMatcher.new(Anime) }

  describe :get_id do
    describe 'single match' do
      let!(:anime) { create :anime, kind: 'TV', name: 'My anime', synonyms: ['My little anime', 'My : little anime', 'My Little Anime', 'MyAnim'] }

      it { matcher.get_id(anime.name).should be anime.id }
      it { matcher.get_id("#{anime.synonyms.last}!").should be anime.id }
      it { matcher.get_id("#{anime.name} TV").should be anime.id }
      it { matcher.get_id(anime.synonyms.first).should be anime.id }
      it { matcher.get_id("#{anime.synonyms.first} TV").should be anime.id }
      it { matcher.get_id("#{anime.synonyms.first}, with comma").should be anime.id }
    end

    describe 'matches "&" with "and"' do
      subject { matcher.get_id 'test and test' }
      let!(:anime) { create :anime, kind: 'TV', name: 'test & test' }
      it { should be anime.id }
    end

    describe 'matches "and" with "&"' do
      subject { matcher.get_id 'test and test' }
      let!(:anime) { create :anime, kind: 'TV', name: 'test and test' }
      it { should be anime.id }
    end

    describe 'matches "S3" with "Season 3"' do
      subject { matcher.get_id 'Anime S3' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Anime Season 3' }
      it { should be anime.id }
    end

    describe 'matches "The anime" with "anime"' do
      subject { matcher.get_id 'The anime' }
      let!(:anime) { create :anime, kind: 'TV', name: 'anime' }
      it { should be anime.id }
    end

    describe 'matches "anime" with "The anime"' do
      subject { matcher.get_id 'anime' }
      let!(:anime) { create :anime, kind: 'TV', name: 'The anime' }
      it { should be anime.id }
    end

    describe 'matches "Season 3" with "S3"' do
      let!(:anime) { create :anime, kind: 'TV', name: 'Anime S3' }
      it { matcher.get_id("Anime Season 3").should be anime.id }
    end

    describe 'matches Madoka' do
      subject { matcher.get_id 'Mahou Shoujo Madoka Magica' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Mahou Shoujo Madoka★Magika', synonyms: ['Mahou Shoujo Madoka Magika'] }
      it { should be anime.id }
    end

    describe 'matches downcase' do
      subject { matcher.get_id 'mahou shoujo madoka magica' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Mahou Shoujo Madoka★Magika', synonyms: ['Mahou Shoujo Madoka Magika'] }
      it { should be anime.id }
    end

    describe 'prefers tv' do
      subject { matcher.get_id anime2.name }
      let!(:anime1) { create :anime, kind: 'TV', name: 'test' }
      let!(:anime2) { create :anime, kind: 'Movie', name: anime1.name }

      it { should be anime1.id }
    end

    describe 'matches long lines in brackets' do
      subject { matcher.get_id "My youth romantic comedy is wrong as I expected. (Yahari ore no seishun rabukome wa machigatte iru.)" }
      let!(:anime) { create :anime, kind: 'TV', name: 'Yahari Ore no Seishun Love Come wa Machigatteiru.', english: ["My youth romantic comedy is wrong as I expected."] }
      it { should be anime.id }
    end

    describe 'matches short lines in brackets' do
      subject { matcher.get_id 'Cyborg009 (1968ver.)' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Cyborg 009' }
      it { should be anime.id }
    end

    describe 'matches with year at end' do
      subject { matcher.get_id 'The Genius Bakabon 1975' }
      let!(:anime) { create :anime, kind: 'TV', name: 'The Genius Bakabon', aired_at: DateTime.parse('1975-01-01') }
      it { should be anime.id }
    end

    describe 'matches without brackets' do
      subject { matcher.get_id 'HUNTER x HUNTER 2011' }
      let!(:anime) { create :anime, kind: 'TV', name: 'Hunter x Hunter (2011)' }
      it { should be anime.id }
    end
  end

  describe :get_ids do
    subject { matcher.get_ids anime2.name }
    let!(:anime1) { create :anime, kind: 'TV', name: 'test' }
    let!(:anime2) { create :anime, kind: 'Movie', name: anime1.name }

    it { should eq [anime1.id, anime2.id] }
  end

  describe :fetch_id do
    subject { matcher.fetch_id 'The Genius' }
    let!(:anime1) { create :anime, kind: 'TV', name: 'The Genius Bakabon' }
    let!(:anime2) { create :anime, kind: 'TV', name: 'zzz' }

    it { should be anime1.id }
  end
end
