class Tags::ImportDanbooruTagsWorker
  include Sidekiq::Worker

  def perform
    import_tags
    match_tags
  end

private

  def import_tags
    Tags::ImportDanbooruTags.call
  end

  def match_tags
    tags = Set.new(DanbooruTag.where(kind: DanbooruTag::COPYRIGHT).pluck(:name))
    [Anime, Manga].each do |klass|
      entries = klass.where(tags: nil).all

      entries.each do |v|
        names = ([v.name, v.english] + (v.synonyms || [])).select(&:present?)
        tag = DanbooruTag.match(names, tags, false)
        v.update_attribute(:tags, tag) if tag
      end
    end

    tags = Set.new(
      DanbooruTag.where(kind: DanbooruTag::CHARACTER, ambiguous: false)
        .pluck(:name)
    )

    Character
      .where(tags: nil)
      .includes(:animes)
      .includes(:mangas)
      .find_each(batch_size: 5000) do |character|
        names = (
          [character.name] + [character.name.split(' ').reverse.join(' ')]
        ).uniq

        if character.fullname =~ /.*"(.*)"/
          names += Regexp.last_match(1).split(',').map(&:strip)
        end

        entries_tags = (character.animes + character.mangas).map(&:tags).compact
        tag = nil
        # сачала попытаемся подобрать имя тега, включающее имя аниме/манги
        unless entries_tags.empty?
          tag = DanbooruTag.match(
            names
              .map { |name| entries_tags.map { |entry_tag| "#{name.tr(' ', '_')}_(#{entry_tag})".downcase } }
              .flatten
              .uniq,
            tags,
            true
          )
        end
        tag ||= DanbooruTag.match(names, tags, true)
        character.update_attribute(:tags, tag) if tag
      end
  end
end
