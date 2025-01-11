class AniMangaDecorator::RelatedDecorator < BaseDecorator
  instance_cache :related, :similar, :all

  ADAPTATION_ORIGINS = %i[light_novel manga]

  def related
    all.map do |relation|
      RelatedEntry.new(
        (relation.anime || relation.manga).decorate,
        other_adaptation?(relation) ?
          I18n.t('enumerize.related_anime.relation_kind.other') :
          relation.relation_kind_text
      )
    end
  end

  def similar
    return [] if object.rkn_abused?

    object
      .send(:"similar_#{object.class.base_class.name.downcase.pluralize}")
      .map(&:decorate)
  end

  delegate :any?, to: :related

  def one?
    related.size == 1
  end

  def chronology?
    all.any? do |relation|
      relation.relation_kind != Types::RelatedAniManga::RelationKind[:adaptation]
    end
  end

  def all # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    return [] if object.rkn_abused?

    object
      .related
      .includes(:anime, :manga)
      .select { |relation| relation.anime || relation.manga }
      .sort_by do |relation|
        relation.anime&.aired_on.presence ||
          relation.manga&.aired_on.presence ||
          Date.new(9999)
      end
  end
 
  def other_adaptation? relation # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    relation.adaptation? &&
      relation.manga &&
      anime? &&
      (
        (
          origin&.to_sym&.in?(ADAPTATION_ORIGINS) &&
          relation.manga.kind != origin
        ) || (
          origin_manga_id.present? &&
          relation.manga_id != origin_manga_id
        )
      )
  end
end
