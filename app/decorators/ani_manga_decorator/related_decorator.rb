class AniMangaDecorator::RelatedDecorator < BaseDecorator
  instance_cache :related, :similar, :all

  def related
    return [] if object.rkn_abused?

    all.map do |v|
      RelatedEntry.new (v.anime || v.manga).decorate, v.relation
    end
  end

  def similar
    return [] if object.rkn_abused?

    object
      .send("similar_#{object.class.base_class.name.downcase.pluralize}")
      .map(&:decorate)
  end

  delegate :any?, to: :related

  def one?
    related.size == 1
  end

  def chronology?
    related.any? { |v| v.relation.downcase != 'adaptation' }
  end

  def all
    object
      .related
      .includes(:anime, :manga)
      .select { |v| (v.anime_id && v.anime && v.anime.name) || (v.manga_id && v.manga && v.manga.name) }
      .sort_by do |v|
        (v.anime_id ? v.anime.aired_on.presence : nil) ||
          (v.manga_id ? v.manga.aired_on.presence : nil) ||
          Date.new(9999)
      end
  end
end
