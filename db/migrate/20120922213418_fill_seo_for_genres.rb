class FillSeoForGenres < ActiveRecord::Migration
  def self.up
    Genre.where(:name => 'Romance').update_all seo: 1
    Genre.where(:name => 'Yaoi').update_all seo: 1
    Genre.where(:name => 'Vampire').update_all seo: 2
    Genre.where(:name => 'Horror').update_all seo: 3
    Genre.where(:name => 'Demons').update_all seo: 4
    Genre.where(:name => 'Samurai').update_all seo: 5
    Genre.where(:name => 'School').update_all seo: 6
    Genre.where(:name => 'Harem').update_all seo: 7
    Genre.where(:name => 'Ecchi').update_all seo: 8
    Genre.where(:name => 'Shoujo').update_all seo: 8
    Genre.where(:name => 'Magic').update_all seo: 9
    Genre.where(:name => 'Martial Arts').update_all seo: 10
    Genre.where(:name => 'Space').update_all seo: 11
    Genre.where(:name => 'Shounen').update_all seo: 11
    Genre.where(:name => 'Yuri').update_all seo: 12
    Genre.where(:name => 'Comedy').update_all seo: 13
    Genre.where(:name => 'Fantasy').update_all seo: 14
    Genre.where(:name => 'Adventure').update_all seo: 15
    Genre.where(:name => 'Mecha').update_all seo: 16
    Genre.where(:name => 'Sci-Fi').update_all seo: 17

    Genre.where(:name => 'Action').update_all seo: 99
    Genre.where(:name => 'Cars').update_all seo: 99
    Genre.where(:name => 'Dementia').update_all seo: 99
    Genre.where(:name => 'Drama').update_all seo: 99
    Genre.where(:name => 'Game').update_all seo: 99
    Genre.where(:name => 'Gender Bender').update_all seo: 99
    Genre.where(:name => 'Hentai').update_all seo: 99
    Genre.where(:name => 'Historical').update_all seo: 99
    Genre.where(:name => 'Josei').update_all seo: 99
    Genre.where(:name => 'Kids').update_all seo: 99
    Genre.where(:name => 'Military').update_all seo: 99
    Genre.where(:name => 'Music').update_all seo: 99
    Genre.where(:name => 'Mystery').update_all seo: 99
    Genre.where(:name => 'Parody').update_all seo: 99
    Genre.where(:name => 'Police').update_all seo: 99
    Genre.where(:name => 'Psychological').update_all seo: 99
    Genre.where(:name => 'Seinen').update_all seo: 99
    Genre.where(:name => 'Shoujo Ai').update_all seo: 99
    Genre.where(:name => 'Shounen Ai').update_all seo: 99
    Genre.where(:name => 'Slice of Life').update_all seo: 99
    Genre.where(:name => 'Sports').update_all seo: 99
    Genre.where(:name => 'Super Power').update_all seo: 99
    Genre.where(:name => 'Supernatural').update_all seo: 99
    Genre.where(:name => 'Thriller').update_all seo: 99
  end
end
