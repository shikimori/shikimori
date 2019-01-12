class Tags::MatchCoubTags
  method_object :tags

  def call
    scope.find_each do |anime|
      tag = Tags::MatchNames.call(
        names: names(anime),
        tags: @tags,
        no_correct: false
      )

      if tag.present?
        anime.update coub_tag: tag
        log anime, tag
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
    Anime.where(coub_tag: nil).order(:franchise, :id)
  end

  def log model, tag
    NamedLogger.coub_tag.info(
      "`#{tag}` for #{model.class.name.downcase} ID=#{model.id} NAME=#{model.name}"
    )
  end
end
