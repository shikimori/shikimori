module AniMangaDecorator::SeoHelpers
  def seo_keywords
    [
      object.name, object.russian,
      (object.synonyms || '').join(', '),
      (object.english || '').join(', '),
      "#{anime? ? 'аниме' : 'манга'} #{object.short_name}",
      "#{object.short_name} персонажи",
      "#{object.short_name} обсуждение",
      (cosplay.characters.any? ? "#{object.short_name} косплей" : nil),
      (reviews? ? "#{object.short_name} обзоры, рецензии, отзывы" : '')
    ].select(&:present?).join(', ')
  end

  def seo_description
    h.ani_manga_description object, 310
  end

  # главный сео жанр
  def main_genre
    genre = object.genres.sort_by(&:seo).first
    genres = object.genres.select { |v| v.seo == genre.seo }

    genres[object.id % genres.size - 1]
  end
end

