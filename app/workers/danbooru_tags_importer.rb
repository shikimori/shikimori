# загрузка новых тегов с DanbooruJob
class DanbooruTagsImporter
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    DanbooruTag.import_from_danbooru(10)

    tags = Set.new(DanbooruTag.where(kind: DanbooruTag::Copyright).pluck :name)
    [Anime, Manga].each do |klass|
      entries = klass.where(tags: nil).all

      entries.each do |v|
        tag = DanbooruTag.match([v.name] + (v.english || []) + (v.synonyms || []), tags, false)
        v.update_attribute(:tags, tag) if tag
      end
    end

    tags = Set.new(DanbooruTag.where(kind: DanbooruTag::Character, ambiguous: false).pluck :name)
    Character.where(tags: nil)
             .includes(:animes)
             .includes(:mangas)
             .find_each(batch_size: 5000) do |character|

      names = ([character.name] + [character.name.split(' ').reverse.join(' ')]).uniq
      if character.fullname =~ /.*"(.*)"/
        names += $1.split(',').map(&:strip)
      end

      entries_tags = (character.animes + character.mangas).map {|v| v.tags }.compact
      tag = nil
      # сачала попытаемся подобрать имя тега, включающее имя аниме/манги
      unless entries_tags.empty?
        tag = DanbooruTag.match(names.map {|name| entries_tags.map {|entry_tag| "#{name.gsub(' ', '_')}_(#{entry_tag})".downcase } }.flatten.uniq, tags, true)
      end
      tag = DanbooruTag.match(names, tags, true) unless tag
      character.update_attribute(:tags, tag) if tag
    end
  end
end

