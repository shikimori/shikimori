class AniMangaDecorator::RelatedDecorator < BaseDecorator
  instance_cache :related, :similar, :all

  # связанные аниме
  def related
    all.map do |v|
      RelatedEntry.new (v.anime || v.manga).decorate, v.relation
    end
  end

  # похожие аниме
  def similar
    object
      .send("similar_#{object.class.name.downcase.pluralize}")
      .map(&:decorate)
  end

  # есть ли они вообще?
  def any?
    related.any?
  end

  # одно ли связанное аниме?
  def one?
    related.size == 1
  end

  # одно ли что-либо, кроме адаптаций?
  def chronology?
    related.any? { |v| v.relation.downcase != 'adaptation' }
  end

  # достаточно ли большое число связанных аниме?
  #def many?
    #related.size > AnimeDecorator::VISIBLE_RELATED
  #end

  def all
    object
      .related
      .includes(:anime, :manga)
      .select { |v| (v.anime_id && v.anime && v.anime.name) || (v.manga_id && v.manga && v.manga.name) }
      .sort_by do |v|
        (v.anime_id ? v.anime.aired_on : nil) ||
          (v.manga_id ? v.manga.aired_on : nil) ||
          Date.new(9999)
      end
  end
end
