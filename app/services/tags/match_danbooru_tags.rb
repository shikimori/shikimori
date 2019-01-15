class Tags::MatchDanbooruTags
  method_object

  def call
    animanga_tags = animanga_tags_scope.pluck(:name)
    character_tags = character_tags_scope.pluck(:name)

    match_animangas animanga_tags, animes_scope
    match_animangas animanga_tags, mangas_scope
    match_characters character_tags, characters_scope
  end

private

  def match_animangas tags, scope
    scope.find_each do |model|
      names = anime_names model
      tag = match names, tags, false

      if tag
        model.update imageboard_tag: tag
        log model, tag
      end
    end
  end

  def match_characters tags, scope # rubocop:disable MethodLength
    scope.find_each do |model|
      names = character_names model

      if model.fullname =~ /.*"(.*)"/
        names += Regexp.last_match(1).split(',').map(&:strip)
      end

      entries_tags = (model.animes + model.mangas).map(&:imageboard_tag).compact
      tag = nil

      if entries_tags.any?
        tag = match compile_names(entries_tags, names), tags, true
      end

      tag ||= match names, tags, true

      if tag
        model.update imageboard_tag: tag
        log model, tag
      end
    end
  end

  def match names, tags, no_correct
    Tags::MatchNames.call(
      names: names,
      tags: tags,
      no_correct: no_correct
    ).first
  end

  def animes_scope
    Anime
      .where(imageboard_tag: nil)
  end

  def mangas_scope
    Manga
      .where(imageboard_tag: nil)
  end

  def characters_scope
    Character
      .where(imageboard_tag: nil)
      .includes(:animes)
      .includes(:mangas)
  end

  def compile_names entries_tags, names
    names
      .flat_map do |name|
        entries_tags.map { |entry_tag| "#{name.tr(' ', '_')}_(#{entry_tag})".downcase }
      end
      .uniq
  end

  def anime_names model
    (
      [model.name, model.english] + (model.synonyms || []) + [model.franchise]
    ).select(&:present?).uniq
  end

  def character_names model
    (
      [model.name] + [model.name.split(' ').reverse.join(' ')]
    ).uniq
  end

  def animanga_tags_scope
    DanbooruTag.where kind: DanbooruTag::COPYRIGHT
  end

  def character_tags_scope
    DanbooruTag.where kind: DanbooruTag::CHARACTER, ambiguous: false
  end

  def log model, tag
    NamedLogger.danbooru_tag.info(
      "`#{tag}` for #{model.class.name.downcase} ID=#{model.id} NAME=#{model.name}"
    )
  end
end
