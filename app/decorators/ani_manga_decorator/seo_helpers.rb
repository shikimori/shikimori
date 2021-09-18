module AniMangaDecorator::SeoHelpers
  def seo_keywords
    [
      object.name, object.russian,
      (object.synonyms || '').join(', '),
      (object.english || '').join(', '),
      "#{anime? ? 'аниме' : 'манга'} #{short_name object}",
      "#{short_name object} персонажи",
      "#{short_name object} обсуждение",
      (cosplay.characters.any? ? "#{short_name object} косплей" : nil),
      (critiques? ? "#{short_name object} обзоры, рецензии, отзывы" : '')
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

private

  def short_name entry
    entry.name.gsub(/:.*|'$/, '')
  end
end
