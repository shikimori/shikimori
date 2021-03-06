class Tags::MatchCoubTags
  method_object :tags

  def call
    tags_variants = Tags::GenerateVariants.call @tags

    scope.find_each do |anime|
      tags = Tags::MatchNames.call(
        names: names(anime),
        tags_variants: tags_variants
      )

      if tags.any?
        anime.update coub_tags: tags
        log anime, tags
      end
    end
  end

private

  def names model
    (
      [model.name, model.english] + (model.synonyms || []) + [model.franchise]
    ).select(&:present?).uniq
  end

  def scope
    Anime
      .where(Arel.sql("not(desynced @> '{\"coub_tags\"}')"))
      .order(:franchise, :id)
  end

  def log model, tags
    NamedLogger.coub_tag.info(
      "`#{tags.join('`,`')}` for #{model.class.name.downcase} ID=#{model.id} NAME=#{model.name}"
    )
  end
end
