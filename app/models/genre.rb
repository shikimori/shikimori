class Genre < ActiveRecord::Base
  # Relations
  has_and_belongs_to_many :animes

  HentaiID = 12
  YaoiID = 33
  YuriID = 34
  ShounenAiID = 28
  ShoujoAiID = 26

  Merged = {
    45 => 41
  }

  ThrillerDupID = 45

  MiscGenresPosition = 10000000

  MainGenres = [
    'Seinen',
    'Josei',
    'Yaoi',
    'Hentai',
    'Action',
    'Comedy',
    'Drama',
    'Romance',
    'Slice of Life',
    'School',
    'Samurai',
    'Vampire',
    'Sci-Fi',
    'Mystery',
    'Mecha',
    'Yuri',
    'Shoujo Ai',
    'Shounen Ai',
    'Shoujo',
    'Shounen'
  ]

  LongNameGenres = [
    'Slice of Life',
    'Martial Arts',
    'Supernatural',
    'Psychological'
  ]


  # основной ли жанр
  def main?
    MainGenres.include?(self.english)
  end

  # возвращет все id, связанные с текущим
  def self.related(id)
    Merged.map { |k,v| k == id ? v : (v == id ? k : nil) }.compact << id
  end

  def format_for_title(types, rus_var)
    case self.english
      when 'Magic'        then "#{types} про магию"
      when 'Space'        then "#{types} про космос"
      when 'Demons'       then "#{types} про демонов"
      when 'Vampire'      then "#{types} про вампиров"
      when 'Mystery'      then "#{types} о мистике"
      when 'School'       then "#{types} про школу"
      when 'Police'       then "#{types} про полицию"
      when 'Sports'       then "#{types} про спорт"
      when 'Games'        then "#{types} про игры"
      when 'Martial Arts' then "#{types} про боевые искусства"
      when 'Samurai'      then "#{types} про самураев"
      when 'Adventure'    then "#{types} о приключениях"
      when 'Drama'        then "#{types} в жанре драма"
      when 'Horror'       then "#{types} в жанре ужасы"
      when 'Sci-Fi'       then "#{types} в жанре фантастика"
      when 'Comedy'       then "#{rus_var == nil ? 'Комедийных' : (rus_var ? 'Комедии' : 'Комедийная')} #{Unicode.downcase types}"
      when 'Romance'      then "#{rus_var == nil ? 'Романтических' : (rus_var ? 'Романтические' : 'Романтическая')} #{Unicode.downcase types} про любовь"
      when 'Historical'   then "#{rus_var == nil ? 'Исторических' : (rus_var ? 'Исторические' : 'Историческая')} #{Unicode.downcase types}"
      when 'Supernatural' then "#{rus_var == nil ? 'Сверхъестественных' : (rus_var ? 'Сверхъестественные' : 'Сверхъестественная')} #{Unicode.downcase types}"
      when 'Yaoi'         then "#{types} яой"
      when 'Kids'         then "Детское #{Unicode.downcase types}"
      when 'Mecha'        then "Меха #{Unicode.downcase types} про роботов"
      when 'Shounen'      then "Сёнен #{Unicode.downcase types}"
      when 'Shounen Ai'   then "Сёнен-Ай #{Unicode.downcase types}"
      when 'Seinen'       then "Сэйнэн #{Unicode.downcase types}"
      when 'Shoujo'       then "Сёдзё #{Unicode.downcase types}"
      when 'Shoujo Ai'    then "Сёдзё-Ай #{Unicode.downcase types}"
      when 'Josei'        then "Дзёсэй #{Unicode.downcase types}"
      when 'Fantasy'      then "Фэнтези #{Unicode.downcase types}"
      when 'Thriller'     then "Триллер #{Unicode.downcase types}"
      when 'Echi'         then "Этти #{Unicode.downcase types}"
      when 'Yuri'         then "Юри #{Unicode.downcase types}"
      else "#{types} жанра #{self.russian || self.name}"
    end
  end

  def english
    self[:name]
  end

  def to_param
    "%d-%s" % [id, self.english.gsub(' ', '-')]
  end

  def censored?
    id == HentaiID || id == YaoiID || id == YuriID
  end
end
