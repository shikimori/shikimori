class FixPositionsForGenres < ActiveRecord::Migration
  def up
    pos = 1
    Genre.where(name: 'Shounen').update_all position: (pos=pos+7)
    Genre.where(name: 'Shounen Ai').update_all position: (pos=pos+7)
    Genre.where(name: 'Seinen').update_all position: (pos=pos*10)

    Genre.where(name: 'Shoujo').update_all position: (pos=pos+7)
    Genre.where(name: 'Shoujo Ai').update_all position: (pos=pos+7)
    Genre.where(name: 'Josei').update_all position: (pos=pos*10)

    Genre.where(name: 'Comedy').update_all position: (pos=pos+7)
    Genre.where(name: 'Romance').update_all position: (pos=pos+7)
    Genre.where(name: 'School').update_all position: (pos=pos*10)

    pos+=7

    Genre.where(name: 'Slice of Life').update_all position: pos
    Genre.where(name: 'Drama').update_all position: pos
    Genre.where(name: 'Action').update_all position: pos
    Genre.where(name: 'Mecha').update_all position: pos
    Genre.where(name: 'Fantasy').update_all position: pos

    Genre.where(name: 'Harem').update_all position: pos
    Genre.where(name: 'Ecchi').update_all position: pos

    Genre.where(name: 'Vampire').update_all position: pos
    Genre.where(name: 'Historical').update_all position: pos
    Genre.where(name: 'Space').update_all position: pos
    Genre.where(name: 'Mystery').update_all position: pos
    Genre.where(name: 'Adventure').update_all position: pos
    Genre.where(name: 'Samurai').update_all position: pos
    Genre.where(name: 'Supernatural').update_all position: pos
    Genre.where(name: 'Sports').update_all position: pos
    Genre.where(name: 'Sci-Fi').update_all position: pos

    Genre.where(name: 'Martial Arts').update_all position: pos
    Genre.where(name: 'Military').update_all position: pos
    Genre.where(name: 'Demons').update_all position: pos
    Genre.where(name: 'Game').update_all position: pos
    Genre.where(name: 'Magic').update_all position: pos
    Genre.where(name: 'Parody').update_all position: pos
    Genre.where(name: 'Super Power').update_all position: pos
    Genre.where(name: 'Horror').update_all position: pos
    Genre.where(name: 'Dementia').update_all position: pos
    Genre.where(name: 'Kids').update_all position: pos
    Genre.where(name: 'Cars').update_all position: pos
    Genre.where(name: 'Music').update_all position: pos
    Genre.where(name: 'Police').update_all position: pos
    Genre.where(name: 'Psychological').update_all position: pos
    Genre.where(name: 'Gender Bender').update_all position: pos
    Genre.where(name: 'Thriller').update_all position: (pos=pos*10)

    Genre.where(name: 'Hentai').update_all position: (pos=Genre::MiscGenresPosition+1)
    Genre.where(name: 'Yaoi').update_all position: (pos=pos+7)
    Genre.where(name: 'Yuri').update_all position: (pos=pos+7)#(pos=pos*10)
  end

  def down
  end
end
