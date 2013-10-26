class AddRussianToGenre < ActiveRecord::Migration
  def self.up
    add_column :genres, :russian, :string

    Genre.where(:name => 'Action').update_all(:russian => 'Экшен')
    Genre.where(:name => 'Adventure').update_all(:russian => 'Приключения')
    Genre.where(:name => 'Cars').update_all(:russian => 'Машины')
    Genre.where(:name => 'Comedy').update_all(:russian => 'Комедия')
    Genre.where(:name => 'Dementia').update_all(:russian => 'Безумие')
    Genre.where(:name => 'Demons').update_all(:russian => 'Демоны')
    Genre.where(:name => 'Drama').update_all(:russian => 'Драма')
    Genre.where(:name => 'Ecchi').update_all(:russian => 'Этти')
    Genre.where(:name => 'Fantasy').update_all(:russian => 'Фэнтези')
    Genre.where(:name => 'Game').update_all(:russian => 'Игры')
    Genre.where(:name => 'Gender Bender').update_all(:russian => 'Смена пола')
    Genre.where(:name => 'Hentai').update_all(:russian => 'Хентай')
    Genre.where(:name => 'Harem').update_all(:russian => 'Гарем')
    Genre.where(:name => 'Historical').update_all(:russian => 'Исторический')
    Genre.where(:name => 'Horror').update_all(:russian => 'Ужасы')
    Genre.where(:name => 'Josei').update_all(:russian => 'Дзёсей')
    Genre.where(:name => 'Kids').update_all(:russian => 'Детское')
    Genre.where(:name => 'Magic').update_all(:russian => 'Магия')
    Genre.where(:name => 'Mecha').update_all(:russian => 'Меха')
    Genre.where(:name => 'Martial Arts').update_all(:russian => 'Боевые искусства')
    Genre.where(:name => 'Military').update_all(:russian => 'Военное')
    Genre.where(:name => 'Music').update_all(:russian => 'Музыка')
    Genre.where(:name => 'Mystery').update_all(:russian => 'Мистика')
    Genre.where(:name => 'Parody').update_all(:russian => 'Пародия')
    Genre.where(:name => 'Police').update_all(:russian => 'Полиция')
    Genre.where(:name => 'Psychological').update_all(:russian => 'Психологическое')
    Genre.where(:name => 'Romance').update_all(:russian => 'Романтика')
    Genre.where(:name => 'Samurai').update_all(:russian => 'Самураи')
    Genre.where(:name => 'School').update_all(:russian => 'Школа')
    Genre.where(:name => 'Sci-Fi').update_all(:russian => 'Фантастика')
    Genre.where(:name => 'Seinen').update_all(:russian => 'Сейнен')
    Genre.where(:name => 'Shoujo Ai').update_all(:russian => 'Сёдзе Ай')
    Genre.where(:name => 'Shoujo').update_all(:russian => 'Сёдзе')
    Genre.where(:name => 'Shounen Ai').update_all(:russian => 'Сёнен Ай')
    Genre.where(:name => 'Shounen').update_all(:russian => 'Сёнен')
    Genre.where(:name => 'Slice of Life').update_all(:russian => 'Повседневность')
    Genre.where(:name => 'Space').update_all(:russian => 'Космос')
    Genre.where(:name => 'Sports').update_all(:russian => 'Спорт')
    Genre.where(:name => 'Super Power').update_all(:russian => 'Супер сила')
    Genre.where(:name => 'Supernatural').update_all(:russian => 'Сверхъестественное')
    Genre.where(:name => 'Thriller').update_all(:russian => 'Триллер')
    Genre.where(:name => 'Vampire').update_all(:russian => 'Вампиры')
    Genre.where(:name => 'Yaoi').update_all(:russian => 'Яой')
    Genre.where(:name => 'Yuri').update_all(:russian => 'Юри')
  end

  def self.down
    remove_column :genres, :russian
  end
end
