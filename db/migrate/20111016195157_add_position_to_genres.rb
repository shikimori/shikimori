class AddPositionToGenres < ActiveRecord::Migration
  def self.up
    add_column :genres, :position, :integer

    pos = 1
    Genre.where(name: 'Shounen').update_all(position: (pos=pos+7))
    Genre.where(name: 'Shounen Ai').update_all(position: (pos=pos+7))
    Genre.where(name: 'Seinen').update_all(position: (pos=pos+7))

    Genre.where(name: 'Shoujo').update_all(position: (pos=pos+7))
    Genre.where(name: 'Shoujo Ai').update_all(position: (pos=pos+7))
    Genre.where(name: 'Josei').update_all(position: (pos=pos*10))

    Genre.where(name: 'Comedy').update_all(position: (pos=pos+7))
    Genre.where(name: 'School').update_all(position: (pos=pos+7))
    Genre.where(name: 'Romance').update_all(position: (pos=pos+7))
    Genre.where(name: 'Slice of Life').update_all(position: (pos=pos+7))
    Genre.where(name: 'Drama').update_all(position: (pos=pos+7))
    Genre.where(name: 'Action').update_all(position: (pos=pos+7))
    Genre.where(name: 'Mecha').update_all(position: (pos=pos+7))
    Genre.where(name: 'Fantasy').update_all(position: (pos=pos*10))

    Genre.where(name: 'Harem').update_all(position: (pos=pos+7))
    Genre.where(name: 'Ecchi').update_all(position: (pos=pos*10))

    Genre.where(name: 'Vampire').update_all(position: (pos=pos+7))
    Genre.where(name: 'Historical').update_all(position: (pos=pos+7))
    Genre.where(name: 'Space').update_all(position: (pos=pos+7))
    Genre.where(name: 'Mystery').update_all(position: (pos=pos+7))
    Genre.where(name: 'Adventure').update_all(position: (pos=pos+7))
    Genre.where(name: 'Samurai').update_all(position: (pos=pos+7))
    Genre.where(name: 'Supernatural').update_all(position: (pos=pos+7))
    Genre.where(name: 'Sports').update_all(position: (pos=pos+7))
    Genre.where(name: 'Sci-Fi').update_all(position: (pos=pos*10))

    Genre.where(name: 'Martial Arts').update_all(position: (pos=pos+7))
    Genre.where(name: 'Military').update_all(position: (pos=pos+7))
    Genre.where(name: 'Demons').update_all(position: (pos=pos+7))
    Genre.where(name: 'Game').update_all(position: (pos=pos+7))
    Genre.where(name: 'Magic').update_all(position: (pos=pos+7))
    Genre.where(name: 'Parody').update_all(position: (pos=pos+7))
    Genre.where(name: 'Super Power').update_all(position: (pos=pos+7))
    Genre.where(name: 'Horror').update_all(position: (pos=pos*10))

    Genre.where(name: 'Hentai').update_all(position: (pos=Genre::MiscGenresPosition+1))
    Genre.where(name: 'Yaoi').update_all(position: (pos=pos+7))
    Genre.where(name: 'Yuri').update_all(position: (pos=pos*10))

    Genre.where(name: 'Dementia').update_all(position: (pos=pos+7))
    Genre.where(name: 'Kids').update_all(position: (pos=pos+7))
    Genre.where(name: 'Cars').update_all(position: (pos=pos+7))
    Genre.where(name: 'Music').update_all(position: (pos=pos+7))
    Genre.where(name: 'Police').update_all(position: (pos=pos+7))
    Genre.where(name: 'Psychological').update_all(position: (pos=pos+7))
    Genre.where(name: 'Gender Bender').update_all(position: (pos=pos+7))
    Genre.where(name: 'Thriller').update_all(position: (pos=pos+9))
  end

  def self.down
    remove_column :genres, :position
  end
end
